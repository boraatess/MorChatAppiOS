//
//  OnboardingPageView.swift
//  MorChatApp
//
//  Created by bora ateş on 9.02.2026.
//

import Foundation
import UIKit
import SnapKit

struct OnboardingItem {
    let iconName: String
    let title: String
    let description: String
}


final class OnboardingPageView: UIView {

    private let circleView = UIView()
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let descLabel = UILabel()

    init(item: OnboardingItem) {
        super.init(frame: .zero)
        setupUI()
        configure(item)
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        addSubview(circleView)
        addSubview(iconView)
        addSubview(titleLabel)
        addSubview(descLabel)

        circleView.layer.cornerRadius = 120
        circleView.clipsToBounds = true

        iconView.tintColor = .white
        iconView.contentMode = .scaleAspectFit

        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2

        descLabel.textColor = UIColor.white.withAlphaComponent(0.85)
        descLabel.font = .systemFont(ofSize: 16)
        descLabel.textAlignment = .center
        descLabel.numberOfLines = 0

        circleView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(140)
            $0.width.height.equalTo(240)
        }

        iconView.snp.makeConstraints {
            $0.center.equalTo(circleView)
            $0.width.height.equalTo(80)
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(circleView.snp.bottom).offset(40)
            $0.left.right.equalToSuperview().inset(24)
        }

        descLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(16)
            $0.left.right.equalToSuperview().inset(32)
        }
    }

    private func configure(_ item: OnboardingItem) {
        iconView.image = UIImage(systemName: item.iconName)
        titleLabel.text = item.title
        descLabel.text = item.description
        applyCircleGradient()
    }

    private func applyCircleGradient() {
        let g = CAGradientLayer()
        g.colors = [
            UIColor(red: 255/255, green: 128/255, blue: 171/255, alpha: 1).cgColor,
            UIColor(red: 186/255, green: 104/255, blue: 200/255, alpha: 1).cgColor
        ]
        g.frame = CGRect(x: 0, y: 0, width: 240, height: 240)
        g.cornerRadius = 120
        circleView.layer.insertSublayer(g, at: 0)
    }
}
