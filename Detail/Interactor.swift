import ManagedModels
import os
import RealmSwift
import RxRealm
import RIBs
import RIBsExtensions
import RxCocoa
import RxSwift
import Utils

public protocol Routing: ViewableRouting {}

protocol Presentable: RIBs.Presentable {
    var listener: PresentableListener? { get set }
    var relay: BehaviorRelay<ViewModel> { get }
}

public protocol Listener: AnyObject {}

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
        loadingDisposable.disposeOnDeactivate(interactor: self)

        networkStatusStream.flatMap { [fetchFromRemote, fetchFromLocal] (status: NetworkStatus) -> Observable<ViewModel> in
                switch status {
                case .reachable:
                    return fetchFromRemote()
                case .notReachable:
                    return fetchFromLocal()
                }
            }.take(1)
            .subscribeOn(workingScheduler)
            .observeOn(MainScheduler.instance)
            .asDriver(onErrorJustReturn: .empty)
            .drive(presenter.relay)
            .disposeOnDeactivate(interactor: self)
    }

    func didPressDownload() {
        let albumSavingStateCheck = checkExistance().asObservable().share()

        let deleteAlbumObservable: Observable<ViewModelTransformer.LoadingState> = albumSavingStateCheck.filter { $0 == true }
            .flatMap { [deleteAlbum] _ in deleteAlbum().andThen(Observable.just(.preloading)) }
            .observeOn(MainScheduler.instance)

        let saveAlbumObservable: Observable<ViewModelTransformer.LoadingState> = albumSavingStateCheck.filter { $0 == false }
            .flatMap { [saveAlbum] _ in
                saveAlbum().andThen(Observable.just(.loaded))
                    .observeOn(MainScheduler.instance)
            }.startWith(.loading)

        loadingDisposable.disposable = deleteAlbumObservable.ifEmpty(
            switchTo: saveAlbumObservable
        ).withLatestFrom(state.flatMap(Observable.from(optional:))) { (loadingState: $0, tracks: $1) }
        .observeOn(workingScheduler)
        .map { [viewModelTransformer] in viewModelTransformer.transform($0.tracks, loadingState: $0.loadingState) }
        .observeOn(MainScheduler.instance)
        .asDriver(
            onErrorRecover: {
                os_log(.error, log: .logic, "Failed to delete/save album, error: %@", $0.localizedDescription)
                return .just(.empty)
            }
        ).drive(presenter.relay)
    }

    private let fetcher: TrackFetchable
    private let viewModelTransformer: ViewModelTransformer
    private let networkStatusStream: ImmutableStream<NetworkStatus>
    private let configuration: Configuration
    private let albumSaver: AlbumSaver

    private let workingScheduler = ConcurrentDispatchQueueScheduler(qos: .utility)

    private let state = BehaviorSubject<TrackResponse?>(value: nil)

    private var loadingDisposable = SerialDisposable()
}

private extension Interactor {
    func saveAlbum() -> Completable {
        return fetcher.fetchArtist(
            for: configuration.artistName
        ).withLatestFrom(
            state.asObservable().flatMap(Observable.from(optional:))
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

        source.bind(
            onNext: { [state] model in
                state.onNext(model)
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
                ArtistManagedModel.self
            ).filter("title = %@", configuration.artistName)
        }.map { _ in .empty }
        .asObservable()
    }
}
