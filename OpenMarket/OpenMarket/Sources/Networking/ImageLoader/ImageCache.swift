import Foundation

final class ImageCache: ImageCacheable {
    static let shared = ImageCache()

    private var cache = NSCache<NSURL, CachedImage>()

    func store(_ image: CachedImage) {
        cache.setObject(image, forKey: image.url as NSURL)
    }

    func cachedImage(for url: URL) -> CachedImage? {
        guard let cachedImage = cache.object(forKey: url as NSURL) else {
            return nil
        }
        guard cachedImage.isExpired == false else {
            cache.removeObject(forKey: url as NSURL)
            return nil
        }
        return cachedImage
    }
}
