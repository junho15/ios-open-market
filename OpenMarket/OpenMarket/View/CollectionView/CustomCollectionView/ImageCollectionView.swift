//
//  ImagePickerCollectionView.swift
//  OpenMarket
//
//  Created by Ayaan, junho on 2022/11/30.
//

import UIKit

final class ImageCollectionView: UICollectionView {
    private var imagePickerCellRegistration: UICollectionView.CellRegistration<ImagePickerCell, UIView>?
    private var imagePickerDataSource: UICollectionViewDiffableDataSource<Section, UIView>?
    
    init(frame: CGRect, collectionViewLayout layout: CollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: LayoutMaker.make(of: layout))
        registerCell()
        configureDataSource()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //MARK: - Snapshot
    func applySnapshot(_ snapshot: NSDiffableDataSourceSnapshot<Section, UIView>) {
        imagePickerDataSource?.apply(snapshot, animatingDifferences: true)
    }
    
    func fetchSnapshot() -> NSDiffableDataSourceSnapshot<Section, UIView>? {
        return imagePickerDataSource?.snapshot()
    }
    //MARK: - Cell
    private func registerCell() {
        imagePickerCellRegistration = UICollectionView.CellRegistration<ImagePickerCell, UIView> { (cell, indexPath, view) in
            cell.addContentView(view)
        }
    }
    //MARK: - DataSource
    private func configureDataSource() {
        guard let imageCellRegistration = imagePickerCellRegistration else {
            return
        }
        
        imagePickerDataSource = UICollectionViewDiffableDataSource<Section, UIView>(collectionView: self) { (collectionView: UICollectionView, indexPath: IndexPath, view: UIView) -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(using: imageCellRegistration, for: indexPath, item: view)
        }
    }
    
    func appendImage(_ image: UIImage?) {
        guard let image: UIImage = image else {
            return
        }
        
        var snapshot: NSDiffableDataSourceSnapshot<Section, UIView> = .init()
        snapshot.appendSections([.main])
        if let currentSnapshot: NSDiffableDataSourceSnapshot<Section, UIView> = imagePickerDataSource?.snapshot(),
            currentSnapshot.numberOfItems > 0 {
            snapshot.appendItems(currentSnapshot.itemIdentifiers)
            snapshot.deleteItems([UIImageView(image: image)])
        }
        snapshot.appendItems([UIImageView(image: image)])
        
        imagePickerDataSource?.apply(snapshot)
    }
}
