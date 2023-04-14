struct Product: Identifiable {
    let id: Int
    let vendorID: Int
    let vendorName: String
    var name: String
    var description: String
    let thumbnailURL: String
    var currency: Currency
    var price: Double?
    var bargainPrice: Double?
    var discountedPrice: Double?
    var stock: Int?
    let createdAt: String
    let issuedAt: String
    var images: [ProductImage]?
    let vendors: ProductVendor?
    var thumbnailId: Int?

    init(id: Int,
         vendorID: Int,
         vendorName: String,
         name: String,
         description: String,
         thumbnailURL: String,
         currency: Currency,
         price: Double?,
         bargainPrice: Double?,
         discountedPrice: Double?,
         stock: Int?,
         createdAt: String,
         issuedAt: String,
         images: [ProductImage]? = nil,
         vendors: ProductVendor? = nil,
         thumbnailId: Int? = nil) {
        self.id = id
        self.vendorID = vendorID
        self.vendorName = vendorName
        self.name = name
        self.description = description
        self.thumbnailURL = thumbnailURL
        self.currency = currency
        self.price = price
        self.bargainPrice = bargainPrice
        self.discountedPrice = discountedPrice
        self.stock = stock
        self.createdAt = createdAt
        self.issuedAt = issuedAt
        self.images = images
        self.vendors = vendors
        self.thumbnailId = thumbnailId
    }

    init() {
        self.init(id: 0,
                  vendorID: 0,
                  vendorName: "",
                  name: "",
                  description: "",
                  thumbnailURL: "",
                  currency: .KRW,
                  price: nil,
                  bargainPrice: nil,
                  discountedPrice: nil,
                  stock: nil,
                  createdAt: "",
                  issuedAt: "")
    }
}

extension Product: Decodable {
    private enum DecodingKeys: String, CodingKey {
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
        let container = try decoder.container(keyedBy: DecodingKeys.self)
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

extension Product: Encodable {
    private enum EncodingKeys: String, CodingKey {
        case name, description
        case thumbnailID = "thumbnail_id"
        case price, currency
        case discountedPrice = "discounted_price"
        case stock, secret
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: EncodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(description, forKey: .description)
        try container.encodeIfPresent(thumbnailId, forKey: .thumbnailID)
        try container.encode(price, forKey: .price)
        try container.encode(currency, forKey: .currency)
        try container.encode(discountedPrice, forKey: .discountedPrice)
        try container.encode(stock, forKey: .stock)
        try container.encode(Secrets.password, forKey: .secret)
    }
}
