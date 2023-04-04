import UIKit

final class ProductListViewController: UICollectionViewController {

    // MARK: Properties

    private var dataSource: DataSource!
    private var products = [Product]()
    private var layoutStyle = LayoutStyle.list {
        didSet {
            configureCollectionViewLayoutStyle(layoutStyle)
        }
    }

    // MARK: IBOutlets

    @IBOutlet weak var segmentedControl: UISegmentedControl!

    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        configureCollectionViewLayoutStyle(layoutStyle)
        configureDataSource()
    }

    // MARK: IBActions

    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        guard let layoutStyle = LayoutStyle(rawValue: segmentedControl.selectedSegmentIndex) else { return }
        self.layoutStyle = layoutStyle
    }
}

// MARK: - Methods

extension ProductListViewController {
    private func configureCollectionViewLayoutStyle(_ layoutStyle: LayoutStyle) {
        let layout = layoutStyle.layout
        collectionView.collectionViewLayout = layout
        collectionView.collectionViewLayout.invalidateLayout()
    }

    private func configureDataSource() {
        dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            switch self.layoutStyle {
            case .list:
                let listCellRegistration = UICollectionView.CellRegistration(handler: self.listCellRegistrationHandler)
                return collectionView.dequeueConfiguredReusableCell(using: listCellRegistration,
                                                                    for: indexPath,
                                                                    item: itemIdentifier)
            case .grid:
                let gridCellRegistration = UICollectionView.CellRegistration(handler: self.gridCellRegistrationHandler)
                return collectionView.dequeueConfiguredReusableCell(using: gridCellRegistration,
                                                                    for: indexPath,
                                                                    item: itemIdentifier)
            }
        }
    }
}

// MARK: - DataSource

extension ProductListViewController {
    typealias DataSource = UICollectionViewDiffableDataSource<ProductListSection, Product.ID>
    typealias Snapshot = NSDiffableDataSourceSnapshot<ProductListSection, Product.ID>

    private func listCellRegistrationHandler(cell: UICollectionViewListCell,
                                             indexPath: IndexPath,
                                             itemIdentifier: Product.ID) {
        guard let product = product(for: itemIdentifier) else { fatalError("Error: Not found") }
        var contentConfiguration = cell.defaultContentConfiguration()
        contentConfiguration.text = product.name
        contentConfiguration.textProperties.font = UIFont.preferredFont(forTextStyle: .body)
        let priceAttributedText = ProductAttributedStringMaker.oneLinePrice(currency: product.currency,
                                                             price: product.price,
                                                             bargainPrice: product.bargainPrice).attributedString
        contentConfiguration.secondaryAttributedText = priceAttributedText
        contentConfiguration.secondaryTextProperties.font = UIFont.preferredFont(forTextStyle: .caption2)
        cell.contentConfiguration = contentConfiguration

        cell.accessories = [.disclosureIndicator(displayed: .always)]
    }

    private func gridCellRegistrationHandler(cell: UICollectionViewCell,
                                             indexPath: IndexPath,
                                             itemIdentifier: Product.ID) {
    }

    private func product(for id: Product.ID) -> Product? {
        return products.first(where: { $0.id == id })
    }
}
