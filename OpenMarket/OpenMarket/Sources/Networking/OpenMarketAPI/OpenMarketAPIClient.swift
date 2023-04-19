import UIKit

final class OpenMarketAPIClient {
    private let session: URLSessionProtocol

    init(session: URLSessionProtocol = URLSession.shared) {
        self.session = session
    }

    func checkHealth(completion: @escaping (Result<Void, OpenMarketError>) -> Void) {
        let checkHealthRequest = OpenMarketRequest.checkHealth
        session.execute(request: checkHealthRequest) { result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    completion(.success(()))
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }

    func fetchPage(pageNumber: Int,
                   productsPerPage: Int,
                   completion: @escaping (Result<Page, OpenMarketError>) -> Void) {
        let fetchPageRequest = OpenMarketRequest.fetchPage(pageNumber: pageNumber, productsPerPage: productsPerPage)
        session.execute(request: fetchPageRequest) { result in
            switch result {
            case .success(let data):
                switch JSONDecoder().decode(data, to: Page.self) {
                case .success(let page):
                    DispatchQueue.main.async {
                        completion(.success(page))
                    }
                case .failure:
                    DispatchQueue.main.async {
                        completion(.failure(.decodingError))
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }

    func fetchProductDetail(productID: Product.ID, completion: @escaping (Result<Product, OpenMarketError>) -> Void) {
        let fetchProductDetailRequest = OpenMarketRequest.fetchProductDetail(productID: productID)
        session.execute(request: fetchProductDetailRequest) { result in
            switch result {
            case .success(let data):
                switch JSONDecoder().decode(data, to: Product.self) {
                case .success(let product):
                    DispatchQueue.main.async {
                        completion(.success(product))
                    }
                case .failure:
                    DispatchQueue.main.async {
                        completion(.failure(.decodingError))
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }

    func createProduct(product: Product,
                       images: [UIImage],
                       completion: @escaping (Result<Product, OpenMarketError>) -> Void) {
        let images: [Data] = images.compactMap { image in
            return image.jpegData(compressionQuality: 1.0)
        }
        let createProductRequest = OpenMarketRequest.createProduct(identifier: Secrets.identifier,
                                                                   product: product,
                                                                   images: images)
        session.execute(request: createProductRequest) { result in
            switch result {
            case .success(let data):
                switch JSONDecoder().decode(data, to: Product.self) {
                case .success(let product):
                    DispatchQueue.main.async {
                        completion(.success(product))
                    }
                case .failure:
                    DispatchQueue.main.async {
                        completion(.failure(.decodingError))
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }

    func updateProduct(product: Product, completion: @escaping (Result<Product, OpenMarketError>) -> Void) {
        let updateProductRequest = OpenMarketRequest.updateProduct(identifier: Secrets.identifier,
                                                                   product: product)
        session.execute(request: updateProductRequest) { result in
            switch result {
            case .success(let data):
                switch JSONDecoder().decode(data, to: Product.self) {
                case .success(let product):
                    DispatchQueue.main.async {
                        completion(.success(product))
                    }
                case .failure:
                    DispatchQueue.main.async {
                        completion(.failure(.decodingError))
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }

    func deleteProduct(productID: Product.ID,
                       password: String,
                       completion: @escaping (Result<Void, OpenMarketError>) -> Void) {
        let fetchProductDeleteURIRequest = OpenMarketRequest.fetchProductDeleteURI(identifier: Secrets.identifier,
                                                                                   password: password,
                                                                                   productID: productID)
        session.execute(request: fetchProductDeleteURIRequest) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let URIData):
                guard let URI = String(data: URIData, encoding: .utf8) else {
                    DispatchQueue.main.async {
                        completion(.failure(OpenMarketError.decodingError))
                    }
                    return
                }
                let deleteProductRequest = OpenMarketRequest.deleteProduct(identifier: Secrets.identifier, URI: URI)
                session.execute(request: deleteProductRequest) { result in
                    switch result {
                    case .success:
                        DispatchQueue.main.async {
                            completion(.success(()))
                        }
                    case .failure(let error):
                        DispatchQueue.main.async {
                            completion(.failure(error))
                        }
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
}
