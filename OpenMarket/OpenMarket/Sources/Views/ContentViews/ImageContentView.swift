import UIKit

final class ImageContentView: UIView, UIContentView {
    var configuration: UIContentConfiguration {
        didSet {
            configure(configuration)
        }
    }
    override var intrinsicContentSize: CGSize {
        CGSize(width: 150, height: 150)
    }
    private let imageView = UIImageView()

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
        imageView.image = configuration.image
    }

    private func configureSubviews() {
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true

        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

extension ImageContentView {
    struct Configuration: UIContentConfiguration {
        var image: UIImage?

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
