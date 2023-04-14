import UIKit

final class ImagePickerContentView: UIView, UIContentView {
    var configuration: UIContentConfiguration
    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: 140)
    }
    private let imagePickerButton = UIButton()
    private var onClick: (() -> Void)?

    init(_ configuration: UIContentConfiguration) {
        self.configuration = configuration
        super.init(frame: .zero)
        configureSubviews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureSubviews() {
        imagePickerButton.setImage(Constants.placeholderImage, for: .normal)
        imagePickerButton.backgroundColor = .systemGray5
        imagePickerButton.addAction(
            UIAction(handler: { [weak self] _ in
                guard let self,
                let configuration = configuration as? Configuration else { return }
                configuration.onClick?()
            }),
            for: .touchUpInside
        )

        imagePickerButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imagePickerButton)

        NSLayoutConstraint.activate([
            imagePickerButton.topAnchor.constraint(equalTo: topAnchor),
            imagePickerButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            imagePickerButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            imagePickerButton.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

extension ImagePickerContentView {
    private enum Constants {
        static let placeholderImage = UIImage.add
    }
}

extension ImagePickerContentView {
    struct Configuration: UIContentConfiguration {
        var onClick: (() -> Void)?

        func makeContentView() -> UIView & UIContentView {
            return ImagePickerContentView(self)
        }

        func updated(for state: UIConfigurationState) -> ImagePickerContentView.Configuration {
            return self
        }
    }
}

extension UICollectionViewCell {
    func imagePickerConfiguration() -> ImagePickerContentView.Configuration {
        return ImagePickerContentView.Configuration()
    }
}
