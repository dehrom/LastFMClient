import RIBs
import RIBsExtensions
import Search
import Utils

public protocol Dependency: RIBs.Dependency {
    var apiClient: ApiClient { get }
    var networkStatusStream: ImmutableStream<NetworkStatus> { get }
}

final class Component: RIBs.Component<Dependency> {}

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
        let interactor = Interactor(presenter: viewController)
        interactor.listener = listener
        return Router(
            interactor: interactor,
            viewController: viewController,
            searchBuilder: Search.Builder(dependency: component)
        )
    }
}
