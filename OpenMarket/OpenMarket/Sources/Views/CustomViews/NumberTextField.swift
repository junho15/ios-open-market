import UIKit

final class NumberTextField: UITextField {
    var numberType = NumberType.double {
        didSet {
            self.keyboardType = numberType.keyboardType
        }
    }

    init(keyboardType: NumberType = .double) {
        super.init(frame: .zero)
        self.numberType = keyboardType
        self.keyboardType = keyboardType.keyboardType
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setNumericValue<T: Numeric & LosslessStringConvertible>(_ value: T?) {
        if let value {
            text = NumberFormatter.decimalString(value, usesGroupingSeparator: false)
        } else {
            text = nil
        }
    }

    func numericValue<T: Numeric & LosslessStringConvertible>() -> T? {
        guard let text else { return nil }
        return T(text)
    }
}

extension NumberTextField: UITextFieldDelegate {
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        let allowedCharacterSet = numberType.allowedCharacterSet
        let characterSet = CharacterSet(charactersIn: string)
        let isAllowed = allowedCharacterSet.isSuperset(of: characterSet)
        let numberOfDots = ((textField.text ?? "") + string).filter { $0 == "." }.count
        return isAllowed && numberOfDots < 2
    }
}

extension NumberTextField {
    enum NumberType {
        case double
        case int

        var keyboardType: UIKeyboardType {
            switch self {
            case .double:
                return .decimalPad
            case .int:
                return .numberPad
            }
        }

        var allowedCharacterSet: CharacterSet {
            switch self {
            case .double:
                return CharacterSet(charactersIn: "0123456789.")
            case .int:
                return CharacterSet.decimalDigits
            }
        }
    }
}
