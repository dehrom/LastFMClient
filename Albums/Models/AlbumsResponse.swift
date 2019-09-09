import Foundation

// MARK: - AlbumsResponse

struct AlbumsResponse: Codable {
    let topalbums: Topalbums
}

extension AlbumsResponse {
    // MARK: - Topalbums

    struct Topalbums: Codable {
        let album: [Album]
        let attr: Attr

        enum CodingKeys: String, CodingKey {
            case album
            case attr = "@attr"
        }
    }

    // MARK: - Album

    struct Album: Codable {
        let name: String
        let playcount: Int
        let url: String
        let artist: ArtistClass
        let image: [Image]
    }

    // MARK: - ArtistClass

    struct ArtistClass: Codable {
        let name: String
        let url: String
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
        case large
        case medium
        case small
    }

    // MARK: - Attr

    struct Attr: Codable {
        let artist: String
        let page, perPage, totalPages, total: String
    }
}
