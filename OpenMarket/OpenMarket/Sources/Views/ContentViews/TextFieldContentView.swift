import UIKit

final class TextFieldContentView: UIView, UIContentView {
    var configuration: UIContentConfiguration {
        didSet {
            configure(configuration)
        }
    }
    override var intrinsicContentSize: CGSize {
        CGSize(width: 0, height: 44)
    }
    private let textField = UITextField()

    init(_ configuration: UIContentConfiguration) {
        self.configuration = configuration
        super.init(frame: .zero)
        configureSubviews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(_ configuration: UIContentConfiguration) {
        guard let configuration = configuration as? Configuration else { return }
        textField.text = configuration.text
        textField.placeholder = configuration.placeholder
    }

    private func configureSubviews() {
        textField.font = UIFont.preferredFont(forTextStyle: .body)
        textField.adjustsFontForContentSizeCategory = true
        textField.clearButtonMode = .whileEditing
        textField.addAction(
            UIAction(handler: { [weak self] _ in
                guard let self,
                      let configuration = self.configuration as? Configuration else { return }
                configuration.onChange?(self.textField.text ?? "")
            }),
            for: .editingChanged
        )

        textField.translatesAutoresizingMaskIntoConstraints = false
        addSubview(textField)

        let spacing = Constants.layoutSpacing
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: topAnchor),
            textField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: spacing),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -spacing),
            textField.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

extension TextFieldContentView {
    private enum Constants {
        static let layoutSpacing = CGFloat(10)
    }
}

extension TextFieldContentView {
    struct Configuration: UIContentConfiguration {
        var text: String = ""
        var placeholder: String?
        var onChange: ((String) -> Void)?

        func makeContentView() -> UIView & UIContentView {
            return TextFieldContentView(self)
        }

        func updated(for state: UIConfigurationState) -> TextFieldContentView.Configuration {
            return self
        }
    }
}

extension UICollectionViewCell {
    func textFieldConfiguration() -> TextFieldContentView.Configuration {
        return TextFieldContentView.Configuration()
    }
}
