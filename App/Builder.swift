import Alamofire
import Main
import RIBs
import RIBsExtensions
import Utils

class Dependency: EmptyDependency {}

final class Component: RIBs.Component<Dependency> {
    let apiClient: ApiClient

    override init(dependency: Dependency) {
        let path = Bundle.main.path(forResource: "settings", ofType: "plist")!
        let dictionary = NSDictionary(contentsOfFile: path) as! [String: String]
        apiClient = DefaultApiClient(
            baseURL: dictionary["BASE_URL"]!,
            defaultRequestParameters: InitialParams(
                apiKey: dictionary["API_KEY"]!
            )
        )

        super.init(dependency: dependency)
    }

    let networkStatusMutableStream = MutableStream<NetworkStatus>()

    struct InitialParams: RequestParamsConvertible {
        let apiKey: String
        let format = "json"

        enum CodingKeys: String, CodingKey {
            case apiKey = "api_key"
            case format
        }
    }
}

// MARK: - Builder

protocol Buildable: RIBs.Buildable {
    func build() -> Routing
}

final class Builder: RIBs.Builder<Dependency>, Buildable {
    override init(dependency: Dependency = .init()) {
        super.init(dependency: dependency)
    }

    func build() -> Routing {
        let component = Component(dependency: dependency)
        let viewController = ViewController()
        let interactor = Interactor(presenter: viewController, stream: component.networkStatusMutableStream)
        return Router(
            interactor: interactor,
            viewController: viewController,
            mainBuilder: Main.Builder(dependency: component)
        )
    }
}
