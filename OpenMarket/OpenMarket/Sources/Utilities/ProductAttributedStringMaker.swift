import UIKit

enum ProductAttributedStringMaker {
    case oneLinePrice(currency: Currency, price: Double, bargainPrice: Double)
    case twoLinePrice(currency: Currency, price: Double, bargainPrice: Double)
    case stock(stock: Int)

    var attributedString: NSAttributedString {
        switch self {
        case .oneLinePrice(let currency, let price, let bargainPrice):
            return attributedPriceString(currency: currency,
                                         price: price,
                                         bargainPrice: bargainPrice,
                                         needNewLineCharacters: true)
        case .twoLinePrice(let currency, let price, let bargainPrice):
            return attributedPriceString(currency: currency,
                                         price: price,
                                         bargainPrice: bargainPrice,
                                         needNewLineCharacters: false)
        case .stock(let stock):
            return attributedStockString(stock: stock)
        }
    }

    private func attributedPriceString(currency: Currency,
                                       price: Double,
                                       bargainPrice: Double,
                                       needNewLineCharacters: Bool = true) -> NSAttributedString {
        guard let formattedPrice = NumberFormatter.decimalString(price),
              let formattedBargainPrice = NumberFormatter.decimalString(bargainPrice) else {
            fatalError("Error: Failed to format")
        }
        let font = UIFont.preferredFont(forTextStyle: .caption2)
        let notDiscounted = price == bargainPrice
        if notDiscounted {
            return NSMutableAttributedString(string: "\(currency.rawValue) \(formattedPrice)",
                                             attributes: [.font: font,
                                                          .foregroundColor: UIColor.gray])
        } else {
            let separator = needNewLineCharacters ? " " : "\n"
            let string = "\(currency.rawValue) \(formattedPrice)\(separator)"
            let attributes: [NSAttributedString.Key: Any] = [.font: font,
                                                             .foregroundColor: UIColor.red,
                                                             .strikethroughStyle: NSUnderlineStyle.single.rawValue]
            let attributedString = NSMutableAttributedString(string: string,
                                                             attributes: attributes)
            let bargainPriceString = NSMutableAttributedString(string: "\(currency.rawValue) \(formattedBargainPrice)",
                                                               attributes: [.font: font,
                                                                            .foregroundColor: UIColor.gray])
            attributedString.append(bargainPriceString)
            return attributedString
        }
    }

    private func attributedStockString(stock: Int) -> NSAttributedString {
        let font = UIFont.preferredFont(forTextStyle: .caption2)
        let inStock = stock > 0
        if inStock {
            let format = NSLocalizedString("Stock : %d", comment: "Stock description")
            let stockString = String(format: format, stock)
            return NSAttributedString(string: stockString,
                                      attributes: [.font: font,
                                                   .foregroundColor: UIColor.gray])
        } else {
            let outOfStockString = NSLocalizedString("Out of stock", comment: "Out of stock")
            return NSAttributedString(string: outOfStockString,
                                      attributes: [.font: font,
                                                   .foregroundColor: UIColor.orange])
        }
    }
}
