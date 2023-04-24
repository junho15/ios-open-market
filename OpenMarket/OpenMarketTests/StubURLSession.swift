import Foundation
@testable import OpenMarket

class StubURLSession: URLSessionProtocol {
    var data: Data?
    var error: Error?
    var response: URLResponse?
    var delay: TimeInterval = 0.5

    func execute(request: OpenMarket.Requestable) async throws -> Data {
        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        guard request.urlRequest != nil else {
            throw OpenMarketError.invalidRequest
        }
        if let error {
            throw OpenMarketError.networkError(error: error)
        }
        guard let response = response as? HTTPURLResponse,
              (200...299).contains(response.statusCode) else {
            throw OpenMarketError.badStatus
        }
        guard let data else {
            throw OpenMarketError.emptyData
        }
        return data
    }

    func execute(url: URL) async throws -> Data {
        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        if let error {
            throw OpenMarketError.networkError(error: error)
        }
        guard let response = response as? HTTPURLResponse,
              (200...299).contains(response.statusCode) else {
            throw OpenMarketError.badStatus
        }
        guard let data else {
            throw OpenMarketError.emptyData
        }
        return data
    }
}
