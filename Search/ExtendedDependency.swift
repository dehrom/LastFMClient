import Albums
import RIBs
import RIBsExtensions
import Utils

extension Component: Albums.Dependency {
    var apiClient: ApiClient {
        return dependency.apiClient
    }

    var networkStatusStream: ImmutableStream<NetworkStatus> {
        return dependency.networkStatusStream
    }
}
