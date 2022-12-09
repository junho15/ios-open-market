//
//  ProductDetailView.swift
//  OpenMarket
//
//  Created by Ayaan, junho on 2022/12/07.
//

import UIKit

final class ProductDetailView: UIView {
    private let collectionView: ImageCollectionView = {
        let imageCollectionView: ImageCollectionView = ImageCollectionView(frame: .zero, collectionViewLayout: .image)
        
        imageCollectionView.isPagingEnabled = true
        imageCollectionView.decelerationRate = .fast
        imageCollectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        return imageCollectionView
    }()
    private let nameLabel: UILabel = {
        let label: UILabel = UILabel()
        
        label.font = UIFont.preferredFont(forTextStyle: .title3,
                                          compatibleWith: UITraitCollection.init(preferredContentSizeCategory: .large))
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .left
        label.numberOfLines = 0
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    private let stockLabel: StockLabel = StockLabel()
    private let priceLabel: PriceLabel = PriceLabel()
    private let descriptionLabel: UILabel = {
        let label: UILabel = UILabel()
        
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .left
        label.numberOfLines = 0
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    private let stackView: UIStackView = {
        let stackView: UIStackView = UIStackView()
        
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    private let scrollView: UIScrollView = {
        let scrollView: UIScrollView = UIScrollView()
        
        scrollView.bounces = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        return scrollView
    }()
    private var product: Product? {
        didSet {
            setUpDataIfNeeded()
            setUpImages()
        }
    }
    private let semaphore: DispatchSemaphore = DispatchSemaphore(value: 0)
    
    init() {
        super.init(frame: .zero)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateWithProduct(_ newProduct: Product) {
        self.product = newProduct
    }
    
    private func configure() {
        setUpTextAlignment()
        setUpViewsIfNeeded()
    }
    
    private func setUpTextAlignment() {
        priceLabel.textAlignment = .right
        stockLabel.textAlignment = .right
    }
    
    private func setUpViewsIfNeeded() {
        backgroundColor = .white
        let spacing: CGFloat = 10
        stackView.addArrangedSubview(collectionView)
        stackView.addArrangedSubview(nameLabel)
        stackView.addArrangedSubview(priceLabel)
        stackView.addArrangedSubview(stockLabel)
        stackView.addArrangedSubview(descriptionLabel)
        scrollView.addSubview(stackView)
        addSubview(scrollView)
                
        let contentStackViewSizeConstraints: (width: NSLayoutConstraint, height: NSLayoutConstraint) = (stackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor), stackView.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor))
        
        contentStackViewSizeConstraints.height.priority = .init(rawValue: 1)
        
        NSLayoutConstraint.activate([
            collectionView.heightAnchor.constraint(lessThanOrEqualTo: stackView.widthAnchor, multiplier: 0.8),
            scrollView.topAnchor.constraint(equalTo: topAnchor,
                                           constant: spacing),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor,
                                              constant: -spacing),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor,
                                               constant: spacing),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor,
                                                constant: -spacing),
            scrollView.topAnchor.constraint(equalTo: stackView.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: stackView.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            contentStackViewSizeConstraints.width,
            contentStackViewSizeConstraints.height
        ])
    }
    
    private func setUpDataIfNeeded() {
        guard let product: Product = product,
              let bargainPrice: Double = product.bargainPrice else {
            return
        }
        
        nameLabel.text = product.name
        stockLabel.stock = product.stock
        priceLabel.setPrice(product.price,
                            bargainPrice: bargainPrice,
                            currency: product.currency,
                            style: .grid)
        descriptionLabel.text = product.description
    }
    
    private func setUpImages() {
        guard let product: Product = product,
        let images: [ProductImage] = product.images else {
            return
        }
        
        var imageParser: ImageParser = ImageParser()
        DispatchQueue.global().async {
            images.forEach {
                imageParser.parse($0.url) { image in
                    DispatchQueue.main.async {
                        self.collectionView.appendImage(image)
                    }
                    self.semaphore.signal()
                }
                self.semaphore.wait()
            }
        }
    }
}
