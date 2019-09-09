import RIBs
import Utils

public protocol Dependency: RIBs.Dependency {
    var apiClient: ApiClient { get }
}

final class Component: RIBs.Component<Dependency> {
    fileprivate lazy var fetcher: Fetchable = Fetcher(apiClient: dependency.apiClient)
}

// MARK: - Builder

public protocol Buildable: RIBs.Buildable {
    func build(withListener listener: Listener) -> Routing
}

public final class Builder: RIBs.Builder<Dependency>, Buildable {
    public override init(dependency: Dependency) {
        super.init(dependency: dependency)
    }

    public func build(withListener listener: Listener) -> Routing {
        let component = Component(dependency: dependency)
        let viewController = ViewController()
        let interactor = Interactor(presenter: viewController, fetcher: component.fetcher)
        interactor.listener = listener
        return Router(interactor: interactor, viewController: viewController)
    }
}
