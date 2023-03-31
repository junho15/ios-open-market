import Foundation

struct ProductImage {
    let id: Int
    let url: String
    let thumbnailURL: String
    let issuedAt: String
}

extension ProductImage: Decodable {
    enum CodingKeys: String, CodingKey {
        case id, url
        case thumbnailURL = "thumbnail_url"
        case issuedAt = "issued_at"
    }
}
