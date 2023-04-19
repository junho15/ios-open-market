import Foundation
@testable import OpenMarket

final class SpyURLSession: StubURLSession {
    private(set) var executeCallCount = 0

    override func execute(request: Requestable, completion: @escaping (Result<Data, OpenMarketError>) -> Void) {
        executeCallCount += 1
        super.execute(request: request, completion: completion)
    }

    override func execute(url: URL, completion: @escaping (Result<Data, OpenMarketError>) -> Void) {
        executeCallCount += 1
        super.execute(url: url, completion: completion)
    }
}
