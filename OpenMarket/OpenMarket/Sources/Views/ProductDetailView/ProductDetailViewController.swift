import UIKit

class ProductDetailViewController: UIViewController {

    // MARK: Properties

    private let onChange: (Product?) -> Void
    private let imageLoader = ImageLoader()
    private var dataSource: DataSource!
    private var product: Product
    private var images: [UIImage] = []
    private var lastVisibleIndex: Int = -1

    // MARK: IBOutlets

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageIndicatorLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var stockLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!

    // MARK: View Lifecycle

    init(coder: NSCoder, product: Product, onChange: @escaping (Product?) -> Void) {
        self.product = product
        self.onChange = onChange
        super.init(coder: coder)!
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        configureDatasource()
        loadImages()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationItem()
        configureSubviewsText()
        navigationController?.isToolbarHidden = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isToolbarHidden = true
    }

    // MARK: IBActions

    @IBAction func editBarButtonItemTapped(_ sender: UIBarButtonItem) {
    }

    @IBAction func deleteBarButtonItemTapped(_ sender: UIBarButtonItem) {
    }
}

// MARK: - Methods

extension ProductDetailViewController {
    private func configureCollectionView() {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .fractionalHeight(1.0))
        let group: NSCollectionLayoutGroup
        if #available(iOS 16.0, *) {
            group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 1)
        } else {
            group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        }
        let spacing = CGFloat(10)
        group.interItemSpacing = .fixed(spacing)

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .paging
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
        section.interGroupSpacing = spacing
        section.visibleItemsInvalidationHandler = { [weak self] visibleItems, _, _ in
            guard let self,
                  let index = visibleItems.last?.indexPath.item,
                  lastVisibleIndex != index else { return }
            lastVisibleIndex = index
            self.updatePageIndicatorLabel(currentPage: index + 1)
        }

        let layout = UICollectionViewCompositionalLayout(section: section)
        collectionView.collectionViewLayout = layout
    }

    private func updatePageIndicatorLabel(currentPage: Int) {
        var text: String?
        let totalPageCount = collectionView.numberOfItems(inSection: 0)
        if totalPageCount > 0 {
            text = "\(currentPage)/\(totalPageCount)"
        }
        pageIndicatorLabel.text = text
    }

    private func configureDatasource() {
        let cellRegistration = UICollectionView.CellRegistration(handler: cellRegistrationHandler)
        dataSource = DataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, image in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: image)
        })
    }

    private func loadImages() {
        guard let productImages = product.images else { return }
        let URLs = productImages.map { $0.url }
        let validURLs = URLs.compactMap { URL(string: $0) }
        var loadedImages: [URL: UIImage] = [:]
        let dispatchGroup = DispatchGroup()

        validURLs.forEach { url in
            print(url.description)
            dispatchGroup.enter()
            imageLoader.loadImage(from: url) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let image):
                        loadedImages[url] = image
                    case .failure(let error):
                        print(error)
                    }
                    dispatchGroup.leave()
                }
            }
        }

        dispatchGroup.notify(queue: .main) { [weak self] in
            guard let self else { return }
            self.images = validURLs.compactMap { loadedImages[$0] }
            updateSnapshot()
        }
    }

    private func configureNavigationItem() {
        navigationItem.title = product.name
    }

    private func configureSubviewsText() {
        nameLabel.text = product.name
        priceLabel.attributedText = ProductAttributedStringMaker.twoLinePrice(
            currency: product.currency,
            price: product.price ?? 0,
            bargainPrice: product.bargainPrice ?? 0,
            font: UIFont.preferredFont(forTextStyle: .body)
        ).attributedString
        stockLabel.attributedText = ProductAttributedStringMaker.stock(
            stock: product.stock ?? 0,
            font: UIFont.preferredFont(forTextStyle: .body)
        ).attributedString
        descriptionTextView.text = product.description
    }
}

// MARK: - DataSource

extension ProductDetailViewController {
    typealias DataSource = UICollectionViewDiffableDataSource<Section, UIImage>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, UIImage>

    private func cellRegistrationHandler(cell: UICollectionViewCell, indexPath: IndexPath, image: UIImage) {
        var contentConfiguration = cell.imageConfiguration()
        contentConfiguration.image = image
        cell.contentConfiguration = contentConfiguration
    }

    private func updateSnapshot() {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(images)
        dataSource.apply(snapshot)
    }
}
