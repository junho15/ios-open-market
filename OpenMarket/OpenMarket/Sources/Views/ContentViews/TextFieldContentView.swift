import UIKit

class TextFieldContentView: UIView, UIContentView {
    var configuration: UIContentConfiguration {
        didSet {
            configure(configuration)
        }
    }

    init(_ configuration: UIContentConfiguration) {
        self.configuration = configuration
        super.init(frame: .zero)
        configureSubviews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(_ configuration: UIContentConfiguration) {

    }

    private func configureSubviews() {

    }
}

extension TextFieldContentView {
    struct Configuration: UIContentConfiguration {

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
