import UIKit

extension UIImage {
    func limitSize(maxSizeInKb: Int, completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.global().async {
            let maxSizeInBytes = maxSizeInKb * 1024
            let step = CGFloat(0.05)

            var compressionQuality = CGFloat(0.8)
            var imageData = self.jpegData(compressionQuality: compressionQuality)

            while let data = imageData,
                  data.count > maxSizeInBytes,
                  compressionQuality > step {
                compressionQuality -= step
                imageData = self.jpegData(compressionQuality: compressionQuality)
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
}
