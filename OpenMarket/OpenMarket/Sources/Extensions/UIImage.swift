import UIKit

extension UIImage {
    func limitSize(maxSizeInKb: Int) async -> UIImage? {
        let maxSizeInBytes = maxSizeInKb * 1024
        let step = CGFloat(0.05)

        guard let resizedImage = self.resized(targetSize: CGSize(width: 500, height: 500)) else {
            return nil
        }

        var compressionQuality = CGFloat(0.8)
        var imageData = resizedImage.jpegData(compressionQuality: compressionQuality)

        while let data = imageData,
              data.count > maxSizeInBytes,
              compressionQuality > step {
            compressionQuality -= step
            imageData = resizedImage.jpegData(compressionQuality: compressionQuality)
        }

        if let imageData {
            return UIImage(data: imageData)
        } else {
            return nil
        }
    }

    private func resized(targetSize: CGSize) -> UIImage? {
        let size = self.size
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height

        let ratio = min(widthRatio, heightRatio)
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
}
