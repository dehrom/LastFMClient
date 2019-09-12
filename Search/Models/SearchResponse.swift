import Foundation

// MARK: - SearchResponse

struct SearchResponse: Codable {
    let results: Results
}

// MARK: - Results

struct Results: Codable {
    let opensearchQuery: OpensearchQuery
    let opensearchTotalResults, opensearchStartIndex, opensearchItemsPerPage: String
    let artistmatches: Artistmatches
    let attr: Attr

    enum CodingKeys: String, CodingKey {
        case opensearchQuery = "opensearch:Query"
        case opensearchTotalResults = "opensearch:totalResults"
        case opensearchStartIndex = "opensearch:startIndex"
        case opensearchItemsPerPage = "opensearch:itemsPerPage"
        case artistmatches
        case attr = "@attr"
    }
}

// MARK: - Artistmatches

struct Artistmatches: Codable {
    let artist: [Artist]
}

// MARK: - Artist

struct Artist: Codable {
    let name, listeners, mbid: String
    let url: String
    let streamable: String
    let image: [Image]
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
    case mega
    case small
}

// MARK: - Attr

struct Attr: Codable {
    let attrFor: String

    enum CodingKeys: String, CodingKey {
        case attrFor = "for"
    }
}

// MARK: - OpensearchQuery

struct OpensearchQuery: Codable {
    let text, role, searchTerms, startPage: String

    enum CodingKeys: String, CodingKey {
        case text = "#text"
        case role, searchTerms, startPage
    }
}
