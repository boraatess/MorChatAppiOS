//
//  BuyTokenCell.swift
//  MorChatApp
//
//  Created by bora ateş on 21.02.2026.
//

import Foundation
import UIKit
import SnapKit

final class BuyTokenCell: UITableViewCell {
    
    static let identifier = "BuyTokenCell"
    
    private let containerView = UIView()
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let priceLabel = UILabel()
    private let discountLabel = UILabel()
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
        selectionStyle = .none
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with model: TokenPackage) {
        
        titleLabel.text = model.title
        priceLabel.text = model.price
        
        if let discount = model.discountText {
            discountLabel.text = "  \(discount)  "
            discountLabel.isHidden = false
        } else {
            discountLabel.isHidden = true
        }
    }

    
    private func setupUI() {
        
        contentView.addSubview(containerView)
        
        containerView.addSubview(iconImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(priceLabel)
        containerView.addSubview(discountLabel)
        
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 16
        
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.08
        containerView.layer.shadowOffset = CGSize(width: 0, height: 4)
        containerView.layer.shadowRadius = 8
        
        iconImageView.image = UIImage(systemName: "arrow.2.circlepath.circle.fill")
        iconImageView.tintColor = .systemOrange
        iconImageView.contentMode = .scaleAspectFit
        
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = .black
        
        priceLabel.font = .systemFont(ofSize: 18, weight: .bold)
        priceLabel.textColor = UIColor(red: 0.45, green: 0.35, blue: 0.75, alpha: 1)
        
        discountLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        discountLabel.textColor = .white
        discountLabel.backgroundColor = .systemPink
        discountLabel.layer.cornerRadius = 12
        discountLabel.clipsToBounds = true
        discountLabel.textAlignment = .center
        
        setupConstraints()
    }

    private func setupConstraints() {
        
        containerView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(8)
            $0.left.right.equalToSuperview().inset(20)
        }
        
        iconImageView.snp.makeConstraints {
            $0.left.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(32)
        }
        
        titleLabel.snp.makeConstraints {
            $0.left.equalTo(iconImageView.snp.right).offset(12)
            $0.centerY.equalToSuperview()
        }
        
        priceLabel.snp.makeConstraints {
            $0.right.equalToSuperview().offset(-16)
            $0.top.equalToSuperview().offset(18)
        }
        
        discountLabel.snp.makeConstraints {
            $0.right.equalTo(priceLabel)
            $0.top.equalTo(priceLabel.snp.bottom).offset(6)
            $0.height.equalTo(24)
        }
    }

    
}
