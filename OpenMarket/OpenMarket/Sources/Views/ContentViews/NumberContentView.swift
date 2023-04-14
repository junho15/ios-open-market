import UIKit

final class NumberContentView: UIView, UIContentView {
    var configuration: UIContentConfiguration {
        didSet {
            configure(configuration)
        }
    }
    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: 44)
    }
    private let numberTextField = NumberTextField()

    init(_ configuration: UIContentConfiguration) {
        self.configuration = configuration
        super.init(frame: .zero)
        backgroundColor = .systemBackground
        configureSubviews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(_ configuration: UIContentConfiguration) {
        if let configuration = configuration as? IntNumberConfiguration {
            numberTextField.numberType = configuration.numberType
            numberTextField.setNumericValue(configuration.number)
            numberTextField.placeholder = configuration.placeholder
        } else if let configuration = configuration as? DoubleNumberConfiguration {
            numberTextField.numberType = configuration.numberType
            numberTextField.setNumericValue(configuration.number)
            numberTextField.placeholder = configuration.placeholder
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
                    configuration.onChange?(numberTextField.numericValue())
                } else if let configuration = configuration as? DoubleNumberConfiguration {
                    configuration.onChange?(numberTextField.numericValue())
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
            numberTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -spacing),
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
        let numberType: NumberTextField.NumberType = .int
        var number: Int?
        var placeholder: String?
        var onChange: ((Int?) -> Void)?

        func makeContentView() -> UIView & UIContentView {
            return NumberContentView(self)
        }

        func updated(for state: UIConfigurationState) -> NumberContentView.IntNumberConfiguration {
            return self
        }
    }

    struct DoubleNumberConfiguration: UIContentConfiguration {
        let numberType: NumberTextField.NumberType = .double
        var number: Double?
        var placeholder: String?
        var onChange: ((Double?) -> Void)?

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
