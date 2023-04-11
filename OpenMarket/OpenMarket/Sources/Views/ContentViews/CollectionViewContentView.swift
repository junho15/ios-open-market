import UIKit

class CollectionViewContentView: UICollectionView, UIContentView {
    var configuration: UIContentConfiguration {
        didSet {
            configure(configuration)
        }
    }

    init(_ configuration: UIContentConfiguration) {
        self.configuration = configuration

        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.scrollDirection = .horizontal
        collectionViewLayout.minimumInteritemSpacing = 10
        super.init(frame: .zero, collectionViewLayout: collectionViewLayout)

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

extension CollectionViewContentView {
    struct Configuration: UIContentConfiguration {
        func makeContentView() -> UIView & UIContentView {
            return CollectionViewContentView(self)
        }

        func updated(for state: UIConfigurationState) -> CollectionViewContentView.Configuration {
            return self
        }
    }
}

extension UICollectionViewCell {
    func collectionViewConfiguration() -> CollectionViewContentView.Configuration {
        return CollectionViewContentView.Configuration()
    }
}
