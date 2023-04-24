import UIKit

final class ImageLoader: ImageLoadable {
    typealias Callback = (Result<UIImage, Error>) -> Void

    private let session: URLSessionProtocol
    private let imageCache: ImageCacheable

    init(session: URLSessionProtocol = URLSession.shared, imageCache: ImageCacheable = ImageCache.shared) {
        self.session = session
        self.imageCache = imageCache
    }

    func loadImage(from url: URL) async throws -> UIImage {
        if let cachedImage = imageCache.cachedImage(for: url) {
            return cachedImage.image
        }

        let data = try await session.execute(url: url)
        guard let image = UIImage(data: data) else {
            throw OpenMarketError.decodingError
        }

        let cachedImage = CachedImage(url: url, image: image)
        imageCache.store(cachedImage)
        return image
    }
}
