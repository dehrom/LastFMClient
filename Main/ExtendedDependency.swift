import Search
import RIBs
import Utils

protocol ExtendedDependency: RIBs.Dependency {}

extension Component: Search.Dependency {
    var apiClient: ApiClient {
        return self.dependency.apiClient
    }
}
