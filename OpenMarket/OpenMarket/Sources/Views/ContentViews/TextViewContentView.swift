import UIKit

class TextViewContentView: UIView, UIContentView {
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

extension TextViewContentView {
    struct Configuration: UIContentConfiguration {

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
