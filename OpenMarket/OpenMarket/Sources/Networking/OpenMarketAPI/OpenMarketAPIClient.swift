import UIKit

final class OpenMarketAPIClient {
    private let session: URLSessionProtocol

    init(session: URLSessionProtocol = URLSession.shared) {
        self.session = session
    }

    func checkHealth() async throws {
        let checkHealthRequest = OpenMarketRequest.checkHealth
        _ = try await session.execute(request: checkHealthRequest)
    }

    func fetchPage(pageNumber: Int, productsPerPage: Int) async throws -> Page {
        let fetchPageRequest = OpenMarketRequest.fetchPage(pageNumber: pageNumber, productsPerPage: productsPerPage)
        let data = try await session.execute(request: fetchPageRequest)
        switch JSONDecoder().decode(data, to: Page.self) {
        case .success(let page):
            return page
        case .failure:
            throw OpenMarketError.decodingError
        }
    }

    func fetchProductDetail(productID: Product.ID) async throws -> Product {
        let fetchProductDetailRequest = OpenMarketRequest.fetchProductDetail(productID: productID)
        let data = try await session.execute(request: fetchProductDetailRequest)
        switch JSONDecoder().decode(data, to: Product.self) {
        case .success(let product):
            return product
        case .failure:
            throw OpenMarketError.decodingError
        }
    }

    func createProduct(product: Product, images: [UIImage]) async throws -> Product {
        let images: [Data] = images.compactMap { image in
            return image.jpegData(compressionQuality: 1.0)
        }
        let createProductRequest = OpenMarketRequest.createProduct(identifier: Secrets.identifier,
                                                                   product: product,
                                                                   images: images)
        let data = try await session.execute(request: createProductRequest)
        switch JSONDecoder().decode(data, to: Product.self) {
        case .success(let product):
            return product
        case .failure:
            throw OpenMarketError.decodingError
        }
    }

    func updateProduct(product: Product) async throws -> Product {
        let updateProductRequest = OpenMarketRequest.updateProduct(identifier: Secrets.identifier,
                                                                   product: product)
        let data = try await session.execute(request: updateProductRequest)
        switch JSONDecoder().decode(data, to: Product.self) {
        case .success(let product):
            return product
        case .failure:
            throw OpenMarketError.decodingError
        }
    }

    func deleteProduct(productID: Product.ID, password: String) async throws {
        let fetchProductDeleteURIRequest = OpenMarketRequest.fetchProductDeleteURI(identifier: Secrets.identifier,
                                                                                   password: password,
                                                                                   productID: productID)
        let URIData = try await session.execute(request: fetchProductDeleteURIRequest)
        guard let URI = String(data: URIData, encoding: .utf8) else {
            throw OpenMarketError.decodingError
        }
        let deleteProductRequest = OpenMarketRequest.deleteProduct(identifier: Secrets.identifier, URI: URI)
        _ = try await session.execute(request: deleteProductRequest)
    }
}
