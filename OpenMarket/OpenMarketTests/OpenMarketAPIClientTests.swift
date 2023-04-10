import XCTest
@testable import OpenMarket

// swiftlint:disable force_try
final class OpenMarketAPIClientTests: XCTestCase {
    var sut: OpenMarketAPIClient!
    var stubURLSession: StubURLSession!

    override func setUpWithError() throws {
        try super.setUpWithError()
        stubURLSession = StubURLSession()
        stubURLSession.delay = 0.5
        sut = OpenMarketAPIClient(session: stubURLSession)
    }

    override func tearDownWithError() throws {
        sut = nil
        stubURLSession = nil
        try super.tearDownWithError()
    }
}

// MARK: - checkHealth

extension OpenMarketAPIClientTests {
    func test_checkHealth_호출시_서버에서_200코드를보내면_sucess를_반환하는지() {
        // given
        stubURLSession.data = Data()
        stubURLSession.response = HTTPURLResponse(url: URL(string: "https://test.com")!,
                                                  statusCode: 200,
                                                  httpVersion: nil,
                                                  headerFields: nil)
        let expectation = self.expectation(description: "checkHealth Complete")

        // when
        sut.checkHealth { result in
            // then
            switch result {
            case .success:
                XCTAssert(true)
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0) { error in
            if let error {
                XCTFail(error.localizedDescription)
            }
        }
    }

    func test_checkHealth_호출시_서버에서_500코드를보내면_badStatus에러를_반환하는지() {
        // given
        stubURLSession.data = Data()
        stubURLSession.response = HTTPURLResponse(url: URL(string: "https://test.com")!,
                                                  statusCode: 500,
                                                  httpVersion: nil,
                                                  headerFields: nil)
        let expectation = self.expectation(description: "checkHealth Complete")

        // when
        sut.checkHealth { result in
            // then
            switch result {
            case .success:
                XCTFail("Should return failure")
            case .failure(let error):
                if let error = error as? OpenMarketError,
                   case .badStatus = error {
                    XCTAssert(true)
                } else {
                    XCTFail("Should return OpenMarketError.badStatus")
                }
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0) { error in
            if let error {
                XCTFail(error.localizedDescription)
            }
        }
    }
}

// MARK: - fetchPage

extension OpenMarketAPIClientTests {
    func test_정상적인상황에서_fetchPage_호출시_sucess를_반환하는지() {
        // given
        stubURLSession.data = TestData.validPageData
        stubURLSession.response = HTTPURLResponse(url: URL(string: "https://test.com")!,
                                                  statusCode: 200,
                                                  httpVersion: nil,
                                                  headerFields: nil)
        let expectation = self.expectation(description: "fetchPage Complete")

        // when
        sut.fetchPage(pageNumber: 1, productsPerPage: 3) { result in
            // then
            switch result {
            case .success(let page):
                XCTAssertEqual(page.pageNumber, 1)
                XCTAssertEqual(page.products.count, 3)
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0) { error in
            if let error {
                XCTFail(error.localizedDescription)
            }
        }
    }

    func test_fetchPage_호출시_서버에서_404코드를보내면_badStatus에러를_반환하는지() {
        // given
        stubURLSession.data = nil
        stubURLSession.response = HTTPURLResponse(url: URL(string: "https://test.com")!,
                                                  statusCode: 404,
                                                  httpVersion: nil,
                                                  headerFields: nil)
        let expectation = self.expectation(description: "fetchPage Complete")

        // when
        sut.fetchPage(pageNumber: 1, productsPerPage: 3) { result in
            // then
            switch result {
            case .success:
                XCTFail("Should return failure")
            case .failure(let error):
                if let error = error as? OpenMarketError,
                   case .badStatus = error {
                    XCTAssert(true)
                } else {
                    XCTFail("Should return OpenMarketError.badStatus")
                }
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0) { error in
            if let error {
                XCTFail(error.localizedDescription)
            }
        }
    }
}

// MARK: - fetchProductDetail

extension OpenMarketAPIClientTests {
    func test_정상적인상황에서_fetchProductDetail_호출시_sucess를_반환하는지() {
        // given
        stubURLSession.data = TestData.validProductDetailData
        stubURLSession.response = HTTPURLResponse(url: URL(string: "https://test.com")!,
                                                  statusCode: 200,
                                                  httpVersion: nil,
                                                  headerFields: nil)
        let expectation = self.expectation(description: "fetchProductDetail Complete")

        // when
        sut.fetchProductDetail(productID: 1944) { result in
            // then
            switch result {
            case .success(let product):
                XCTAssertEqual(product.id, 1944)
                XCTAssertEqual(product.stock, 2)
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0) { error in
            if let error {
                XCTFail(error.localizedDescription)
            }
        }
    }

    func test_fetchProductDetail_호출시_서버에서_404코드를보내면_badStatus에러를_반환하는지() {
        // given
        stubURLSession.data = nil
        stubURLSession.response = HTTPURLResponse(url: URL(string: "https://test.com")!,
                                                  statusCode: 404,
                                                  httpVersion: nil,
                                                  headerFields: nil)
        let expectation = self.expectation(description: "fetchProductDetail Complete")

        // when
        sut.fetchProductDetail(productID: 1944) { result in
            // then
            switch result {
            case .success:
                XCTFail("Should return failure")
            case .failure(let error):
                if let error = error as? OpenMarketError,
                   case .badStatus = error {
                    XCTAssert(true)
                } else {
                    XCTFail("Should return OpenMarketError.badStatus")
                }
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0) { error in
            if let error {
                XCTFail(error.localizedDescription)
            }
        }
    }
}

// MARK: - createProduct

extension OpenMarketAPIClientTests {
    func test_정상적인상황에서_createProduct_호출시_sucess를_반환하는지() {
        // given
        stubURLSession.data = TestData.validProductDetailData
        stubURLSession.response = HTTPURLResponse(url: URL(string: "https://test.com")!,
                                                  statusCode: 201,
                                                  httpVersion: nil,
                                                  headerFields: nil)
        let expectation = self.expectation(description: "createProduct Complete")
        let product = try! JSONDecoder().decode(Product.self, from: TestData.validProductDetailData)
        let images = [UIImage.add, UIImage.remove]

        // when
        sut.createProduct(product: product, images: images) { result in
            // then
            switch result {
            case .success(let createdProduct):
                XCTAssertEqual(createdProduct.name, product.name)
                XCTAssertEqual(createdProduct.price, product.price)
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.0) { error in
            if let error {
                XCTFail(error.localizedDescription)
            }
        }
    }

    func test_createProduct_호출시_서버에서_400코드를보내면_badStatus에러를_반환하는지() {
        // given
        stubURLSession.data = nil
        stubURLSession.response = HTTPURLResponse(url: URL(string: "https://test.com")!,
                                                  statusCode: 400,
                                                  httpVersion: nil,
                                                  headerFields: nil)
        let expectation = self.expectation(description: "createProduct Complete")
        let product = try! JSONDecoder().decode(Product.self, from: TestData.validProductDetailData)
        let images = [UIImage.add, UIImage.remove]

        // when
        sut.createProduct(product: product, images: images) { result in
            // then
            switch result {
            case .success:
                XCTFail("Should return failure")
            case .failure(let error):
                if let error = error as? OpenMarketError,
                   case .badStatus = error {
                    XCTAssert(true)
                } else {
                    XCTFail("Should return OpenMarketError.badStatus")
                }
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0) { error in
            if let error {
                XCTFail(error.localizedDescription)
            }
        }
    }
}

// MARK: - updateProduct

extension OpenMarketAPIClientTests {
    func test_정상적인상황에서_updateProduct_호출시_sucess를_반환하는지() {
        // given
        stubURLSession.data = TestData.validProductDetailData
        stubURLSession.response = HTTPURLResponse(url: URL(string: "https://test.com")!,
                                                  statusCode: 200,
                                                  httpVersion: nil,
                                                  headerFields: nil)
        let expectation = self.expectation(description: "updateProduct Complete")
        var product = try! JSONDecoder().decode(Product.self, from: TestData.validProductDetailData)
        product.thumbnailId = 2

        // when
        sut.updateProduct(product: product) { result in
            // then
            switch result {
            case .success(let updatedProduct):
                XCTAssertEqual(updatedProduct.name, product.name)
                XCTAssertEqual(updatedProduct.price, product.price)
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.0) { error in
            if let error {
                XCTFail(error.localizedDescription)
            }
        }
    }

    func test_updateProduct_호출시_서버에서_400코드를보내면_badStatus에러를_반환하는지() {
        // given
        stubURLSession.data = nil
        stubURLSession.response = HTTPURLResponse(url: URL(string: "https://test.com")!,
                                                  statusCode: 400,
                                                  httpVersion: nil,
                                                  headerFields: nil)
        let expectation = self.expectation(description: "updateProduct Complete")
        var product = try! JSONDecoder().decode(Product.self, from: TestData.validProductDetailData)
        product.thumbnailId = 2

        // when
        sut.updateProduct(product: product) { result in
            // then
            switch result {
            case .success:
                XCTFail("Should return failure")
            case .failure(let error):
                if let error = error as? OpenMarketError,
                   case .badStatus = error {
                    XCTAssert(true)
                } else {
                    XCTFail("Should return OpenMarketError.badStatus")
                }
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0) { error in
            if let error {
                XCTFail(error.localizedDescription)
            }
        }
    }
}
// swiftlint:enable force_try
