import Alamofire
import os
import RIBs
import RIBsExtensions
import RxSwift
import Utils

protocol Routing: LaunchRouting {
    func routeToMain()
}

protocol Presentable: RIBs.Presentable {
    var listener: PresentableListener? { get set }
}

protocol Listener: AnyObject {}

final class Interactor: PresentableInteractor<Presentable>, Interactable, PresentableListener {
    weak var router: Routing?
    weak var listener: Listener?

    init(
        presenter: Presentable,
        stream: MutableStream<NetworkStatus>,
        reachabilityManager: NetworkReachabilityManager? = NetworkReachabilityManager()
    ) {
        self.stream = stream
        self.reachabilityManager = reachabilityManager
        super.init(presenter: presenter)
        presenter.listener = self
    }

    override func didBecomeActive() {
        observeNetworkStatus()
        router?.routeToMain()
    }

    private let stream: MutableStream<NetworkStatus>
    private let reachabilityManager: NetworkReachabilityManager?
}

private extension Interactor {
    func observeNetworkStatus() {
        reachabilityManager?.listener = { [stream] in
            let networkStatus = $0.asNetworkStatus()
            stream.update(with: networkStatus)
        }
        guard
            let manager = reachabilityManager,
            manager.startListening() == true
        else {
            os_log(.fault, log: .structure, "failed to start listening network status", "")
            return
        }
    }
}
