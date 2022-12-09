//
//  ProductUpdateViewController.swift
//  OpenMarket
//
//  Created by Ayaan on 2022/12/09.
//

import UIKit

protocol ProductUpdateDelegate: AnyObject {
    func productUpdate(didUpdate: Bool, _ product: Product?)
}

final class ProductUpdateViewController: ProductManagementViewController {
    private let productUpdateTitle: String = "상품수정"
    private var doneWorkItem: DispatchWorkItem? = nil
    private var productID: Int? = nil
    weak var productUpdateDelegate: ProductUpdateDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    func setUpContentData(of newProduct: Product, with imagesSnapshot: NSDiffableDataSourceSnapshot<Section, UIView>) {
        self.productID = newProduct.id
        self.nameTextField.text = newProduct.name
        self.currencySegmentedControl.selectedSegmentIndex = newProduct.currency == .krw ? 0 : 1
        self.priceTextField.text = "\(newProduct.price)"
        self.discountedPriceTextField.text = "\(newProduct.discountedPrice)"
        self.stockTextField.text = "\(newProduct.stock)"
        self.descriptionTextView.text = newProduct.description
        imageCollectionView.applySnapshot(imagesSnapshot)
    }
    
    private func configure() {
        setUpNavigationBarButton()
        title = productUpdateTitle
        doneBarButtonItem?.isEnabled = true
    }
    
    private func setUpNavigationBarButton() {
        doneBarButtonItem?.action = #selector(tappedDoneButton)
        cancelBarButtonItem?.action = #selector(tappedCancelButton)
        
        navigationItem.setRightBarButton(doneBarButtonItem, animated: false)
        navigationItem.setLeftBarButton(cancelBarButtonItem, animated: false)
    }
    
    private func showResultAlert(isSuccess: Bool) {
        let title: String = isSuccess ? "상품 수정 성공" : "상품 수정 실패"
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
    
    @objc
    private func tappedCancelButton(_ sender: UIButton) {
        productUpdateDelegate?.productUpdate(didUpdate: false, nil)
        self.navigationController?.popViewController(animated: false)
    }

    @objc
    private func tappedDoneButton(_ sender: UIBarButtonItem) {
        guard doneWorkItem == nil,
              let product: ProductToRequest = makeProductByInputedData(with: productID) else {
            return
        }
        let workItem: DispatchWorkItem = DispatchWorkItem {
            let registrationManager: NetworkManager = .init(openMarketAPI: .update(product: product))
            registrationManager.network { data, error in
                if let error = error {
                    DispatchQueue.main.async { [weak self] in
                        print(error.localizedDescription)
                        self?.doneWorkItem = nil
                        self?.showResultAlert(isSuccess: false)
                    }
                } else if let data = data, let product: Product = try? JSONDecoder().decode(Product.self, from: data) {
                    DispatchQueue.main.async { [weak self] in
                        self?.doneWorkItem = nil
                        self?.productUpdateDelegate?.productUpdate(didUpdate: true, product)
                        self?.showResultAlert(isSuccess: true)
                    }
                }
            }
        }
        
        doneWorkItem = workItem
        DispatchQueue.global().async(execute: workItem)
    }
}
