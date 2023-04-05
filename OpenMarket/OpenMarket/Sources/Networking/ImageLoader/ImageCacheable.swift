import Foundation

protocol ImageCacheable {
    func store(_ image: CachedImage)
    func cachedImage(for url: URL) -> CachedImage?
}
