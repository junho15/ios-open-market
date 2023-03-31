import Foundation

struct ProductVendor {
    let id: Int
    let name: String
}

extension ProductVendor: Decodable { }
