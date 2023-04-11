import UIKit

class ImageContentView: UIView, UIContentView {
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

extension ImageContentView {
    struct Configuration: UIContentConfiguration {
        func makeContentView() -> UIView & UIContentView {
            return ImageContentView(self)
        }

        func updated(for state: UIConfigurationState) -> ImageContentView.Configuration {
            return self
        }
    }
}

extension UICollectionViewCell {
    func imageConfiguration() -> ImageContentView.Configuration {
        return ImageContentView.Configuration()
    }
}
