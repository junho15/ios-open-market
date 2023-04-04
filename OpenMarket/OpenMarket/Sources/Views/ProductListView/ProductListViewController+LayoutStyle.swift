import UIKit

extension ProductListViewController {
    enum LayoutStyle: Int {
        case list, grid

        var layout: UICollectionViewCompositionalLayout {
            switch self {
            case .list:
                return listLayout
            case .grid:
                return gridLayout
            }
        }

        private var listLayout: UICollectionViewCompositionalLayout {
            var listConfiguration = UICollectionLayoutListConfiguration(appearance: .plain)
            listConfiguration.backgroundColor = .systemBackground
            return UICollectionViewCompositionalLayout.list(using: listConfiguration)
        }

        private var gridLayout: UICollectionViewCompositionalLayout {
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .estimated(100))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .estimated(100))
            let group: NSCollectionLayoutGroup
            if #available(iOS 16.0, *) {
                group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 2)
            } else {
                group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
            }
            let spacing = CGFloat(10)
            group.interItemSpacing = .fixed(spacing)

            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = spacing
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)

            return UICollectionViewCompositionalLayout(section: section)
        }
    }
}
