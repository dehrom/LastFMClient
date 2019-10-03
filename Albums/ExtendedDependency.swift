import Detail
import Foundation
import RIBs
import RIBsExtensions
import Utils

extension Component: Detail.Dependency {
    var apiClient: ApiClient {
        return dependency.apiClient
    }

    var networkStatusStream: ImmutableStream<NetworkStatus> {
        return dependency.networkStatusStream
    }
}
