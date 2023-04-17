import Foundation

enum ProductValidationError: Error {
    case invalidName
    case invalidPrice
    case invalidDiscountedPrice
    case invalidStock
    case invalidDescription

    var localizedDescription: String {
        switch self {
        case .invalidName:
            return NSLocalizedString("Enter a product name in 3 to 100 characters",
                                     comment: "Invalid Product Name Description")
        case .invalidPrice:
            return NSLocalizedString("Enter a positive number for the product price",
                                     comment: "Invalid Product Price Description")
        case .invalidDiscountedPrice:
            return NSLocalizedString("Enter a value between 0 and the product price for Discount price",
                                     comment: "Invalid Product DiscountedPrice Description")
        case .invalidStock:
            return NSLocalizedString("Enter a stock",
                                     comment: "Invalid Product Stock Description")
        case .invalidDescription:
            return NSLocalizedString("Enter product description in 10 to 1000 characters",
                                     comment: "Invalid Product Description Description")
        }
    }
}
