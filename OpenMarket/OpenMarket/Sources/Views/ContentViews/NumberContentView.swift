import UIKit

class NumberContentView: UIView, UIContentView {
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

extension NumberContentView {
    struct Configuration: UIContentConfiguration {

        func makeContentView() -> UIView & UIContentView {
            return NumberContentView(self)
        }

        func updated(for state: UIConfigurationState) -> NumberContentView.Configuration {
            return self
        }
    }
}

extension UICollectionViewCell {
    func numberConfiguration() -> NumberContentView.Configuration {
        return NumberContentView.Configuration()
    }
}
