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
    func test_checkHealth_호출시_서버에서_200코드를보내면_에러를_반환하지않는지() async {
        // given
        stubURLSession.data = Data()
        stubURLSession.response = HTTPURLResponse(url: URL(string: "https://test.com")!,
                                                  statusCode: 200,
                                                  httpVersion: nil,
                                                  headerFields: nil)

        // when
        do {
            // then
            _ = try await sut.checkHealth()
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func test_checkHealth_호출시_서버에서_500코드를보내면_badStatus에러를_반환하는지() async {
        // given
        stubURLSession.data = Data()
        stubURLSession.response = HTTPURLResponse(url: URL(string: "https://test.com")!,
                                                  statusCode: 500,
                                                  httpVersion: nil,
                                                  headerFields: nil)

        // when
        do {
            _ = try await sut.checkHealth()
            XCTFail("Should return failure")
        } catch let error as OpenMarketError {
            if case .badStatus = error {
                // then
                XCTAssert(true)
            } else {
                XCTFail("Should return OpenMarketError.badStatus")
            }
        } catch {
            XCTFail("Should return OpenMarketError.badStatus")
        }
    }
}

// MARK: - fetchPage

extension OpenMarketAPIClientTests {
    func test_정상적인상황에서_fetchPage_호출시_제대로_동작하는지() async {
        // given
        stubURLSession.data = TestData.validPageData
        stubURLSession.response = HTTPURLResponse(url: URL(string: "https://test.com")!,
                                                  statusCode: 200,
                                                  httpVersion: nil,
                                                  headerFields: nil)

        // when
        do {
            let page = try await sut.fetchPage(pageNumber: 1, productsPerPage: 3)
            // then
            XCTAssertEqual(page.pageNumber, 1)
            XCTAssertEqual(page.products.count, 3)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func test_fetchPage_호출시_서버에서_404코드를보내면_badStatus에러를_반환하는지() async {
        // given
        stubURLSession.data = nil
        stubURLSession.response = HTTPURLResponse(url: URL(string: "https://test.com")!,
                                                  statusCode: 404,
                                                  httpVersion: nil,
                                                  headerFields: nil)

        // when
        do {
            _ = try await sut.fetchPage(pageNumber: 1, productsPerPage: 3)
            XCTFail("Should return failure")
        } catch let error as OpenMarketError {
            if case .badStatus = error {
                // then
                XCTAssert(true)
            } else {
                XCTFail("Should return OpenMarketError.badStatus")
            }
        } catch {
            XCTFail("Should return OpenMarketError.badStatus")
        }
    }
}

// MARK: - fetchProductDetail

extension OpenMarketAPIClientTests {
    func test_정상적인상황에서_fetchProductDetail_호출시_제대로_동작하는지() async {
        // given
        stubURLSession.data = TestData.validProductDetailData
        stubURLSession.response = HTTPURLResponse(url: URL(string: "https://test.com")!,
                                                  statusCode: 200,
                                                  httpVersion: nil,
                                                  headerFields: nil)

        // when
        do {
            let product = try await sut.fetchProductDetail(productID: 1944)
            // then
            XCTAssertEqual(product.id, 1944)
            XCTAssertEqual(product.stock, 2)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func test_fetchProductDetail_호출시_서버에서_404코드를보내면_badStatus에러를_반환하는지() async {
        // given
        stubURLSession.data = nil
        stubURLSession.response = HTTPURLResponse(url: URL(string: "https://test.com")!,
                                                  statusCode: 404,
                                                  httpVersion: nil,
                                                  headerFields: nil)

        // when
        do {
            _ = try await sut.fetchProductDetail(productID: 1944)
            XCTFail("Should return failure")
        } catch let error as OpenMarketError {
            if case .badStatus = error {
                // then
                XCTAssert(true)
            } else {
                XCTFail("Should return OpenMarketError.badStatus")
            }
        } catch {
            XCTFail("Should return OpenMarketError.badStatus")
        }
    }
}

// MARK: - createProduct

extension OpenMarketAPIClientTests {
    func test_정상적인상황에서_createProduct_호출시_제대로_동작하는지() async {
        // given
        stubURLSession.data = TestData.validProductDetailData
        stubURLSession.response = HTTPURLResponse(url: URL(string: "https://test.com")!,
                                                  statusCode: 201,
                                                  httpVersion: nil,
                                                  headerFields: nil)
        let product = try! JSONDecoder().decode(Product.self, from: TestData.validProductDetailData)
        let images = [UIImage.add, UIImage.remove]

        // when
        do {
            let createdProduct = try await sut.createProduct(product: product, images: images)
            // then
            XCTAssertEqual(createdProduct.name, product.name)
            XCTAssertEqual(createdProduct.price, product.price)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func test_createProduct_호출시_서버에서_400코드를보내면_badStatus에러를_반환하는지() async {
        // given
        stubURLSession.data = nil
        stubURLSession.response = HTTPURLResponse(url: URL(string: "https://test.com")!,
                                                  statusCode: 400,
                                                  httpVersion: nil,
                                                  headerFields: nil)
        let product = try! JSONDecoder().decode(Product.self, from: TestData.validProductDetailData)
        let images = [UIImage.add, UIImage.remove]

        // when
        do {
            _ = try await sut.createProduct(product: product, images: images)
            XCTFail("Should return failure")
        } catch let error as OpenMarketError {
            if case .badStatus = error {
                // then
                XCTAssert(true)
            } else {
                XCTFail("Should return OpenMarketError.badStatus")
            }
        } catch {
            XCTFail("Should return OpenMarketError.badStatus")
        }
    }
}

// MARK: - updateProduct

extension OpenMarketAPIClientTests {
    func test_정상적인상황에서_updateProduct_호출시_제대로_동작하는지() async {
        // given
        stubURLSession.data = TestData.validProductDetailData
        stubURLSession.response = HTTPURLResponse(url: URL(string: "https://test.com")!,
                                                  statusCode: 200,
                                                  httpVersion: nil,
                                                  headerFields: nil)
        var product = try! JSONDecoder().decode(Product.self, from: TestData.validProductDetailData)
        product.thumbnailId = 2

        // when
        do {
            let updatedProduct = try await sut.updateProduct(product: product)
            // then
            XCTAssertEqual(updatedProduct.name, product.name)
            XCTAssertEqual(updatedProduct.price, product.price)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func test_updateProduct_호출시_서버에서_400코드를보내면_badStatus에러를_반환하는지() async {
        // given
        stubURLSession.data = nil
        stubURLSession.response = HTTPURLResponse(url: URL(string: "https://test.com")!,
                                                  statusCode: 400,
                                                  httpVersion: nil,
                                                  headerFields: nil)
        var product = try! JSONDecoder().decode(Product.self, from: TestData.validProductDetailData)
        product.thumbnailId = 2

        // when
        do {
            _ = try await sut.updateProduct(product: product)
            XCTFail("Should return failure")
        } catch let error as OpenMarketError {
            if case .badStatus = error {
                // then
                XCTAssert(true)
            } else {
                XCTFail("Should return OpenMarketError.badStatus")
            }
        } catch {
            XCTFail("Should return OpenMarketError.badStatus")
        }
    }

    func test_정상적인상황에서_deleteProduct_호출시_제대로_동작하는지() async {
        // given
        stubURLSession.data = "test".data(using: .utf8)
        stubURLSession.response = HTTPURLResponse(url: URL(string: "https://test.com")!,
                                                  statusCode: 204,
                                                  httpVersion: nil,
                                                  headerFields: nil)

        // when
        do {
            _ = try await sut.deleteProduct(productID: 1944, password: Secrets.password)
            // then
            XCTAssert(true)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func test_deleteProduct_호출시_서버에서_500코드를보내면_badStatus에러를_반환하는지() async {
        // given
        stubURLSession.response = HTTPURLResponse(url: URL(string: "https://test.com")!,
                                                  statusCode: 500,
                                                  httpVersion: nil,
                                                  headerFields: nil)

        // when
        do {
            _ = try await sut.deleteProduct(productID: 1944, password: Secrets.password)
            XCTFail("Should return failure")
        } catch let error as OpenMarketError {
            if case .badStatus = error {
                // then
                XCTAssert(true)
            } else {
                XCTFail("Should return OpenMarketError.badStatus")
            }
        } catch {
            XCTFail("Should return OpenMarketError.badStatus")
        }
    }
}
// swiftlint:enable force_try
