import RIBs
import RIBsExtensions
import Search
import Utils
import Detail

extension Component {
    var apiClient: ApiClient {
        return dependency.apiClient
    }

    var networkStatusStream: ImmutableStream<NetworkStatus> {
        return dependency.networkStatusStream
    }
}

extension Component: Detail.Dependency {}

extension Component: Search.Dependency {}
