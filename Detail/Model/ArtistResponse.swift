import Foundation

// MARK: - ArtistResponse

struct ArtistResponse: Codable {
    let artist: ArtistResponseArtist
}

extension ArtistResponse {
    // MARK: - ArtistResponseArtist

    struct ArtistResponseArtist: Codable {
        let name: String
        let url: String
        let image: [Image]
        let streamable, ontour: String
        let stats: Stats
        let similar: Similar
        let tags: Tags
        let bio: Bio
    }

    // MARK: - Bio

    struct Bio: Codable {
        let links: Links
        let published, summary, content: String
    }

    // MARK: - Links

    struct Links: Codable {
        let link: Link
    }

    // MARK: - Link

    struct Link: Codable {
        let text, rel: String
        let href: String

        enum CodingKeys: String, CodingKey {
            case text = "#text"
            case rel, href
        }
    }

    // MARK: - Image

    struct Image: Codable {
        let text: String
        let size: Size

        enum CodingKeys: String, CodingKey {
            case text = "#text"
            case size
        }

        enum Size: String, Codable {
            case extralarge
            case large
            case medium
            case mega
            case small
            case unknown = ""
        }
    }

    // MARK: - Similar

    struct Similar: Codable {
        let artist: [ArtistElement]
    }

    // MARK: - ArtistElement

    struct ArtistElement: Codable {
        let name: String
        let url: String
        let image: [Image]
    }

    // MARK: - Stats

    struct Stats: Codable {
        let listeners, playcount: String
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
}
