struct Page {
    let pageNumber: Int
    let productCountPerPage: Int
    let totalProductCount: Int
    let offset: Int
    let limit: Int
    let lastPageNumber: Int
    let hasNextPage: Bool
    let hasPreviousPage: Bool
    let products: [Product]
}

extension Page: Decodable {
    enum CodingKeys: String, CodingKey {
        case pageNumber = "pageNo"
        case productCountPerPage = "itemsPerPage"
        case totalProductCount = "totalCount"
        case offset
        case limit
        case lastPageNumber = "lastPage"
        case hasNextPage = "hasNext"
        case hasPreviousPage = "hasPrev"
        case products = "pages"
    }
}
