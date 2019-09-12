import RIBs
import Search
import Utils

protocol ExtendedDependency: RIBs.Dependency {}

extension Component: Search.Dependency {
    var apiClient: ApiClient {
        return dependency.apiClient
    }
}
