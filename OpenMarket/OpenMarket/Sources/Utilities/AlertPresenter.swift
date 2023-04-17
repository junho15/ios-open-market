import UIKit

final class AlertPresenter {
    func showAlert(title: String?,
                   message: String?,
                   actions: [AlertAction] = [.okay],
                   in viewController: UIViewController) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        actions.forEach { action in
            let alertAction = UIAlertAction(title: action.title, style: action.style, handler: action.handler)
            alertController.addAction(alertAction)
        }
        viewController.present(alertController, animated: true)
    }
}

extension AlertPresenter {
    struct AlertAction {
        let title: String?
        let style: UIAlertAction.Style
        let handler: ((UIAlertAction) -> Void)?

        static let okay = AlertAction(title: NSLocalizedString("OK", comment: "OK Alert Action"),
                                    style: .default,
                                    handler: nil)
    }
}
