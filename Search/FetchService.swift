import Foundation
import RxSwift
import Utils

protocol Fetchable: AnyObject {
    func fetch(for artistName: String) -> Observable<SearchResponse>
}

final class Fetcher: Fetchable {
    init(apiClient: ApiClient) {
        self.apiClient = apiClient
    }
    
    func fetch(for artistName: String) -> Observable<SearchResponse> {
        return apiClient.get(
            parameters: SearchRequest(artist: artistName),
            resultType: SearchResponse.self
        )
    }
    
    private let apiClient: ApiClient
}

private extension Fetcher {
    struct SearchRequest: RequestParamsConvertible {
        let method = "artist.search"
        let artist: String
    }
}
