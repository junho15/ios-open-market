import XCTest
@testable import OpenMarket

final class JSONDecodingTests: XCTestCase {
    func test_유효한JSON데이터를_올바르게디코딩하는지() throws {
        // given
        let data = TestData.validData

        // when
        let result = JSONDecoder().decode(data, to: Page.self)

        // then
        switch result {
        case .success(let page):
            XCTAssertEqual(page.pageNumber, 1)
            XCTAssertEqual(page.products[0].id, 1944)
            XCTAssertEqual(page.products[0].currency, .KRW)
        case .failure(let error):
            XCTFail(error.localizedDescription)
        }
    }

    func test_유효하지않은JSON데이터를_디코딩하면_에러를반환하는지() {
        // given
        let data = TestData.invalidData

        // when, then
        XCTAssertThrowsError(try JSONDecoder().decode(Page.self, from: data))

        // when
        let result = JSONDecoder().decode(data, to: Page.self)

        // then
        switch result {
        case .success:
            XCTFail("디코딩은 실패해야 합니다.")
        case .failure(let error):
            if let error = error as? OpenMarketError,
               case .decodingError = error {
                XCTAssert(true)
            } else {
                XCTFail("OpenMarketError.decodingError가 아닙니다.")
            }
        }
    }
}
