import Foundation

final class OpenMarketAPIClient {
    private let session: URLSessionProtocol

    init(session: URLSessionProtocol = URLSession.shared) {
        self.session = session
    }

    func checkHealth(completion: @escaping (Result<Void, Error>) -> Void) {
        let checkHealthRequest = OpenMarketRequest.checkHealth
        session.execute(request: checkHealthRequest) { result in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func fetchPage(pageNumber: Int, productsPerPage: Int, completion: @escaping (Result<Page, Error>) -> Void) {
        let fetchPageRequest = OpenMarketRequest.fetchPage(pageNumber: pageNumber, productsPerPage: productsPerPage)
        session.execute(request: fetchPageRequest) { result in
            switch result {
            case .success(let data):
                switch JSONDecoder().decode(data, to: Page.self) {
                case .success(let page):
                    completion(.success(page))
                case .failure(let error):
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func fetchProductDetail(productID: Product.ID, completion: @escaping (Result<Product, Error>) -> Void) {
        let fetchProductDetailRequest = OpenMarketRequest.fetchProductDetail(productID: productID)
        session.execute(request: fetchProductDetailRequest) { result in
            switch result {
            case .success(let data):
                switch JSONDecoder().decode(data, to: Product.self) {
                case .success(let products):
                    completion(.success(products))
                case .failure(let error):
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
