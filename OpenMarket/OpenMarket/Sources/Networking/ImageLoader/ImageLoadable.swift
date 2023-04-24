import UIKit

protocol ImageLoadable {
    func loadImage(from url: URL) async throws -> UIImage
}
