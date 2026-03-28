//
//  FreeTokenCell.swift
//  MorChatApp
//
//  Created by bora ateş on 12.02.2026.
//

import Foundation
import UIKit
import SnapKit


final class FreeTokenCell: UITableViewCell {

    static let identifier = "FreeTokenCell"

    private let containerView = UIView()
    private let titleLabel = UILabel()
    private let descLabel = UILabel()
    private let gradientLayer = CAGradientLayer()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {

        selectionStyle = .none
        backgroundColor = .clear

        containerView.clipsToBounds = true
        containerView.backgroundColor = UIColor(red: 0.16, green: 0.08, blue: 0.28, alpha: 1.0)
        containerView.layer.cornerRadius = 12
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor(red: 0.35, green: 0.2, blue: 0.5, alpha: 1.0).cgColor

        gradientLayer.colors = [
            UIColor(red: 0.9, green: 0.4, blue: 0.3, alpha: 0.8).cgColor,
            UIColor(red: 0.6, green: 0.2, blue: 0.6, alpha: 0.8).cgColor
        ]
        
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)

        containerView.layer.insertSublayer(gradientLayer, at: 0)

        contentView.addSubview(containerView)

        containerView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(4)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        let iconImageView = UIImageView(image: UIImage(systemName: "gift.fill"))
        iconImageView.tintColor = .white
        iconImageView.contentMode = .scaleAspectFill

        titleLabel.text = "Free Token Opportunity"
        titleLabel.textColor = .white
        titleLabel.font = .boldSystemFont(ofSize: 15)

        descLabel.text = "Tap this area to get free tokens by watching ads."
        descLabel.textColor = UIColor.white.withAlphaComponent(0.8)
        descLabel.font = .systemFont(ofSize: 11)
        
        let limitLabel = UILabel()
        limitLabel.text = "0/3"
        limitLabel.textColor = .white
        limitLabel.font = .boldSystemFont(ofSize: 14)

        containerView.addSubview(iconImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(descLabel)
        containerView.addSubview(limitLabel)
        
        iconImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.size.equalTo(32)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.centerX.equalToSuperview()
            
        }

        descLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(2)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-16)
        }
        
        limitLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = containerView.bounds
    }
}
