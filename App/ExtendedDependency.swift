import Main
import RIBs
import RIBsExtensions
import Utils

extension Component: Main.Dependency {
    var networkStatusStream: ImmutableStream<NetworkStatus> {
        return networkStatusMutableStream.asImmutable()
    }
}
