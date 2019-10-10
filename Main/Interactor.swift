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
    func routeToSearchScreen()
    func routeToDetails(artistName: String, albumTitle: String)
    func closeDetails()
}

protocol Presentable: RIBs.Presentable {
    var listener: PresentableListener? { get set }
    var relay: BehaviorRelay<ViewModel?> { get set }
}

public protocol Listener: AnyObject {}

final class Interactor: PresentableInteractor<Presentable>, Interactable, PresentableListener {
    weak var router: Routing?
    weak var listener: Listener?

    lazy var didSelectAlbumRelay = BehaviorRelay<Int?>(value: nil)

    init(
        presenter: Presentable,
        networkStatusStream: ImmutableStream<NetworkStatus>,
        transformer: ViewModelTransformer = .init()
    ) {
        self.transformer = transformer
        self.networkStatusStream = networkStatusStream
        super.init(presenter: presenter)
        presenter.listener = self
    }

    override func didBecomeActive() {
        setupBindings()
        fetch()
    }

    func didTapOnSearchButton() {
        router?.routeToSearchScreen()
    }

    func closeScreen() {
        router?.closeDetails()
    }

    private let transformer: ViewModelTransformer
    private let state = BehaviorRelay<[(artistName: String, albumTitle: String)]>(value: [])
    private let networkStatusStream: ImmutableStream<NetworkStatus>
}

private extension Interactor {
    func setupBindings() {
        networkStatusStream.skipWhile { $0 == .reachable }
            .distinctUntilChanged()
            .bind(
                onNext: { [presenter] status in
                    presenter.relay.accept(.isOnline(status == .reachable))
                }
            ).disposeOnDeactivate(interactor: self)

        didSelectAlbumRelay.flatMap(Observable.from(optional:))
            .withLatestFrom(state) { $1[$0] }
            .bind(
                onNext: { [weak router] in
                    router?.routeToDetails(artistName: $0.artistName, albumTitle: $0.albumTitle)
                }
            ).disposeOnDeactivate(interactor: self)
    }

    func fetch() {
        let source = Realm.rx.execute {
            $0.objects(AlbumManagedModel.self)
        }.asObservable()
            .map { $0.sorted(byKeyPath: "title", ascending: true) }
            .flatMap { Observable.collection(from: $0, synchronousStart: false) }
            .map { $0.toArray() }
            .share()

        source.map {
            $0.compactMap { item -> (artistName: String, albumTitle: String)? in
                guard let artistName = item.artist?.title else { return nil }
                return (artistName, item.title)
            }
        }.bind(
            onNext: { [state] in
                state.accept($0)
            }
        ).disposeOnDeactivate(interactor: self)

        source.map { [transformer] in
            transformer.transform(from: $0)
        }.asDriver(
            onErrorRecover: { error in
                print(error)
                return .empty()
            }
        ).drive(presenter.relay)
            .disposeOnDeactivate(interactor: self)
    }
}
