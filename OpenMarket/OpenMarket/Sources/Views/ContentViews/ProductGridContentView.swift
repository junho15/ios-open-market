import UIKit

final class ProductGridContentView: UIView, UIContentView {
    var configuration: UIContentConfiguration {
        didSet {
            configure(configuration)
        }
    }
    private let thumbnailImageView = UIImageView()
    private let nameLabel = UILabel()
    private let priceLabel = UILabel()
    private let stockLabel = UILabel()
    private let stackView = UIStackView()

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
        thumbnailImageView.image = configuration.thumbnailImage
        nameLabel.text = configuration.name
        priceLabel.attributedText = ProductAttributedStringMaker.twoLinePrice(
            currency: configuration.currency,
            price: configuration.price ?? 0,
            bargainPrice: configuration.bargainPrice ?? 0,
            font: UIFont.preferredFont(forTextStyle: .caption2)
        ).attributedString
        stockLabel.attributedText = ProductAttributedStringMaker.stock(
            stock: configuration.stock ?? 0,
            font: UIFont.preferredFont(forTextStyle: .caption2)
        ).attributedString
    }

    private func configureSubviews() {
        thumbnailImageView.contentMode = .scaleToFill
        nameLabel.font = .preferredFont(forTextStyle: .body)
        nameLabel.adjustsFontForContentSizeCategory = true
        nameLabel.numberOfLines = 2
        priceLabel.numberOfLines = 0

        [thumbnailImageView, nameLabel, priceLabel, stockLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            stackView.addArrangedSubview($0)
        }

        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)

        let thumbnailImageViewConstraints = (
            width: thumbnailImageView.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            height: thumbnailImageView.heightAnchor.constraint(equalTo: thumbnailImageView.widthAnchor))
        thumbnailImageViewConstraints.width.priority = .defaultHigh + 2
        thumbnailImageViewConstraints.height.priority = .defaultHigh + 1

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),

            thumbnailImageViewConstraints.width,
            thumbnailImageViewConstraints.height
        ])
    }
}

extension ProductGridContentView {
    struct Configuration: UIContentConfiguration {
        var thumbnailImage: UIImage?
        var name: String = ""
        var currency: Currency = .KRW
        var price: Double? = 0
        var bargainPrice: Double? = 0
        var stock: Int? = 0

        func makeContentView() -> UIView & UIContentView {
            return ProductGridContentView(self)
        }

        func updated(for state: UIConfigurationState) -> ProductGridContentView.Configuration {
            return self
        }
    }
}

extension UICollectionViewCell {
    func productGridConfiguration() -> ProductGridContentView.Configuration {
        return ProductGridContentView.Configuration()
    }
}
