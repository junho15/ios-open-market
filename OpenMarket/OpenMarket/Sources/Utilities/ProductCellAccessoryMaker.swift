import UIKit

enum ProductCellAccessoryMaker {
    case stockLabel(stock: Int)

    var cellAccessory: UICellAccessory {
        switch self {
        case .stockLabel(let stock):
            let inStock = stock > 0
            if inStock {
                let tintColor = UIColor.systemGray
                let font = UIFont.preferredFont(forTextStyle: .caption2)
                let format = NSLocalizedString("Stock : %d", comment: "Stock description")
                let stockText = String(format: format, stock)
                return UICellAccessory.label(text: stockText,
                                             options: .init(tintColor: tintColor, font: font))
            } else {
                let tintColor = UIColor.systemOrange
                let font = UIFont.preferredFont(forTextStyle: .caption2)
                let outOfStockText = NSLocalizedString("Out of stock", comment: "Out of stock")
                return UICellAccessory.label(text: outOfStockText,
                                             options: .init(tintColor: tintColor, font: font))
            }
        }
    }
}
