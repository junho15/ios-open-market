import UIKit

protocol ImageLoadable {
    func loadImage(from url: URL, completion: @escaping (Result<UIImage, Error>) -> Void)
}
