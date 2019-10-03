import Foundation
import RxSwift
import Utils

protocol AlbumsFetchable: AnyObject {
    func fetchAlbums(for name: String) -> Observable<AlbumsResponse>
}

final class AlbumsFetcher: AlbumsFetchable {
    init(apiClient: ApiClient) {
        self.apiClient = apiClient
    }

    func fetchAlbums(for name: String) -> Observable<AlbumsResponse> {
        return apiClient.get(
            parameters: AlbumsRequest(artist: name),
            resultType: AlbumsResponse.self
        )
    }

    private let apiClient: ApiClient
}

private extension AlbumsFetcher {
    struct AlbumsRequest: RequestParamsConvertible {
        let method = "artist.getTopAlbums"
        let artist: String
    }
}
