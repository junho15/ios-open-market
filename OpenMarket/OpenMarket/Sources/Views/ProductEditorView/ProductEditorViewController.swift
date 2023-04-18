import UIKit
import Photos
import PhotosUI

final class ProductEditorViewController: UICollectionViewController {

    // MARK: Properties

    private let editMode: EditMode
    private let openMarketAPIClient: OpenMarketAPIClient
    private let imageLoader: ImageLoader
    private let onChange: (Product?) -> Void
    private var dataSource: DataSource!
    private var product: Product
    private var images: [UIImage] = []
    private var isPickingImage: Bool = false

    // MARK: View Lifecycle

    init(coder: NSCoder,
         product: Product,
         editMode: EditMode,
         openMarketAPIClient: OpenMarketAPIClient = OpenMarketAPIClient(),
         imageLoader: ImageLoader = ImageLoader(),
         onChange: @escaping (Product?) -> Void) {
        self.product = product
        self.editMode = editMode
        self.openMarketAPIClient = openMarketAPIClient
        self.imageLoader = imageLoader
        self.onChange = onChange
        super.init(coder: coder)!
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        configureNavigationItem()
        configureDataSource()
        updateSnapshot()
        loadImages()
    }
}

// MARK: - Methods

extension ProductEditorViewController {
    private func configureCollectionView() {
        let configuration = UICollectionLayoutListConfiguration(appearance: .plain)
        let layout = UICollectionViewCompositionalLayout.list(using: configuration)
        collectionView.collectionViewLayout = layout
    }

    private func configureNavigationItem() {
        navigationItem.title = String(describing: editMode)
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            systemItem: .cancel,
            primaryAction: UIAction(handler: { [weak self] _ in
                guard let self else { return }
                onChange(nil)
            }))
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            systemItem: .done,
            primaryAction: UIAction(handler: doneButtonActionHandler)
        )
    }

    private func doneButtonActionHandler(action: UIAction) {
        let alertPresenter = AlertPresenter()
        switch validateProduct(product, images: images) {
        case .success:
            switch editMode {
            case .add:
                openMarketAPIClient.createProduct(product: product, images: images) { [weak self] result in
                    guard let self else { return }
                    switch result {
                    case .success(let product):
                        self.onChange(product)
                    case .failure(let error):
                        alertPresenter.showAlert(title: error.localizedDescription, message: nil, in: self)
                    }
                }
            case .edit:
                openMarketAPIClient.updateProduct(product: product) { [weak self] result in
                    guard let self else { return }
                    switch result {
                    case .success(let product):
                        self.onChange(product)
                    case .failure(let error):
                        alertPresenter.showAlert(title: error.localizedDescription, message: nil, in: self)
                    }
                }
            }
        case .failure(let error):
            alertPresenter.showAlert(title: error.localizedDescription, message: nil, in: self)
            return
        }
    }

    private func validateProduct(_ product: Product, images: [UIImage]) -> Result<Void, ProductValidationError> {
        guard product.name.count >= 3,
              product.name.count <= 100 else {
            return .failure(.invalidName)
        }
        guard let price = product.price,
              price >= 0 else {
            return .failure(.invalidPrice)
        }
        guard let discountedPrice = product.discountedPrice,
              discountedPrice >= 0,
              discountedPrice <= price else {
            return .failure(.invalidDiscountedPrice)
        }
        guard product.stock != nil else {
            return .failure(.invalidStock)
        }
        guard product.description.count >= 10,
              product.description.count <= 1000 else {
            return .failure(.invalidDescription)
        }
        return .success(())
    }

    private func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration(handler: cellRegistrationHandler)
        dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, row in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: row)
        }
    }

    private func configureTapGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGestureRecognizer.cancelsTouchesInView = false
        collectionView.addGestureRecognizer(tapGestureRecognizer)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    private func loadImages() {
        guard let productImages = product.images else { return }
        let URLs = productImages.map { $0.url }
        let validURLs = URLs.compactMap { URL(string: $0) }
        var loadedImages: [URL: UIImage] = [:]
        let dispatchGroup = DispatchGroup()

        validURLs.forEach { url in
            dispatchGroup.enter()
            imageLoader.loadImage(from: url) { result in
                switch result {
                case .success(let image):
                    loadedImages[url] = image
                case .failure(let error):
                    print(error)
                }
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) { [weak self] in
            guard let self else { return }
            self.images = validURLs.compactMap { loadedImages[$0] }
            updateSnapshot()
        }
    }

    private func presentPicker() {
        guard isPickingImage == false else { return }
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.filter = PHPickerFilter.images
        configuration.preferredAssetRepresentationMode = .current

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }
}

// MARK: - DataSource

extension ProductEditorViewController {
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, Row>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Row>

    private func updateSnapshot() {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        let canAdd = editMode == .add && images.count < 5
        snapshot.appendItems([
            .images(images: images, canAdd: canAdd),
            .name(text: product.name),
            .priceCurrency(price: product.price, currency: product.currency),
            .discountedPrice(discountedPrice: product.discountedPrice),
            .stock(stock: product.stock),
            .description(text: product.description)
        ])
        dataSource.apply(snapshot)
    }

    private func cellRegistrationHandler(cell: UICollectionViewListCell, indexPath: IndexPath, row: Row) {
        let placeholder = String(describing: row)
        switch row {
        case .images(let images, let canAdd):
            cell.contentConfiguration = imagesConfiguration(for: cell, images: images, canAdd: canAdd)
        case .name(let text):
            cell.contentConfiguration = nameConfiguration(for: cell, name: text, placeholder: placeholder)
        case .priceCurrency(let price, let currency):
            cell.contentConfiguration = priceCurrencyConfiguration(for: cell,
                                                                   price: price,
                                                                   currency: currency,
                                                                   placeholder: placeholder)
        case .discountedPrice(let discountedPrice):
            cell.contentConfiguration = discountedPriceConfiguration(for: cell,
                                                                     discountedPrice: discountedPrice,
                                                                     placeholder: placeholder)
        case .stock(let stock):
            cell.contentConfiguration = stockConfiguration(for: cell, stock: stock, placeholder: placeholder)
        case .description(let text):
            cell.contentConfiguration = descriptionConfiguration(for: cell, description: text)
        }
    }

    private func imagesConfiguration(for cell: UICollectionViewCell,
                                     images: [UIImage],
                                     canAdd: Bool) -> UIContentConfiguration {
        var contentConfiguration = cell.collectionViewConfiguration()
        contentConfiguration.images = images
        contentConfiguration.canAdd = canAdd
        contentConfiguration.onClick = { [weak self] in
            guard let self else { return }
            presentPicker()
        }
        return contentConfiguration
    }

    private func nameConfiguration(for cell: UICollectionViewCell,
                                   name: String,
                                   placeholder: String? = nil) -> UIContentConfiguration {
        var contentConfiguration = cell.textFieldConfiguration()
        contentConfiguration.text = name
        contentConfiguration.placeholder = placeholder
        contentConfiguration.onChange = { [weak self] name in
            guard let self else { return }
            product.name = name
        }
        return contentConfiguration
    }

    private func priceCurrencyConfiguration(for cell: UICollectionViewCell,
                                            price: Double?,
                                            currency: Currency,
                                            placeholder: String? = nil) -> UIContentConfiguration {
        var contentConfiguration = cell.numberSegmentConfiguration()
        contentConfiguration.number = price
        contentConfiguration.placeholder = placeholder
        contentConfiguration.segmentsTitle = Currency.allCases.map { $0.rawValue }
        contentConfiguration.selectedSegmentIndex = currency.index
        contentConfiguration.onChangeNumber = { [weak self] price in
            guard let self else { return }
            product.price = price
        }
        contentConfiguration.onChangeSegment = { [weak self] index in
            guard let self,
                  let currency = Currency.currency(for: index) else { return }
            product.currency = currency
        }
        return contentConfiguration
    }

    private func discountedPriceConfiguration(for cell: UICollectionViewCell,
                                              discountedPrice: Double?,
                                              placeholder: String? = nil) -> UIContentConfiguration {
        var contentConfiguration = cell.doubleNumberConfiguration()
        contentConfiguration.number = discountedPrice
        contentConfiguration.placeholder = placeholder
        contentConfiguration.onChange = { [weak self] discountedPrice in
            guard let self else { return }
            product.discountedPrice = discountedPrice
        }
        return contentConfiguration
    }

    private func stockConfiguration(for cell: UICollectionViewCell,
                                    stock: Int?,
                                    placeholder: String? = nil) -> UIContentConfiguration {
        var contentConfiguration = cell.intNumberConfiguration()
        contentConfiguration.number = stock
        contentConfiguration.placeholder = placeholder
        contentConfiguration.onChange = { [weak self] stock in
            guard let self else { return }
            product.stock = stock
        }
        return contentConfiguration
    }

    private func descriptionConfiguration(for cell: UICollectionViewCell,
                                          description: String) -> UIContentConfiguration {
        var contentConfiguration = cell.textViewConfiguration()
        contentConfiguration.text = description
        contentConfiguration.onChange = { [weak self] description in
            guard let self else { return }
            product.description = description
        }
        return contentConfiguration
    }
}

// MARK: - PHPickerViewControllerDelegate

extension ProductEditorViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: false)

        if let result = results.first,
           result.itemProvider.canLoadObject(ofClass: UIImage.self) {
            result.itemProvider.loadDataRepresentation(
                forTypeIdentifier: "public.image"
            ) { [weak self] imageData, error in
                guard let self else { return }
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    if let error {
                        let alertPresenter = AlertPresenter()
                        alertPresenter.showAlert(title: error.localizedDescription, message: nil, in: self)
                        return
                    }
                    if let imageData,
                       let image = UIImage(data: imageData) {
                        isPickingImage = true
                        image.limitSize(maxSizeInKb: 300) { [weak self] limitedImage in
                            guard let self else { return }
                            isPickingImage = false
                            guard let limitedImage else { return }
                            self.images.append(limitedImage)
                            self.updateSnapshot()
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Constants

extension ProductEditorViewController {
    private enum Constants {
        static let placeholderImage = UIImage(systemName: "photo")
    }
}
