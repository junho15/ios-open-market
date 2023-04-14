import UIKit

final class CollectionViewContentView: UIView, UIContentView {

    // MARK: Properties

    var configuration: UIContentConfiguration {
        didSet {
            configure(configuration)
        }
    }
    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: 150)
    }
    private var collectionView: UICollectionView
    private var dataSource: DataSource?

    // MARK: View Lifecycle

    init(_ configuration: UIContentConfiguration) {
        self.configuration = configuration
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.scrollDirection = .horizontal
        collectionViewLayout.minimumInteritemSpacing = 10
        collectionViewLayout.itemSize = CGSize(width: 140, height: 140)
        collectionViewLayout.sectionInset = UIEdgeInsets(top: 5.0, left: 10.0, bottom: 5.0, right: 10.0)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        super.init(frame: .zero)
        backgroundColor = .systemBackground
        configureDatasource()
        configureSubviews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Methods

    func configure(_ configuration: UIContentConfiguration) {
        guard let configuration = configuration as? Configuration else { return }
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        var rows = configuration.images.map { Row.image(image: $0) }
        if configuration.canAdd {
            rows.append(.imagePicker)
        }
        snapshot.appendItems(rows)
        dataSource?.apply(snapshot)
    }

    private func configureDatasource() {
        let imageCellRegistration = UICollectionView.CellRegistration(handler: imageCellRegistrationHandler)
        let imagePickerCellRegistration = UICollectionView.CellRegistration(handler: imagePickerCellRegistrationHandler)
        dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, row in
            switch row {
            case .image(let image):
                return collectionView.dequeueConfiguredReusableCell(using: imageCellRegistration,
                                                                    for: indexPath,
                                                                    item: image)
            case .imagePicker:
                return collectionView.dequeueConfiguredReusableCell(using: imagePickerCellRegistration,
                                                                    for: indexPath,
                                                                    item: ())
            }
        }
    }

    private func configureSubviews() {
        collectionView.backgroundColor = .systemBackground

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

// MARK: - DataSource

extension CollectionViewContentView {
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, Row>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Row>

    private func imageCellRegistrationHandler(cell: UICollectionViewCell, indexPath: IndexPath, image: UIImage) {
        var contentConfiguration = cell.imageConfiguration()
        contentConfiguration.image = image
        cell.contentConfiguration = contentConfiguration
    }

    private func imagePickerCellRegistrationHandler(cell: UICollectionViewCell, indexPath: IndexPath, item: Void) {
        var contentConfiguration = cell.imagePickerConfiguration()
        contentConfiguration.onClick = (configuration as? Configuration)?.onClick
        cell.contentConfiguration = contentConfiguration
    }
}

extension CollectionViewContentView {
    private enum Section: Int {
        case main
    }

    private enum Row: Hashable {
        case image(image: UIImage)
        case imagePicker
    }
}

extension CollectionViewContentView {
    struct Configuration: UIContentConfiguration {
        var images: [UIImage] = []
        var canAdd: Bool = false
        var onClick: (() -> Void)?

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
