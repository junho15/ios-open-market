struct Product: Identifiable {
    let id: Int
    let vendorID: Int
    let vendorName: String
    let name: String
    let description: String
    let thumbnailURL: String
    let currency: Currency
    let price: Double
    let bargainPrice: Double
    let discountedPrice: Double
    let stock: Int
    let createdAt: String
    let issuedAt: String
    let images: [ProductImage]?
    let vendors: ProductVendor?
}

extension Product: Decodable {
    private enum CodingKeys: String, CodingKey {
        case id
        case vendorID = "vendor_id"
        case vendorName, name, description
        case thumbnailURL = "thumbnail"
        case currency, price
        case bargainPrice = "bargain_price"
        case discountedPrice = "discounted_price"
        case stock
        case createdAt = "created_at"
        case issuedAt = "issued_at"
        case images
        case vendors
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decode(String.self, forKey: .description)
        thumbnailURL = try container.decode(String.self, forKey: .thumbnailURL)
        currency = try container.decode(Currency.self, forKey: .currency)
        price = try container.decode(Double.self, forKey: .price)
        bargainPrice = try container.decode(Double.self, forKey: .bargainPrice)
        discountedPrice = try container.decode(Double.self, forKey: .discountedPrice)
        stock = try container.decode(Int.self, forKey: .stock)
        createdAt = try container.decode(String.self, forKey: .createdAt)
        issuedAt = try container.decode(String.self, forKey: .issuedAt)
        images = try container.decodeIfPresent([ProductImage].self, forKey: .images)

        if let vendors = try? container.decodeIfPresent(ProductVendor.self, forKey: .vendors) {
            self.vendors = vendors
            vendorID = vendors.id
            vendorName = vendors.name
        } else {
            vendorID = try container.decode(Int.self, forKey: .vendorID)
            vendorName = try container.decode(String.self, forKey: .vendorName)
            vendors = nil
        }
    }
}
