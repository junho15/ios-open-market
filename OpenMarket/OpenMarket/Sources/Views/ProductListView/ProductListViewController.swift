import UIKit

final class ProductListViewController: UICollectionViewController {

    // MARK: Properties

    private let openMarketAPIClient = OpenMarketAPIClient()
    private let imageLoader = ImageLoader()
    private var dataSource: DataSource!
    private var products = [Product]()
    private var nextPageNumber = 1
    private var hasNextPage = true
    private var isLoadingNewProducts = false
    private var layoutStyle = LayoutStyle.list {
        didSet {
            configureCollectionViewLayoutStyle(layoutStyle)
            updateSnapshot(reloading: productIDs, animatingDifferences: false)
        }
    }
    private var productIDs: [Product.ID] {
        products.map { $0.id }
    }

    // MARK: IBOutlets

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!

    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        configureSegmentedControl()
        clearProducts()
        loadProducts(pageNumber: nextPageNumber,
                     productsPerPage: Constants.productsPerPage,
                     withActivityIndicator: true)
    }

    // MARK: IBActions

    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        guard let layoutStyle = LayoutStyle(rawValue: segmentedControl.selectedSegmentIndex) else { return }
        self.layoutStyle = layoutStyle
    }
}

// MARK: - Methods

extension ProductListViewController {
    private func configureCollectionView() {
        configureCollectionViewLayoutStyle(layoutStyle)
        configureDataSource()
        configureRefreshControl()
    }

    private func configureCollectionViewLayoutStyle(_ layoutStyle: LayoutStyle) {
        let layout = layoutStyle.layout
        collectionView.collectionViewLayout = layout
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.reloadData()
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

    private func configureRefreshControl() {
        collectionView.refreshControl = UIRefreshControl()
        collectionView.refreshControl?.addAction(UIAction(handler: { [weak self] _ in
            guard let self else { return }
            clearProducts()
            loadProducts(pageNumber: nextPageNumber, productsPerPage: Constants.productsPerPage)
        }), for: .valueChanged)
    }

    private func configureSegmentedControl() {
        LayoutStyle.allCases.forEach { layoutStyle in
            segmentedControl.setTitle(layoutStyle.localizedString, forSegmentAt: layoutStyle.rawValue)
        }
    }

    private func clearProducts() {
        products.removeAll()
        nextPageNumber = 1
        hasNextPage = true
    }

    private func loadProducts(pageNumber: Int, productsPerPage: Int, withActivityIndicator: Bool = false) {
        guard hasNextPage else { return }
        if withActivityIndicator {
            activityIndicatorView.startAnimating()
        }

        openMarketAPIClient.fetchPage(pageNumber: pageNumber,
                                      productsPerPage: productsPerPage) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let page):
                nextPageNumber = pageNumber + 1
                hasNextPage = page.hasNextPage
                let updatedProductIDs = updateOrInsertProducts(page.products).updated
                updateSnapshot(reloading: updatedProductIDs)
            case .failure(let error):
                print(error.localizedDescription)
            }
            activityIndicatorView.stopAnimating()
            collectionView.refreshControl?.endRefreshing()
            isLoadingNewProducts = false
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
        guard let product = product(for: itemIdentifier) else { fatalError("Error: Not found Product") }
        var contentConfiguration = cell.defaultContentConfiguration()
        contentConfiguration.text = product.name
        contentConfiguration.textProperties.font = UIFont.preferredFont(forTextStyle: .body)
        let priceAttributedText = ProductAttributedStringMaker.oneLinePrice(currency: product.currency,
                                                             price: product.price,
                                                             bargainPrice: product.bargainPrice).attributedString
        contentConfiguration.secondaryAttributedText = priceAttributedText
        contentConfiguration.secondaryTextProperties.font = UIFont.preferredFont(forTextStyle: .caption2)

        contentConfiguration.image = Constants.placeholderImage
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
        guard let product = product(for: itemIdentifier) else { fatalError("Error: Not found Product") }
        var contentConfiguration = cell.productGridConfiguration()
        contentConfiguration.name = product.name
        contentConfiguration.currency = product.currency
        contentConfiguration.price = product.price
        contentConfiguration.bargainPrice = product.bargainPrice
        contentConfiguration.stock = product.stock

        contentConfiguration.thumbnailImage = Constants.placeholderImage
        if let url = URL(string: product.thumbnailURL) {
            imageLoader.loadImage(from: url) { [weak self] result in
                guard let self else { return }
                switch result {
                case .success(let image):
                    if collectionView.indexPath(for: cell) == indexPath {
                        contentConfiguration.thumbnailImage = image
                        cell.contentConfiguration = contentConfiguration
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }

        cell.contentConfiguration = contentConfiguration
    }

    private func updateSnapshot(reloading changedProductIDs: [Product.ID] = [], animatingDifferences: Bool = true) {
        var snapshot = Snapshot()
        snapshot.appendSections([ProductListSection.main])
        snapshot.appendItems(productIDs)
        if changedProductIDs.isEmpty == false {
            snapshot.reloadItems(changedProductIDs)
        }
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }

    private func product(for id: Product.ID) -> Product? {
        return products.first(where: { $0.id == id })
    }

    @discardableResult
    private func updateOrInsertProducts(_ newProducts: [Product]) -> (updated: [Product.ID],
                                                                      inserted: [Product.ID]) {
        var updatedProductIDs = [Product.ID]()
        var insertedProductIDs = [Product.ID]()
        newProducts.forEach { product in
            if let index = products.firstIndex(where: { $0.id == product.id }) {
                products[index] = product
                updatedProductIDs.append(product.id)
            } else {
                products.append(product)
                insertedProductIDs.append(product.id)
            }
        }
        return (updatedProductIDs, insertedProductIDs)
    }
}

// MARK: - UICollectionViewDelegate

extension ProductListViewController {
    override func collectionView(_ collectionView: UICollectionView,
                                 willDisplay cell: UICollectionViewCell,
                                 forItemAt indexPath: IndexPath) {
        if indexPath.row == products.count - 1,
           isLoadingNewProducts == false {
            isLoadingNewProducts = true
            loadProducts(pageNumber: nextPageNumber, productsPerPage: Constants.productsPerPage)
        }
    }
}

// MARK: - Constants

extension ProductListViewController {
    private enum Constants {
        static let productsPerPage = 50
        static let placeholderImage = UIImage(systemName: "photo")
    }
}
