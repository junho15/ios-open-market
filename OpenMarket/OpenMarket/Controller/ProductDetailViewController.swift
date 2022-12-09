//
//  ProductDetailViewController.swift
//  OpenMarket
//
//  Created by Ayaan, junho on 2022/12/07.
//

import UIKit

final class ProductDetailViewController: UIViewController {
    private let productDetailView: ProductDetailView = ProductDetailView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
    }
    
    func setUpProduct(_ product: Product) {
        self.title = product.name
        productDetailView.updateWithProduct(product)
        fetchImages(from: product.images) { images in
            DispatchQueue.main.async {
                self.productDetailView.setUpImages(images: images.compactMap {
                    UIImageView(image: $0)
                })
            }
        }
    }
    
    private func configure() {
        view.backgroundColor = .white
        setUpView()
        setUpNavigationBarButton()
    }
    
    private func setUpView() {
        productDetailView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(productDetailView)
        
        let safeArea: UILayoutGuide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            productDetailView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            productDetailView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            productDetailView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            productDetailView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor)
        ])
    }
    
    private func setUpNavigationBarButton() {
        let editBarButtonItem: UIBarButtonItem = .init(title: "",
                                                       style: .plain,
                                                       target: self,
                                                       action: #selector(showEditActionSheet))
        
        editBarButtonItem.image = UIImage(systemName: "ellipsis")
        
        
        navigationItem.setRightBarButton(editBarButtonItem, animated: false)
    }
    
    private func fetchImages(from productImages: [ProductImage]?, completion: @escaping ([UIImage]) -> Void) {
        if let productImages = productImages {
            var imageContainer: [UIImage] = []
            var imageParser: ImageParser = ImageParser()
            let imageSemaphore: DispatchSemaphore = .init(value: 0)
            DispatchQueue.global().async {
                productImages.forEach {
                    imageParser.parse($0.url) { image in
                        if let image = image {
                            imageContainer.append(image)
                        }
                        imageSemaphore.signal()
                    }
                    imageSemaphore.wait()
                }
                completion(imageContainer)
            }
        }
    }
    
    
    @objc
    private func showEditActionSheet(_ sender: UIBarButtonItem) {
        let editActionSheetController: UIAlertController = .init(title: nil,
                                                                 message: nil,
                                                                 preferredStyle: .actionSheet)
        let updateAction: UIAlertAction = .init(title: "수정",
                                              style: .default) { [weak self] (_) in
            self?.updateProduct()
        }
        let deleteAction: UIAlertAction = .init(title: "삭제",
                                                style: .destructive) { (_) in
            self.deleteProduct { result in
                DispatchQueue.main.async { [weak self] in
                    switch result {
                    case .success:
                        self?.showDeleteResultAlert(isSuccess: true)
                    case .failure:
                        self?.showDeleteResultAlert(isSuccess: false)
                    }
                }
            }
        }
        let cancelAction: UIAlertAction = .init(title: "취소", style: .cancel)
        
        editActionSheetController.addAction(updateAction)
        editActionSheetController.addAction(deleteAction)
        editActionSheetController.addAction(cancelAction)
        
        present(editActionSheetController, animated: true)
    }

    private func deleteProduct(completion: @escaping (Result<Product, Error>) -> Void) {
        guard let product: Product = productDetailView.fetchProduct(),
              let productID: Int = product.id else {
            return
        }
        let networkManager: NetworkManager = .init(openMarketAPI: .inquiryDeregistrationURI(productId: productID))
        networkManager.network { (data, error) in
            if let error = error {
                print(error.localizedDescription)
                completion(.failure(error))
            } else if let data = data, let deleteURI: String = String(data: data, encoding: .utf8) {
                let deregistrationNetworkManager: NetworkManager = .init(openMarketAPI: .deregistration(URI: deleteURI))
                deregistrationNetworkManager.network { (data, error) in
                    if let error = error {
                        print(error.localizedDescription)
                        completion(.failure(error))
                    } else if let data = data,
                              let product: Product = try? JSONDecoder().decode(Product.self, from: data) {
                        completion(.success(product))
                    }
                }
            }
        }
    }
    
    private func updateProduct() {
        guard let product: Product = productDetailView.fetchProduct(),
              let imageSnapshot: NSDiffableDataSourceSnapshot<Section, UIView> = productDetailView.fetchImageSnapshot() else {
            return
        }
        
        let updateViewController: ProductUpdateViewController = .init()
        updateViewController.setUpContentData(of: product, with: imageSnapshot)
        updateViewController.productUpdateDelegate = self
        navigationController?.pushViewController(updateViewController, animated: false)
    }
    
    private func showDeleteResultAlert(isSuccess: Bool) {
        let title: String = isSuccess ? "상품 삭제 성공" : "상품 삭제 실패"
        let resultAlertController: UIAlertController = .init(title: title,
                                                             message: nil,
                                                             preferredStyle: .alert)
        let alertAction: UIAlertAction
        
        if isSuccess {
            alertAction = UIAlertAction(title: "확인", style: .cancel) { [weak self] (_) in
                self?.navigationController?.popViewController(animated: false)
            }
        } else {
            alertAction = UIAlertAction(title: "확인", style: .cancel)
        }
        resultAlertController.addAction(alertAction)
        
        present(resultAlertController, animated: true)
    }
}

extension ProductDetailViewController: ProductUpdateDelegate {
    func productUpdate(didUpdate: Bool, _ product: Product?) {
        if didUpdate, let product = product {
            setUpProduct(product)
        } else {
            productDetailView.collectionView.reloadData()
        }
    }
}
