//
//  OpenMarket - ViewController.swift
//  Created by yagom. 
//  Copyright © yagom. All rights reserved.
// 

import UIKit

final class ProductListViewController: UIViewController {
    //MARK: - Properties
    private let segmentedControl: LayoutSegmentedControl = .init()
    private var collectionView: OpenMarketCollectionView!
    private var currentPage: Int = 1
    private let productPerPage: Int = 20
    private var hasNextPage: Bool = true
    private var indicatorView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViewsIfNeeded()
        self.title = ""
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        refreshData(nil)
    }
    
    //MARK: - set Up View Method
    private func setUpViewsIfNeeded() {
        setSegmentedControl()
        setRightBarButton()
        setCollectionView()
        setIndicatorView()
        setUpRefreshControl()
    }
    
    func setUpRefreshControl() {
        let refreshControl: UIRefreshControl = .init()
     
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        
        collectionView.refreshControl = refreshControl
    }
    
    private func setSegmentedControl() {
        navigationItem.titleView = segmentedControl
        segmentedControl.addTarget(self,
                                   action: #selector(layoutSegmentedControlValueChanged),
                                   for: .valueChanged)
    }
    
    private func setRightBarButton() {
        let barButton: UIBarButtonItem = UIBarButtonItem(title: "+",
                                                         style: .plain,
                                                         target: self,
                                                         action: #selector(tappedAddProductButton))
        
        barButton.tintColor = .systemBlue
        navigationItem.setRightBarButton(barButton, animated: false)
    }
    
    private func setCollectionView() {
        collectionView = OpenMarketCollectionView(frame: view.bounds,
                                                  collectionViewLayout: CollectionViewLayout.defaultLayout)
        collectionView.backgroundColor = .white
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.delegate = self
        collectionView.openMarketDelegate = self
        view.addSubview(collectionView)
    }
    
    private func setIndicatorView() {
        let indicatorView: UIView = .init(frame: view.bounds)
        indicatorView.backgroundColor = .systemGray6
        
        let indicator: UIActivityIndicatorView = .init(style: .large)
        indicator.center = indicatorView.center
        indicator.startAnimating()
        indicatorView.addSubview(indicator)
        
        view.addSubview(indicatorView)
        self.indicatorView = indicatorView
    }
    
    private func removeIndicatorView() {
        indicatorView?.removeFromSuperview()
        indicatorView = nil
    }
    //MARK: - objc Method
    @objc
    private func layoutSegmentedControlValueChanged(_ sender: UISegmentedControl) {
        let list: Int = 0
        let grid: Int = 1
        
        switch sender.selectedSegmentIndex {
        case list:
            collectionView.updateLayout(of: .list)
        case grid:
            collectionView.updateLayout(of: .grid)
        default:
            return
        }
        collectionView.reloadData()
    }
    
    @objc
    private func tappedAddProductButton(_ sender: UIBarButtonItem) {
        navigationController?.pushViewController(ProductRegistrationViewController(), animated: false)
    }
    
    @objc
    private func refreshData(_ sender: UIRefreshControl?) {
        reset()
        fetchPage()
    }
    
    private func reset() {
        currentPage = 1
        hasNextPage = true
    }
    
    //MARK: - Snapshot Apply Method
    private func fetchPage() {
        guard hasNextPage == true else { return }
        let networkManger: NetworkManager = .init(openMarketAPI: .fetchPage(pageNumber: currentPage,
                                                                            productsPerPage: productPerPage))
        networkManger.network { [weak self] (data, error) in
            if let error = error {
                print(error.localizedDescription)
            } else if let data = data, let page = try? JSONDecoder().decode(Page.self, from: data){
                self?.hasNextPage = page.hasNextPage
                self?.currentPage = page.number + 1
                DispatchQueue.main.async {
                    self?.collectionView.applyDataSource(using: page)
                    self?.removeIndicatorView()
                }
            }
        }
    }
    
    private func pushDetailView(of productNumber: Int) {
        fetchProduct(of: productNumber) { [weak self] product in
            if let product = product {
                let nextViewController: ProductDetailViewController = .init()
                nextViewController.setUpProduct(product)
                self?.navigationController?.pushViewController(nextViewController, animated: false)
            }
        }
    }
    
    private func fetchProduct(of productNumber: Int, completion: @escaping (Product?) -> Void) {
        let networkManger: NetworkManager = .init(openMarketAPI: .fetchProduct(productNumber: productNumber))
        networkManger.network { (data, error) in
            if let error = error {
                print(error.localizedDescription)
                completion(nil)
            } else if let data = data, let product: Product = try? JSONDecoder().decode(Product.self, from: data) {
                DispatchQueue.main.async {
                    completion(product)
                }
            }
        }
    }
}
//MARK: - Extension UICollectionViewDelegate
extension ProductListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        if let productNumber: Int = self.collectionView.fetchProductNumber(of: indexPath) {
            pushDetailView(of: productNumber)
        }
    }
}
extension ProductListViewController: OpenMarketCollectionViewDelegate {
    func openMarketCollectionView(didRequestNextPage: Bool){
        self.fetchPage()
    }
}
