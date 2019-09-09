import RIBs
import RxCocoa
import RxSwift
import Utils
import os

public protocol Routing: ViewableRouting {}

protocol Presentable: RIBs.Presentable {
    var listener: PresentableListener? { get set }
    var relay: BehaviorRelay<ViewModel> { get }
}

public protocol Listener: AnyObject {}

final class Interactor: PresentableInteractor<Presentable>, Interactable, PresentableListener {
    weak var router: Routing?
    weak var listener: Listener?

    init(presenter: Presentable, fetcher: Fetchable, viewModelTranformer: ViewModelTransformer = .init()) {
        self.fetcher = fetcher
        self.viewModelTranformer = viewModelTranformer
        super.init(presenter: presenter)
        presenter.listener = self
    }
    
    func search(with artistName: String) {
        fetcher.fetch(for: artistName)
            .map { [viewModelTranformer] in viewModelTranformer.tranform(from: $0) }
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .userInitiated))
            .observeOn(MainScheduler.instance)
            .asDriver(
                onErrorRecover: {
                    os_log(.error, log: .logic, "failed to fetch search result, error: %@", $0.localizedDescription)
                    return .just(.empty)
                }
            ).drive(presenter.relay)
            .disposeOnDeactivate(interactor: self)
    }
    
    private let fetcher: Fetchable
    private let viewModelTranformer: ViewModelTransformer
}
