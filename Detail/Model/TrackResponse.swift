import Foundation

// MARK: - TrackResponse

struct TrackResponse: Codable {
    let album: Album
}

extension TrackResponse {
    // MARK: - Album

    struct Album: Codable {
        let name: String
        let artist: String
        let url: String
        let image: [Image]
        let listeners, playcount: String
        let tracks: Tracks
        let tags: Tags
    }

    // MARK: - Image

    struct Image: Codable {
        let text: String
        let size: Size

        enum CodingKeys: String, CodingKey {
            case text = "#text"
            case size
        }
    }

    enum Size: String, Codable {
        case extralarge
        case mega
        case large
        case medium
        case small
        case unknown = ""
    }

    // MARK: - Tags

    struct Tags: Codable {
        let tag: [Tag]
    }

    // MARK: - Tag

    struct Tag: Codable {
        let name: String
        let url: String
    }

    // MARK: - Tracks

    struct Tracks: Codable {
        let track: [Track]
    }

    // MARK: - Track

    struct Track: Codable {
        let name: String
        let url: String
        let duration: String
        let attr: Attr
        let streamable: Streamable
        let artist: ArtistClass

        enum CodingKeys: String, CodingKey {
            case name, url, duration
            case attr = "@attr"
            case streamable, artist
        }
    }

    // MARK: - ArtistClass

    struct ArtistClass: Codable {
        let name: String
        let url: String
    }

    // MARK: - Attr

    struct Attr: Codable {
        let rank: String
    }

    // MARK: - Streamable

    struct Streamable: Codable {
        let text, fulltrack: String

        enum CodingKeys: String, CodingKey {
            case text = "#text"
            case fulltrack
        }
    }
}
