import RIBs
import Utils
import Search

public protocol Dependency: RIBs.Dependency {
    var apiClient: ApiClient { get }
}

final class Component: RIBs.Component<Dependency> {}

// MARK: - Builder

public protocol Buildable: RIBs.Buildable {
    func build() -> LaunchRouting
}

public final class Builder: RIBs.Builder<Dependency>, Buildable {
    public override init(dependency: Dependency) {
        super.init(dependency: dependency)
    }

    public func build() -> LaunchRouting {
        let component = Component(dependency: dependency)
        let viewController = ViewController()
        let interactor = Interactor(presenter: viewController)
        return Router(
            interactor: interactor,
            viewController: viewController,
            searchBuilder: Search.Builder(dependency: component)
        )
    }
}
