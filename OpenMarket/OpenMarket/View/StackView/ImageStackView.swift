//
//  ImageStackView.swift
//  OpenMarket
//
//  Created by Ayaan, junho on 2022/11/29.
//

import UIKit

final class ImageStackView: UIStackView {
    override func addArrangedSubview(_ view: UIView) {
        super.addArrangedSubview(view)
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalTo: heightAnchor),
            view.widthAnchor.constraint(equalTo: view.heightAnchor)
        ])
    }
    
    override func insertArrangedSubview(_ view: UIView, at stackIndex: Int) {
        super.insertArrangedSubview(view, at: stackIndex)
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalTo: heightAnchor),
            view.widthAnchor.constraint(equalTo: view.heightAnchor)
        ])
    }
}
