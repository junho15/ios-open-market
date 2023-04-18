import UIKit

extension UIImage {
    func limitSize(maxSizeInKb: Int, completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.global().async {
            let maxSizeInBytes = maxSizeInKb * 1024
            let step = CGFloat(0.05)

            guard let resizedImage = self.resized(targetSize: CGSize(width: 500, height: 500)) else {
                completion(nil)
                return
            }

            var compressionQuality = CGFloat(0.8)
            var imageData = resizedImage.jpegData(compressionQuality: compressionQuality)

            while let data = imageData,
                  data.count > maxSizeInBytes,
                  compressionQuality > step {
                compressionQuality -= step
                imageData = resizedImage.jpegData(compressionQuality: compressionQuality)
            }

            DispatchQueue.main.async {
                if let imageData {
                    completion(UIImage(data: imageData))
                } else {
                    completion(nil)
                }
            }
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
