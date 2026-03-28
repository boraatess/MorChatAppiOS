//
//  FreeTokenBannerView.swift
//  MorChatApp
//
//  Created by bora ateş on 12.02.2026.
//

import Foundation
import UIKit
import SnapKit

final class FreeTokenBannerView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {

        layer.cornerRadius = 20
        clipsToBounds = true

        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor.systemOrange.cgColor,
            UIColor.systemPurple.cgColor
        ]
        layer.insertSublayer(gradient, at: 0)

        gradient.frame = bounds
        gradient.cornerRadius = 20

        let title = UILabel()
        title.text = "Ücretsiz Jeton Fırsatı"
        title.textColor = .white
        title.font = .boldSystemFont(ofSize: 18)

        addSubview(title)

        title.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.sublayers?.first?.frame = bounds
    }
}
