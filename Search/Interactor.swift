import os
import RIBs
import RxCocoa
import RxSwift
import Utils

public protocol Routing: ViewableRouting {
    func routeToAlbums(with artisName: String)
}

protocol Presentable: RIBs.Presentable {
    var listener: PresentableListener? { get set }
    var relay: BehaviorRelay<ViewModel?> { get }
}

public protocol Listener: AnyObject {}

final class Interactor: PresentableInteractor<Presentable>, Interactable, PresentableListener {
    weak var router: Routing?
    weak var listener: Listener?

    lazy var selectedModelRelay = PublishRelay<ViewModel.Section.Row>()

    init(presenter: Presentable, fetcher: Fetchable, viewModelTranformer: ViewModelTransformer = .init()) {
        self.fetcher = fetcher
        self.viewModelTranformer = viewModelTranformer
        super.init(presenter: presenter)
        presenter.listener = self
    }

    override func didBecomeActive() {
        selectedModelRelay.map { $0.title }
            .bind(onNext: { [router] in router?.routeToAlbums(with: $0) })
            .disposeOnDeactivate(interactor: self)
    }

    func search(with artistName: String?) {
        guard
            let artistName = artistName,
            artistName.count > 0
        else {
            presenter.relay.accept(.sections([]))
            return
        }

        fetcher.fetch(for: artistName)
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .userInteractive))
            .map { [viewModelTranformer] in viewModelTranformer.tranform(from: $0) }
            .observeOn(MainScheduler.instance)
            .asDriver(
                onErrorRecover: {
                    os_log(.error, log: .logic, "failed to fetch search result, error: %@", $0.localizedDescription)
                    return .just(.empty("Failed to search albums."))
                }
            ).drive(presenter.relay)
            .disposeOnDeactivate(interactor: self)
    }

    private let fetcher: Fetchable
    private let viewModelTranformer: ViewModelTransformer
}
