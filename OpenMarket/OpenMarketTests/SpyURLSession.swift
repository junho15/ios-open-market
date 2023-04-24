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
}
