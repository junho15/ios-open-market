import UIKit

final class ProductEditorViewController: UICollectionViewController {

    // MARK: Properties

    private var isAdding: Bool
    private var product: Product
    private var onChange: (Product) -> Void

    // MARK: View Lifecycle

    init(isAdding: Bool, product: Product, onChange: @escaping (Product) -> Void) {
        self.isAdding = isAdding
        self.product = product
        self.onChange = onChange

        let configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        let collectionViewLayout = UICollectionViewCompositionalLayout.list(using: configuration)
        super.init(collectionViewLayout: collectionViewLayout)
        view.backgroundColor = .systemBackground
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

    }
}
