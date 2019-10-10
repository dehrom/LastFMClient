import ManagedModels
import os
import RealmSwift
import RIBs
import RIBsExtensions
import RxCocoa
import RxRealm
import RxSwift
import Utils

public protocol Routing: ViewableRouting {}

protocol Presentable: RIBs.Presentable {
    var listener: PresentableListener? { get set }
    var relay: BehaviorRelay<ViewModel?> { get }
}

public protocol Listener: AnyObject {
    func closeScreen()
}

final class Interactor: PresentableInteractor<Presentable>, Interactable, PresentableListener {
    weak var router: Routing?
    weak var listener: Listener?

    init(
        presenter: Presentable,
        fetcher: TrackFetchable,
        networkStatusStream: ImmutableStream<NetworkStatus>,
        configuration: Configuration,
        viewModelTransformer: ViewModelTransformer = .init(),
        albumSaver: AlbumSaver = .init()
    ) {
        self.fetcher = fetcher
        self.networkStatusStream = networkStatusStream
        self.configuration = configuration
        self.viewModelTransformer = viewModelTransformer
        self.albumSaver = albumSaver
        super.init(presenter: presenter)
        presenter.listener = self
    }

    override func didBecomeActive() {
        loadingDisposables.disposeOnDeactivate(interactor: self)

        networkStatusStream.flatMap { [fetchFromRemote, fetchFromLocal] (status: NetworkStatus) -> Observable<ViewModel> in
            switch status {
            case .reachable:
                return fetchFromRemote().catchError {
                    os_log(.error, log: .logic, "Failed to fetch album's details from server (switch to local), error: %@", $0.localizedDescription)
                    return fetchFromLocal()
                }
            case .notReachable:
                return fetchFromLocal().catchError {
                    os_log(.error, log: .logic, "Failed to fetch album's details from local storage, error: %@", $0.localizedDescription)
                    return .just(.empty("Failed to fetch album's details."))
                }
            }
        }.take(1)
            .subscribeOn(workingScheduler)
            .observeOn(MainScheduler.instance)
            .ifEmpty(default: .empty("There is no data for this album."))
            .asDriver(onErrorJustReturn: .empty("Failed to fetch album's details."))
            .drive(presenter.relay)
            .disposeOnDeactivate(interactor: self)
    }

    func didPressDownload() {
        loadingDisposables = .init()

        let viewModelDisposable = checkExistance().asObservable().flatMap { [startDeletingSequence, startLoadingSequence] isSaved -> Observable<ViewModel> in
            isSaved == true ? startDeletingSequence() : startLoadingSequence()
        }.observeOn(MainScheduler.instance)
            .asDriver(onErrorJustReturn: .empty("Unknown error"))
            .drive(presenter.relay)
        _ = loadingDisposables.insert(viewModelDisposable)
    }

    func didPressClose() {
        listener?.closeScreen()
    }

    private let fetcher: TrackFetchable
    private let viewModelTransformer: ViewModelTransformer
    private let networkStatusStream: ImmutableStream<NetworkStatus>
    private let configuration: Configuration
    private let albumSaver: AlbumSaver

    private let workingScheduler = ConcurrentDispatchQueueScheduler(qos: .utility)

    private let tracks = BehaviorSubject<TrackResponse?>(value: nil)

    private var loadingDisposables = CompositeDisposable()
}

private extension Interactor {
    func startDeletingSequence() -> Observable<ViewModel> {
        return deleteAlbum().andThen(
            Observable.just(ViewModel.empty("Album deleted"))
        ).catchError {
            os_log(.error, log: .logic, "Failed to delete album, error: %@", $0.localizedDescription)
            return .just(.empty("Failed to delete album"))
        }
    }

    func startLoadingSequence() -> Observable<ViewModel> {
        let saveObservable = saveAlbum().andThen(
            Observable.just(ViewModel.LoadingState.loaded)
        ).share()

        let errorHandlingDisposable = saveObservable.materialize().flatMap {
            Observable.from(optional: $0.error)
        }.map { error -> ViewModel in
            os_log(.error, log: .logic, "Failed to save album, error: %@", error.localizedDescription)
            return .empty("Failed to save album")
        }.observeOn(MainScheduler.instance)
            .bind(to: presenter.relay)
        _ = loadingDisposables.insert(errorHandlingDisposable)

        return saveObservable.materialize().flatMap {
            Observable.from(optional: $0.element)
        }.withLatestFrom(
            tracks.flatMap(Observable.from(optional:))
        ) { (loadingState: $0, tracks: $1) }
            .map { [viewModelTransformer] in
                viewModelTransformer.transform($0.tracks, loadingState: $0.loadingState)
            }.catchError {
                os_log(.error, log: .logic, "Failed to transform album, error: %@", $0.localizedDescription)
                return .just(.empty("Failed to save album"))
            }
    }

    func saveAlbum() -> Completable {
        return fetcher.fetchArtist(
            for: configuration.artistName
        ).withLatestFrom(
            tracks.asObservable().flatMap(Observable.from(optional:))
        ) { (artist: $0, tracks: $1) }
            .flatMap { [albumSaver, workingScheduler] in
                albumSaver.saveAlbum(with: $0.tracks, and: $0.artist).subscribeOn(workingScheduler)
            }.asCompletable()
    }

    func checkExistance() -> Maybe<Bool> {
        return Realm.rx.execute { [configuration] in
            let index = $0.objects(
                AlbumManagedModel.self
            ).index(
                matching: "title = %@ AND artist.title = %@",
                configuration.albumTitle,
                configuration.artistName
            )
            return index != nil
        }
    }

    func deleteAlbum() -> Completable {
        return Realm.rx.execute { [configuration] realm in
            let album = realm.objects(
                AlbumManagedModel.self
            ).filter(
                "title = %@ AND artist.title = %@",
                configuration.albumTitle,
                configuration.artistName
            )
            guard
                album.isEmpty == false
            else { fatalError("There is no saved album: \(configuration.albumTitle), for artist: \(configuration.artistName)") }

            try realm.write {
                album.map { $0.tracks }.forEach { realm.delete($0) }
                realm.delete(album)
            }
        }.asObservable()
            .ignoreElements()
    }

    func fetchFromRemote() -> Observable<ViewModel> {
        let source = fetcher.fetchTracks(
            by: configuration.albumTitle,
            artistName: configuration.artistName
        ).share()

        source.subscribe(
            onNext: { [tracks] model in
                tracks.onNext(model)
            }
        ).disposeOnDeactivate(interactor: self)

        return Observable.zip(
            source,
            checkExistance().asObservable()
        ).observeOn(workingScheduler)
            .map { [viewModelTransformer] in
                viewModelTransformer.transform(
                    $0,
                    loadingState: $1 == true ? .loaded : .preloading
                )
            }
    }

    func fetchFromLocal() -> Observable<ViewModel> {
        return Realm.rx.execute { [configuration] in
            $0.objects(
                AlbumManagedModel.self
            ).filter(
                "title = %@ AND artist.title = %@",
                configuration.albumTitle,
                configuration.artistName
            ).first
        }.asObservable()
            .flatMap(Observable.from(optional:))
            .map { [viewModelTransformer] in viewModelTransformer.transform($0) }
    }
}
