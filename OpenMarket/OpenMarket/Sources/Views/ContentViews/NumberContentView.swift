import UIKit

class NumberContentView: UIView, UIContentView {
    var configuration: UIContentConfiguration {
        didSet {
            configure(configuration)
        }
    }
    override var intrinsicContentSize: CGSize {
        CGSize(width: 0, height: 44)
    }
    private let numberTextField = NumberTextField()

    init(_ configuration: UIContentConfiguration) {
        self.configuration = configuration
        super.init(frame: .zero)
        configureSubviews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(_ configuration: UIContentConfiguration) {
        if let configuration = configuration as? IntNumberConfiguration {
            numberTextField.numberType = configuration.keyboardType
            numberTextField.setNumericValue(configuration.number)
        } else if let configuration = configuration as? DoubleNumberConfiguration {
            numberTextField.numberType = configuration.numberType
            numberTextField.setNumericValue(configuration.number)
        }
    }

    private func configureSubviews() {
        numberTextField.font = UIFont.preferredFont(forTextStyle: .body)
        numberTextField.adjustsFontForContentSizeCategory = true
        numberTextField.clearButtonMode = .whileEditing
        numberTextField.addAction(
            UIAction(handler: { [weak self] _ in
                guard let self else { return }
                if let configuration = configuration as? IntNumberConfiguration {
                    configuration.onChange?(numberTextField.numericValue() ?? 0)
                } else if let configuration = configuration as? DoubleNumberConfiguration {
                    configuration.onChange?(numberTextField.numericValue() ?? 0)
                }
            }),
            for: .editingChanged
        )

        numberTextField.translatesAutoresizingMaskIntoConstraints = false
        addSubview(numberTextField)

        let spacing = Constants.layoutSpacing
        NSLayoutConstraint.activate([
            numberTextField.topAnchor.constraint(equalTo: topAnchor),
            numberTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: spacing),
            numberTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: spacing),
            numberTextField.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

    }
}

extension NumberContentView {
    private enum Constants {
        static let layoutSpacing = CGFloat(10)
    }
}

extension NumberContentView {
    struct IntNumberConfiguration: UIContentConfiguration {
        var number: Int?
        var keyboardType: NumberTextField.NumberType = .int
        var onChange: ((Int) -> Void)?

        func makeContentView() -> UIView & UIContentView {
            return NumberContentView(self)
        }

        func updated(for state: UIConfigurationState) -> NumberContentView.IntNumberConfiguration {
            return self
        }
    }

    struct DoubleNumberConfiguration: UIContentConfiguration {
        var number: Double?
        var numberType: NumberTextField.NumberType = .double
        var onChange: ((Double) -> Void)?

        func makeContentView() -> UIView & UIContentView {
            return NumberContentView(self)
        }

        func updated(for state: UIConfigurationState) -> NumberContentView.DoubleNumberConfiguration {
            return self
        }
    }
}

extension UICollectionViewCell {
    func intNumberConfiguration() -> NumberContentView.IntNumberConfiguration {
        return NumberContentView.IntNumberConfiguration()
    }

    func doubleNumberConfiguration() -> NumberContentView.DoubleNumberConfiguration {
        return NumberContentView.DoubleNumberConfiguration()
    }
}
