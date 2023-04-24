import Foundation
@testable import OpenMarket

final class SpyURLSession: StubURLSession {
    private(set) var executeCallCount = 0

    override func execute(request: Requestable) async throws -> Data {
        executeCallCount += 1
        return try await super.execute(request: request)
    }

    override func execute(url: URL) async throws -> Data {
        executeCallCount += 1
        return try await super.execute(url: url)
    }

    override func execute(request: Requestable, completion: @escaping (Result<Data, OpenMarketError>) -> Void) {
        executeCallCount += 1
        super.execute(request: request, completion: completion)
    }

    override func execute(url: URL, completion: @escaping (Result<Data, OpenMarketError>) -> Void) {
        executeCallCount += 1
        super.execute(url: url, completion: completion)
    }
}
