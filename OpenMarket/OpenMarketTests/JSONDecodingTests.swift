import XCTest
@testable import OpenMarket

final class JSONDecodingTests: XCTestCase {
    func test_유효한_PageJSON데이터를_올바르게디코딩하는지() throws {
        // given
        let data = TestData.validPageData

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

    func test_유효하지않은_PageJSON데이터를_디코딩하면_에러를반환하는지() {
        // given
        let data = TestData.invalidPageData

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

    func test_유효한_ProductDetailJSON데이터를_올바르게디코딩하는지() throws {
        // given
        let data = TestData.validProductDetailData

        // when
        let result = JSONDecoder().decode(data, to: Product.self)

        // then
        switch result {
        case .success(let product):
            XCTAssertEqual(product.id, 1944)
            XCTAssertEqual(product.stock, 2)
        case .failure(let error):
            XCTFail(error.localizedDescription)
        }
    }

    func test_유효하지않은_ProductDetailJSON데이터를_디코딩하면_에러를반환하는지() {
        // given
        let data = TestData.invalidProductDetailData

        // when
        let result = JSONDecoder().decode(data, to: Product.self)

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
