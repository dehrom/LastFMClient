import class Alamofire.NetworkReachabilityManager
import Foundation

public enum NetworkStatus {
    case reachable
    case notReachable
}

public extension Alamofire.NetworkReachabilityManager.NetworkReachabilityStatus {
    func asNetworkStatus() -> NetworkStatus {
        switch self {
        case .notReachable, .unknown:
            return .notReachable
        case .reachable:
            return .reachable
        }
    }
}
