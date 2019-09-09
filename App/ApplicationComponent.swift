import Foundation
import Main
import RIBs
import Utils

final class ApplicationComponent: EmptyComponent {
    let apiClient: ApiClient
    
    override init() {
        let path = Bundle.main.path(forResource: "settings", ofType: "plist")!
        let dictionary = NSDictionary(contentsOfFile: path) as! [String: String]
        apiClient = DefaultApiClient(
            baseURL: dictionary["BASE_URL"]!,
            defaultRequestParameters: InitialParams(
                apiKey: dictionary["API_KEY"]!
            )
        )
        
        super.init()
    }
}

extension ApplicationComponent {
    struct InitialParams: RequestParamsConvertible {
        let apiKey: String
        let format = "json"
        
        enum CodingKeys: String, CodingKey {
            case apiKey = "api_key"
            case format
        }
    }
}

extension ApplicationComponent: Main.Dependency {}
