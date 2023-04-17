import Foundation

protocol ProductEditable {
    var editMode: EditMode { get }
    var openMarketAPIClient: OpenMarketAPIClient { get }
    var imageLoader: ImageLoader { get }
    var onChange: (Product?) -> Void { get }
}

enum EditMode: CustomStringConvertible {
    case add
    case edit

    var description: String {
        switch self {
        case .add:
            return NSLocalizedString("Register a Product", comment: "EditMode.add description")
        case .edit:
            return NSLocalizedString("Edit a Product", comment: "EditMode.edit description")
        }
    }
}
