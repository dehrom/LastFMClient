import ManagedModels
import os
import RealmSwift
import RIBs
import RIBsExtensions
import RxCocoa
import RxRealm
import RxSwift
import Utils

public protocol Routing: ViewableRouting {
    func routeToDetails(artistName: String, albumTitle: String)
    func closeDetails()
}

protocol Presentable: RIBs.Presentable {
    var listener: PresentableListener? { get set }
    var relay: BehaviorRelay<ViewModel?> { get }
}

public protocol Listener: AnyObject {}

final class Interactor: PresentableInteractor<Presentable>, Interactable, PresentableListener {
    weak var router: Routing?
    weak var listener: Listener?

    var didSelectAlbumRelay = BehaviorRelay<ViewModel.Album?>(value: nil)

    init(
        presenter: Presentable,
        fetcher: AlbumsFetchable,
        configuration: Configuration,
        viewModelTransformer: ViewModelTransformer = .init()
    ) {
        self.fetcher = fetcher
        self.configuration = configuration
        self.viewModelTransformer = viewModelTransformer
        super.init(presenter: presenter)
        presenter.listener = self
    }

    override func didBecomeActive() {
        setupBindings()
        fetch()
    }

    // MARK: - Detail

    func closeScreen() {
        router?.closeDetails()
    }

    private let fetcher: AlbumsFetchable
    private let configuration: Configuration
    private let viewModelTransformer: ViewModelTransformer
}

private extension Interactor {
    func setupBindings() {
        didSelectAlbumRelay.flatMap(Observable.from(optional:))
            .map { [configuration] in (configuration.artistName, $0.identity) }
            .bind(onNext: { [weak router] in router?.routeToDetails(artistName: $0, albumTitle: $1) })
            .disposeOnDeactivate(interactor: self)
    }

    func fetch() {
        let savedAlbumsTitles = Realm.rx.execute {
            $0.objects(AlbumManagedModel.self)
        }.asObservable()
            .flatMap {
                Observable.collection(from: $0, synchronousStart: false)
            }.map { $0.toArray().map { $0.title } }
            .ifEmpty(default: [])

        Observable.combineLatest(
            savedAlbumsTitles,
            fetcher.fetchAlbums(for: configuration.artistName)
        ).observeOn(ConcurrentDispatchQueueScheduler(qos: .userInteractive))
            .map { [viewModelTransformer] in viewModelTransformer.transform(from: $1, with: $0) }
            .observeOn(MainScheduler.instance)
            .ifEmpty(default: .empty("Couldn't fetch albums for this Artist, try again."))
            .asDriver(
                onErrorRecover: {
                    os_log(.error, log: .logic, "Failed to load albums, error: %@", $0.localizedDescription)
                    return .just(.empty("Failed to fetch albums."))
                }
            ).drive(presenter.relay)
            .disposeOnDeactivate(interactor: self)
    }
}
