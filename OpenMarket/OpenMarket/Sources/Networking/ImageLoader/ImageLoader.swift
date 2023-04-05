import UIKit

final class ImageLoader: ImageLoadable {
    typealias Callback = (Result<UIImage, Error>) -> Void

    private let session: URLSessionProtocol
    private let imageCache: ImageCacheable
    private var runningTasks = [URL: [Callback]]()

    init(session: URLSessionProtocol = URLSession.shared, imageCache: ImageCacheable = ImageCache.shared) {
        self.session = session
        self.imageCache = imageCache
    }

    func loadImage(from url: URL, completion: @escaping Callback) {
        if let cachedImage = imageCache.cachedImage(for: url) {
            DispatchQueue.main.async {
                completion(.success(cachedImage.image))
            }
            return
        }

        if runningTasks[url] != nil {
            runningTasks[url]?.append(completion)
            return
        } else {
            runningTasks[url] = [completion]
        }

        session.execute(url: url) { [weak self] result in
            guard let self else { return }

            defer {
                self.runningTasks[url] = nil
            }

            let callbacks = self.runningTasks[url] ?? []

            switch result {
            case .success(let data):
                if let image = UIImage(data: data) {
                    let cachedImage = CachedImage(url: url, image: image)
                    self.imageCache.store(cachedImage)
                    DispatchQueue.main.async {
                        callbacks.forEach { callback in
                            callback(.success(image))
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        callbacks.forEach { callback in
                            callback(.failure(OpenMarketError.decodingError))
                        }
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    callbacks.forEach { callback in
                        callback(.failure(error))
                    }
                }
            }
        }
    }
}
