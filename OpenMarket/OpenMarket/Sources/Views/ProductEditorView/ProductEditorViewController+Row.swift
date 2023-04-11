import UIKit

extension ProductEditorViewController {
    enum Row: CustomStringConvertible {
        case images(images: [UIImage], isEditable: Bool)
        case name(text: String)
        case priceCurrency(price: Double, currency: Currency)
        case discountedPrice(discountedPrice: Double)
        case stock(stock: Int)
        case description(text: String)

        var description: String {
            switch self {
            case .images:
                return NSLocalizedString("Product Images",
                                         comment: "Product Images Row Description")
            case .name:
                return NSLocalizedString("Product Name",
                                         comment: "Product Name Row Description")
            case .priceCurrency:
                return NSLocalizedString("Product Price",
                                         comment: "Product Price Row Description")
            case .discountedPrice:
                return NSLocalizedString("Product Discounted Price",
                                         comment: "Product Discounted Price Row Description")
            case .stock:
                return NSLocalizedString("Product Stock",
                                         comment: "Product Stock Row Description")
            case .description:
                return NSLocalizedString("Product Description",
                                         comment: "Product Description Row Description")
            }
        }
    }
}
