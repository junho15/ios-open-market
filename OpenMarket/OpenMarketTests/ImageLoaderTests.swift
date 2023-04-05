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

    func test_정상적인상황에서_imageLoad_호출시_sucess를_반환하는지() {
        // given
        let imageURL = URL(string: "https://test.com/image.jpg")!
        spyURLSession.data = UIImage.add.jpegData(compressionQuality: 1.0)!
        spyURLSession.response = HTTPURLResponse(url: imageURL,
                                                 statusCode: 200,
                                                 httpVersion: nil,
                                                 headerFields: nil)
        let expectation = self.expectation(description: "ImageLoad Complete")

        // when
        sut.loadImage(from: imageURL) { result in
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

    func test_imageLoad_호출시_에러가_발생하면_error를_반환하는지() {
        // given
        let imageURL = URL(string: "https://test.com/image.jpg")!
        spyURLSession.data = UIImage.add.jpegData(compressionQuality: 1.0)!
        spyURLSession.response = HTTPURLResponse(url: imageURL,
                                                 statusCode: 500,
                                                 httpVersion: nil,
                                                 headerFields: nil)
        let expectation = self.expectation(description: "ImageLoad Complete")

        // when
        sut.loadImage(from: imageURL) { result in
            // then
            switch result {
            case .success:
                XCTFail("Should return failure")
            case .failure:
                XCTAssert(true)
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0) { error in
            if let error {
                XCTFail(error.localizedDescription)
            }
        }
    }

    func test_캐싱된_이미지가_있으면_캐싱된_이미지를_반환하고_네트워크에서_Load하지않는지() {
        // given
        let imageURL = URL(string: "https://test.com/image.jpg")!
        spyURLSession.data = UIImage.remove.jpegData(compressionQuality: 1.0)!
        spyURLSession.response = HTTPURLResponse(url: imageURL,
                                                 statusCode: 200,
                                                 httpVersion: nil,
                                                 headerFields: nil)
        let cacheImage = UIImage.add
        imageCache.store(CachedImage(url: imageURL, image: cacheImage))
        let expectation = self.expectation(description: "ImageLoad Complete")

        // when
        sut.loadImage(from: imageURL) { result in
            // then
            switch result {
            case .success(let resultImage):
                XCTAssertEqual(resultImage, cacheImage)
                XCTAssertEqual(self.spyURLSession.executeCallCount, 0)
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

    func test_캐싱된_이미지가_기한이만료되었다면_캐싱된_이미지를_반환하지않고_네트워크에서_Load하는지() {
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
        let expectation = self.expectation(description: "ImageLoad Complete")

        // when
        sut.loadImage(from: imageURL) { result in
            // then
            switch result {
            case .success(let resultImage):
                XCTAssertNotEqual(resultImage, cacheImage)
                XCTAssertEqual(self.spyURLSession.executeCallCount, 1)
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

    func test_중복해서_이미지요청시_적절하게_처리되는지() {
        // given
        let imageURL = URL(string: "https://test.com/image.jpg")!
        spyURLSession.data = UIImage.add.jpegData(compressionQuality: 1.0)!
        spyURLSession.response = HTTPURLResponse(url: imageURL,
                                                 statusCode: 200,
                                                 httpVersion: nil,
                                                 headerFields: nil)
        let firstExpectation = self.expectation(description: "First ImageLoad Complete")
        let secondExpectation = self.expectation(description: "Second ImageLoad Complete")

        // when
        var firstImage: UIImage?
        var secondImage: UIImage?
        sut.loadImage(from: imageURL) { result in
            switch result {
            case .success(let image):
                firstImage = image
            case .failure:
                XCTFail("Should return first Image")
            }
            firstExpectation.fulfill()
        }
        sut.loadImage(from: imageURL) { result in
            switch result {
            case .success(let image):
                secondImage = image
            case .failure:
                XCTFail("Should return second Image")
            }
            secondExpectation.fulfill()
        }

        // then
        waitForExpectations(timeout: 1.0) { error in
            if let error {
                XCTFail(error.localizedDescription)
            }
        }
        XCTAssertEqual(firstImage, secondImage)
        XCTAssertEqual(spyURLSession.executeCallCount, 1)
    }
}
