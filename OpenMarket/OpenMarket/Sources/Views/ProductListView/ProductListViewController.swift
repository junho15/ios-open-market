import UIKit

final class ProductListViewController: UICollectionViewController {

    // MARK: Properties

    private let openMarketAPIClient = OpenMarketAPIClient()
    private let imageLoader = ImageLoader()
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

        openMarketAPIClient.fetchPage(pageNumber: 3, productsPerPage: 100) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let page):
                products = page.products
                updateSnapshot()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
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
        let listCellRegistration = UICollectionView.CellRegistration(handler: self.listCellRegistrationHandler)
        let gridCellRegistration = UICollectionView.CellRegistration(handler: self.gridCellRegistrationHandler)
        dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            switch self.layoutStyle {
            case .list:
                return collectionView.dequeueConfiguredReusableCell(using: listCellRegistration,
                                                                    for: indexPath,
                                                                    item: itemIdentifier)
            case .grid:
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
        let placeholderImage = UIImage(systemName: "photo")
        contentConfiguration.image = placeholderImage
        contentConfiguration.imageProperties.maximumSize = CGSize(width: 100, height: 100)
        contentConfiguration.imageProperties.reservedLayoutSize = CGSize(width: 100, height: 100)
        if let url = URL(string: product.thumbnailURL) {
            imageLoader.loadImage(from: url) { [weak self] result in
                guard let self else { return }
                switch result {
                case .success(let image):
                    if collectionView.indexPath(for: cell) == indexPath {
                        contentConfiguration.image = image
                        cell.contentConfiguration = contentConfiguration
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
        cell.contentConfiguration = contentConfiguration

        let stockCellAccessory = ProductCellAccessoryMaker.stockLabel(stock: product.stock).cellAccessory
        cell.accessories = [stockCellAccessory, .disclosureIndicator(displayed: .always)]
    }

    private func gridCellRegistrationHandler(cell: UICollectionViewCell,
                                             indexPath: IndexPath,
                                             itemIdentifier: Product.ID) {
    }

    private func updateSnapshot(reloading changedProductIDs: [Product.ID] = []) {
        var snapshot = Snapshot()
        snapshot.appendSections([ProductListSection.main])
        snapshot.appendItems(products.map { $0.id })
        if changedProductIDs.isEmpty == false {
            snapshot.reloadItems(changedProductIDs)
        }
        dataSource.apply(snapshot)
    }

    private func product(for id: Product.ID) -> Product? {
        return products.first(where: { $0.id == id })
    }
}
