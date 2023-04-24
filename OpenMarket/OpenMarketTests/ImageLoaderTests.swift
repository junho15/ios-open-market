import XCTest
@testable import OpenMarket

final class ImageLoaderTests: XCTestCase {
    var sut: ImageLoader!
    var spyURLSession: SpyURLSession!
    var imageCache: ImageCache!

    override func setUpWithError() throws {
        try super.setUpWithError()
        spyURLSession = SpyURLSession()
        imageCache = ImageCache()
        sut = ImageLoader(session: spyURLSession, imageCache: imageCache)
    }

    override func tearDownWithError() throws {
        sut = nil
        spyURLSession = nil
        imageCache = nil
        try super.tearDownWithError()
    }

    func test_정상적인상황에서_imageLoad_호출시_sucess를_반환하는지() async {
        // given
        let imageURL = URL(string: "https://test.com/image.jpg")!
        spyURLSession.data = UIImage.add.jpegData(compressionQuality: 1.0)!
        spyURLSession.response = HTTPURLResponse(url: imageURL,
                                                 statusCode: 200,
                                                 httpVersion: nil,
                                                 headerFields: nil)

        // when
        let resultImage = try? await sut.loadImage(from: imageURL)

        // then
        XCTAssertNotNil(resultImage)
    }

    func test_imageLoad_호출시_에러가_발생하면_error를_반환하는지() async {
        // given
        let imageURL = URL(string: "https://test.com/image.jpg")!
        spyURLSession.data = UIImage.add.jpegData(compressionQuality: 1.0)!
        spyURLSession.response = HTTPURLResponse(url: imageURL,
                                                 statusCode: 500,
                                                 httpVersion: nil,
                                                 headerFields: nil)

        // when
        do {
            _ = try await sut.loadImage(from: imageURL)
            XCTFail("Should return failure")
        } catch {
            // then
            XCTAssertTrue(error is OpenMarketError)
        }
    }

    func test_캐싱된_이미지가_있으면_캐싱된_이미지를_반환하고_네트워크에서_Load하지않는지() async throws {
        // given
        let imageURL = URL(string: "https://test.com/image.jpg")!
        spyURLSession.data = UIImage.remove.jpegData(compressionQuality: 1.0)!
        spyURLSession.response = HTTPURLResponse(url: imageURL,
                                                 statusCode: 200,
                                                 httpVersion: nil,
                                                 headerFields: nil)
        let cacheImage = UIImage.add
        imageCache.store(CachedImage(url: imageURL, image: cacheImage))

        // when
        let resultImage = try await sut.loadImage(from: imageURL)

        // then
        XCTAssertEqual(resultImage, cacheImage)
        XCTAssertEqual(spyURLSession.executeCallCount, 0)
    }

    func test_캐싱된_이미지가_기한이만료되었다면_캐싱된_이미지를_반환하지않고_네트워크에서_Load하는지() async throws {
        // given
        let imageURL = URL(string: "https://test.com/image.jpg")!
        spyURLSession.data = UIImage.remove.jpegData(compressionQuality: 1.0)!
        spyURLSession.response = HTTPURLResponse(url: imageURL,
                                                 statusCode: 200,
                                                 httpVersion: nil,
                                                 headerFields: nil)
        let cacheImage = UIImage.add
        imageCache.store(CachedImage(url: imageURL,
                                     image: cacheImage,
                                     timestamp: Date(timeIntervalSinceNow: TimeInterval(-600))))

        // when
        let resultImage = try await sut.loadImage(from: imageURL)

        // then
        XCTAssertNotEqual(resultImage, cacheImage)
        XCTAssertEqual(self.spyURLSession.executeCallCount, 1)
    }

    func test_중복해서_이미지요청시_적절하게_처리되는지() async throws {
        // given
        let imageURL = URL(string: "https://test.com/image.jpg")!
        spyURLSession.data = UIImage.add.jpegData(compressionQuality: 1.0)!
        spyURLSession.response = HTTPURLResponse(url: imageURL,
                                                 statusCode: 200,
                                                 httpVersion: nil,
                                                 headerFields: nil)

        // when
        let firstImage = try await sut.loadImage(from: imageURL)
        let secondImage = try await sut.loadImage(from: imageURL)

        // then
        XCTAssertEqual(firstImage, secondImage)
        XCTAssertEqual(spyURLSession.executeCallCount, 1)
    }
}
