//
//  ProductInformationView.swift
//  OpenMarket
//
//  Created by Ayaan, junho on 2022/11/29.
//

import UIKit

final class ProductInformationView: UIView {
    private let nameTextField: NameTextField = NameTextField(minimumLength: 3, maximumLength: 100)
    private let priceTextField: NumberTextField = NumberTextField(placeholder: "상품가격")
    private let discountedPriceTextField: NumberTextField = NumberTextField(placeholder: "할인금액")
    private let stockTextField: NumberTextField = NumberTextField(placeholder: "재고수량")
    private let descriptionTextView: DescriptionTextView = DescriptionTextView(minimumLength: 10, maximumLength: 1000)
    private let currencySegmentedControl: UISegmentedControl = {
        let segmentedControl: UISegmentedControl = UISegmentedControl(items: ["KRW", "USD"])
        
        segmentedControl.selectedSegmentIndex = 0
        
        return segmentedControl
    }()
    private let imagePickerButton: UIButton = {
        let button: UIButton = UIButton(frame: .zero)
        
        button.setTitle("+", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.backgroundColor = .systemGray3
        
        return button
    }()
    private let imageStackView: ImageStackView = {
        let stackView: ImageStackView = ImageStackView()
        
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    private let priceAndCurrencyStackView: UIStackView = {
        let stackView: UIStackView = UIStackView()
        
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    private let contentStackView: UIStackView = {
        let stackView: UIStackView = UIStackView()
        
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    private let imageScrollView: UIScrollView = {
        let scrollView: UIScrollView = UIScrollView()
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.bounces = false
        
        return scrollView
    }()
    private let mainScrollView: UIScrollView = {
        let scrollView: UIScrollView = UIScrollView()
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.bounces = false
        
        return scrollView
    }()
    
    weak var textFieldDelegate: UITextFieldDelegate? {
        didSet { setUpTextFieldDelegate() }
    }
    weak var descriptionTextViewDelegate: UITextViewDelegate? {
        get { return descriptionTextView.delegate }
        set { descriptionTextView.delegate = newValue }
    }
    
    init() {
        super.init(frame: .zero)
        setUpViewsIfNeeded()
        setUpMainScrollView()
        setUpImageScrollView()
        setUpCurrencySegmentedControl()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpViewsIfNeeded() {
        backgroundColor = .white
        priceAndCurrencyStackView.addArrangedSubview(priceTextField)
        priceAndCurrencyStackView.addArrangedSubview(currencySegmentedControl)
        imageStackView.addArrangedSubview(imagePickerButton)
        imageScrollView.addSubview(imageStackView)
        contentStackView.addArrangedSubview(imageScrollView)
        contentStackView.addArrangedSubview(nameTextField)
        contentStackView.addArrangedSubview(priceAndCurrencyStackView)
        contentStackView.addArrangedSubview(discountedPriceTextField)
        contentStackView.addArrangedSubview(stockTextField)
        contentStackView.addArrangedSubview(descriptionTextView)
        
        mainScrollView.addSubview(contentStackView)
        addSubview(mainScrollView)
    }
    
    private func setUpMainScrollView() {
        let spacing: CGFloat = 10
        let safeArea: UILayoutGuide = safeAreaLayoutGuide
        
        let constraints: (width: NSLayoutConstraint, height: NSLayoutConstraint) = (
            width: contentStackView.widthAnchor.constraint(equalTo: mainScrollView.frameLayoutGuide.widthAnchor),
            height: contentStackView.heightAnchor.constraint(equalTo: mainScrollView.frameLayoutGuide.heightAnchor))
        constraints.height.priority = .init(rawValue: 1)
        
        NSLayoutConstraint.activate([
            mainScrollView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: spacing),
            mainScrollView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -spacing),
            mainScrollView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: spacing),
            mainScrollView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -spacing),
            contentStackView.topAnchor.constraint(equalTo: mainScrollView.contentLayoutGuide.topAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: mainScrollView.contentLayoutGuide.bottomAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: mainScrollView.contentLayoutGuide.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: mainScrollView.contentLayoutGuide.trailingAnchor),
            currencySegmentedControl.widthAnchor.constraint(equalTo: safeArea.widthAnchor, multiplier: 0.3),
            constraints.width,
            constraints.height
        ])
    }
    
    private func setUpImageScrollView() {
        let constraints: (width: NSLayoutConstraint, height: NSLayoutConstraint) = (
            width: imageStackView.widthAnchor.constraint(equalTo: imageScrollView.frameLayoutGuide.widthAnchor),
            height: imageStackView.heightAnchor.constraint(equalTo: imageScrollView.frameLayoutGuide.heightAnchor))
        constraints.width.priority = .init(rawValue: 1)
        
        NSLayoutConstraint.activate([
            imageScrollView.heightAnchor.constraint(equalToConstant: 150),
            imageStackView.topAnchor.constraint(equalTo: imageScrollView.contentLayoutGuide.topAnchor),
            imageStackView.bottomAnchor.constraint(equalTo: imageScrollView.contentLayoutGuide.bottomAnchor),
            imageStackView.leadingAnchor.constraint(equalTo: imageScrollView.contentLayoutGuide.leadingAnchor),
            imageStackView.trailingAnchor.constraint(equalTo: imageScrollView.contentLayoutGuide.trailingAnchor),
            constraints.width,
            constraints.height
        ])
    }
    
    private func setUpCurrencySegmentedControl() {
        currencySegmentedControl.setContentHuggingPriority(.defaultLow - 1, for: .vertical)
        currencySegmentedControl.setContentHuggingPriority(.defaultLow - 1, for: .horizontal)
    }
    
    private func setUpTextFieldDelegate() {
        nameTextField.delegate = textFieldDelegate
        priceTextField.delegate = textFieldDelegate
        discountedPriceTextField.delegate = textFieldDelegate
        stockTextField.delegate = textFieldDelegate
    }
}
