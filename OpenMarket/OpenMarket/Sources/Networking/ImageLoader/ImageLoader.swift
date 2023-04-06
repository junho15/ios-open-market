import UIKit

final class ImageLoader: ImageLoadable {
    typealias Callback = (Result<UIImage, Error>) -> Void

    private let session: URLSessionProtocol
    private let imageCache: ImageCacheable
    private let runningTasksQueue = DispatchQueue(label: "runningTasks")
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

        var existsRunningTasks = true
        runningTasksQueue.sync {
            existsRunningTasks = runningTasks[url] != nil
            if existsRunningTasks {
                runningTasks[url]?.append(completion)
            } else {
                runningTasks[url] = [completion]
            }
        }
        guard existsRunningTasks == false else { return }

        session.execute(url: url) { [weak self] result in
            guard let self else { return }
            var callbacks = [Callback]()
            self.runningTasksQueue.sync {
                callbacks = self.runningTasks[url] ?? []
                self.runningTasks[url] = nil
            }

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
