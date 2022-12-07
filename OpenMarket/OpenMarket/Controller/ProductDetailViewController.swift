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
    
    private func configure() {
        view.backgroundColor = .white
        setUpView()
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
    
    func setUpProduct(_ product: Product) {
        productDetailView.updateWithProduct(product)
    }
}
