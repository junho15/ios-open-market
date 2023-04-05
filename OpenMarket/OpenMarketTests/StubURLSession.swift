import Foundation
@testable import OpenMarket

class StubURLSession: URLSessionProtocol {
    var data: Data?
    var error: Error?
    var response: URLResponse?
    var delay: TimeInterval = 0.5

    func execute(request: OpenMarket.Requestable, completion: @escaping (Result<Data, Error>) -> Void) {
        guard request.urlRequest != nil else {
            completion(.failure(OpenMarketError.invalidRequest))
            return
        }

        DispatchQueue.global().asyncAfter(deadline: .now() + delay) { [weak self] in
            guard let self else { return }
            if let error {
                completion(.failure(OpenMarketError.networkError(error: error)))
                return
            }
            guard let response = response as? HTTPURLResponse,
                  (200...299).contains(response.statusCode) else {
                completion(.failure(OpenMarketError.badStatus))
                return
            }
            guard let data else {
                completion(.failure(OpenMarketError.emptyData))
                return
            }
            completion(.success(data))
        }
    }

    func execute(url: URL, completion: @escaping (Result<Data, Error>) -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + delay) { [weak self] in
            guard let self else { return }
            if let error {
                completion(.failure(OpenMarketError.networkError(error: error)))
                return
            }
            guard let response = response as? HTTPURLResponse,
                  (200...299).contains(response.statusCode) else {
                completion(.failure(OpenMarketError.badStatus))
                return
            }
            guard let data else {
                completion(.failure(OpenMarketError.emptyData))
                return
            }
            completion(.success(data))
        }
    }
}
