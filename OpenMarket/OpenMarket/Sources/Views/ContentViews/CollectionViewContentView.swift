import UIKit

final class CollectionViewContentView: UIView, UIContentView {

    // MARK: Properties

    var configuration: UIContentConfiguration {
        didSet {
            configure(configuration)
        }
    }
    override var intrinsicContentSize: CGSize {
        CGSize(width: 0, height: 150)
    }
    private var collectionView: UICollectionView
    private var dataSource: DataSource?

    // MARK: View Lifecycle

    init(_ configuration: UIContentConfiguration) {
        self.configuration = configuration
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.scrollDirection = .horizontal
        collectionViewLayout.minimumInteritemSpacing = 10
        collectionViewLayout.itemSize = CGSize(width: 150, height: 150)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        super.init(frame: .zero)
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
        let cellRegistration = UICollectionView.CellRegistration(handler: cellRegistrationHandler)
        dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, row in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: row)
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

    private func cellRegistrationHandler(cell: UICollectionViewCell, indexPath: IndexPath, row: Row) {
        switch row {
        case .image(let image):
            var contentConfiguration = cell.imageConfiguration()
            contentConfiguration.image = image
            cell.contentConfiguration = contentConfiguration
        case .imagePicker:
            var contentConfiguration = cell.imagePickerConfiguration()
            contentConfiguration.onClick = (configuration as? Configuration)?.onClick
            cell.contentConfiguration = contentConfiguration
        }
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
