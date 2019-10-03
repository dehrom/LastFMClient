import RIBs
import RIBsExtensions
import Utils

public struct Configuration {
    let artistName: String
    let albumTitle: String

    public init(artistName: String, albumTitle: String) {
        self.artistName = artistName
        self.albumTitle = albumTitle
    }
}

public protocol Dependency: RIBs.Dependency {
    var apiClient: ApiClient { get }
    var networkStatusStream: ImmutableStream<NetworkStatus> { get }
}

final class Component: RIBs.Component<Dependency> {
    fileprivate lazy var fetcher: TrackFetchable = TrackFetcher(dependency.apiClient)
}

// MARK: - Builder

public protocol Buildable: RIBs.Buildable {
    func build(withListener listener: Listener, configuration: Configuration) -> Routing
}

public final class Builder: RIBs.Builder<Dependency>, Buildable {
    public override init(dependency: Dependency) {
        super.init(dependency: dependency)
    }

    public func build(withListener listener: Listener, configuration: Configuration) -> Routing {
        let component = Component(dependency: dependency)
        let viewController = ViewController()
        let interactor = Interactor(
            presenter: viewController,
            fetcher: component.fetcher,
            networkStatusStream: component.dependency.networkStatusStream,
            configuration: configuration
        )
        interactor.listener = listener
        return Router(interactor: interactor, viewController: viewController)
    }
}
