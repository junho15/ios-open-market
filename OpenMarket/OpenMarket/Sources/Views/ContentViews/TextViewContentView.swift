import UIKit

final class TextViewContentView: UIView, UIContentView {
    var configuration: UIContentConfiguration {
        didSet {
            configure(configuration)
        }
    }
    override var intrinsicContentSize: CGSize {
        CGSize(width: 0, height: 200)
    }
    private let textView = UITextView()

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
        textView.text = configuration.text
    }

    private func configureSubviews() {
        textView.delegate = self
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.adjustsFontForContentSizeCategory = true

        textView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(textView)

        let spacing = Constants.layoutSpacing
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: topAnchor),
            textView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: spacing),
            textView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -spacing),
            textView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

extension TextViewContentView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        guard let configuration = configuration as? Configuration else { return }
        configuration.onChange?(textView.text)
    }
}

extension TextViewContentView {
    private enum Constants {
        static let layoutSpacing = CGFloat(10)
    }
}

extension TextViewContentView {
    struct Configuration: UIContentConfiguration {
        var text: String = ""
        var onChange: ((String) -> Void)?

        func makeContentView() -> UIView & UIContentView {
            return TextViewContentView(self)
        }

        func updated(for state: UIConfigurationState) -> TextViewContentView.Configuration {
            return self
        }
    }
}

extension UICollectionViewCell {
    func textViewConfiguration() -> TextViewContentView.Configuration {
        return TextViewContentView.Configuration()
    }
}
