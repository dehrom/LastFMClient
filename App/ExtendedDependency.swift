import Main
import RIBs
import RIBsExtensions
import Search
import Utils

extension Component: Main.Dependency {
    var networkStatusStream: ImmutableStream<NetworkStatus> {
        return networkStatusMutableStream.asImmutable()
    }
}
