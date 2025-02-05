import Foundation

protocol URLSessionProtocol {
    func execute(request: Requestable) async throws -> Data
    func execute(url: URL) async throws -> Data
}

extension URLSession: URLSessionProtocol {
    func execute(request: Requestable) async throws -> Data {
        guard let urlRequest = request.urlRequest else {
            throw OpenMarketError.invalidRequest
        }
        if #available(iOS 15.0, *) {
            let (data, response) = try await self.data(for: urlRequest)
            guard let response = response as? HTTPURLResponse,
                  (200...299).contains(response.statusCode) else {
                throw OpenMarketError.badStatus
            }
            return data
        } else {
            return try await withCheckedThrowingContinuation { continuation in
                self.dataTask(with: urlRequest) { data, response, error in
                    if let error {
                        continuation.resume(throwing: OpenMarketError.networkError(error: error))
                        return
                    }
                    guard let response = response as? HTTPURLResponse,
                          (200...299).contains(response.statusCode) else {
                        continuation.resume(throwing: OpenMarketError.badStatus)
                        return
                    }
                    guard let data else {
                        continuation.resume(throwing: OpenMarketError.emptyData)
                        return
                    }
                    continuation.resume(returning: data)
                }.resume()
            }
        }
    }

    func execute(url: URL) async throws -> Data {
        if #available(iOS 15.0, *) {
            let (data, response) = try await self.data(from: url)
            guard let response = response as? HTTPURLResponse,
                  (200...299).contains(response.statusCode) else {
                throw OpenMarketError.badStatus
            }
            return data
        } else {
            return try await withCheckedThrowingContinuation { continuation in
                self.dataTask(with: url) {data, response, error in
                    if let error {
                        continuation.resume(throwing: OpenMarketError.networkError(error: error))
                        return
                    }
                    guard let response = response as? HTTPURLResponse,
                          (200...299).contains(response.statusCode) else {
                        continuation.resume(throwing: OpenMarketError.badStatus)
                        return
                    }
                    guard let data else {
                        continuation.resume(throwing: OpenMarketError.emptyData)
                        return
                    }
                    continuation.resume(returning: data)
                }.resume()
            }
        }
    }
}
