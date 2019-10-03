import Combine
import RxSwift
import Utils

protocol TrackFetchable: AnyObject {
    func fetchTracks(by albumTitle: String, artistName: String) -> Observable<TrackResponse>
    func fetchArtist(for name: String) -> Observable<ArtistResponse>
}

final class TrackFetcher: TrackFetchable {
    init(_ apiClient: ApiClient) {
        self.apiClient = apiClient
    }

    func fetchTracks(by albumTitle: String, artistName: String) -> Observable<TrackResponse> {
        return apiClient.get(
            parameters: TrackRequest(artist: artistName, album: albumTitle),
            resultType: TrackResponse.self
        )
    }

    func fetchArtist(for name: String) -> Observable<ArtistResponse> {
        return apiClient.get(
            parameters: ArtistRequest(artist: name),
            resultType: ArtistResponse.self
        )
    }

    private let apiClient: ApiClient
}

private extension TrackFetcher {
    struct TrackRequest: RequestParamsConvertible {
        let method = "album.getinfo"
        let artist: String
        let album: String
    }

    struct ArtistRequest: RequestParamsConvertible {
        let method = "artist.getInfo"
        let artist: String
    }
}
