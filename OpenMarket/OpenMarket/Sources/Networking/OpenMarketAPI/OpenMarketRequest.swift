import Foundation

enum OpenMarketRequest: Requestable {
    case checkHealth
    case fetchPage(pageNumber: Int, productsPerPage: Int)
    case fetchProductDetail(productID: Product.ID)

    var baseURL: URL {
        return Foundation.URL(string: "https://openmarket.yagom-academy.kr")!
    }

    var path: String {
        switch self {
        case .checkHealth:
            return "/healthChecker"
        case .fetchPage(let pageNumber, let productsPerPage):
            return "/api/products?page_no=\(pageNumber)&items_per_page=\(productsPerPage)"
        case .fetchProductDetail(let productID):
            return "/api/products/\(productID)"
        }
    }

    var httpMethod: HttpMethod {
        switch self {
        case .checkHealth:
            return .get
        case .fetchPage:
            return .get
        case .fetchProductDetail:
            return .get
        }

    }

    var headers: [HeaderField: HeaderValue]? {
        switch self {
        case .checkHealth:
            return nil
        case .fetchPage:
            return nil
        case .fetchProductDetail:
            return nil
        }
    }

    var httpBody: Data? {
        switch self {
        case .checkHealth:
            return nil
        case .fetchPage:
            return nil
        case .fetchProductDetail:
            return nil
        }
    }
}
