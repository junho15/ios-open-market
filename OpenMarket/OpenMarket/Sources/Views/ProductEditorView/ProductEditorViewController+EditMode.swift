import Foundation

extension ProductEditorViewController {
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
}
