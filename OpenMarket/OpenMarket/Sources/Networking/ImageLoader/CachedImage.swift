import UIKit

final class CachedImage {
    let url: URL
    let image: UIImage
    let timestamp: Date

    var isExpired: Bool {
        let currentTime = Date()
        let timeInterval = currentTime.timeIntervalSince(timestamp)
        let moreThanOneMinute = timeInterval > 60
        return moreThanOneMinute
    }

    init(url: URL, image: UIImage, timestamp: Date = Date()) {
        self.url = url
        self.image = image
        self.timestamp = timestamp
    }
}
