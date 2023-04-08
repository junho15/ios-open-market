import UIKit

enum OpenMarketRequest: Requestable {
    case checkHealth
    case fetchPage(pageNumber: Int, productsPerPage: Int)
    case fetchProductDetail(productID: Product.ID)
    case createProduct(identifier: String, product: Product, images: [Data], boundary: String = UUID().uuidString)

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
        case .createProduct:
            return "/api/products"
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
        case .createProduct:
            return .post
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
        case .createProduct(let identifier, _, _, let boundary):
            return ["identifier": identifier,
                    "Content-Type": "multipart/form-data; boundary=\(boundary)"]
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
        case .createProduct(_, let product, let images, let boundary):
            return createHttpBodyToCreateProduct(product: product, images: images, boundary: boundary)
        }
    }

    private func createHttpBodyToCreateProduct(product: Product, images: [Data], boundary: String) -> Data? {
        var body = Data()
        switch JSONEncoder().encode(from: product) {
        case .success(let productData):
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"params\"\r\n\r\n")
            body.append(productData)
            body.append("\r\n")
        case .failure(let error):
            print(error.localizedDescription)
            return nil
        }
        let mimetype = "image/jpeg"
        images.forEach { imageData in
            let filename = "\(UUID().uuidString).jpg"
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"images\"; filename=\"\(filename)\"\r\n")
            body.append("Content-Type: \(mimetype)\r\n\r\n")
            body.append(imageData)
            body.append("\r\n")
        }
        body.append("--\(boundary)--")
        return body
    }
}
