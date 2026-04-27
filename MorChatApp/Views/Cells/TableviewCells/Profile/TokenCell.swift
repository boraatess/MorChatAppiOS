//
//  TokenCell.swift
//  MorChatApp
//
//  Created by bora ateş on 12.02.2026.
//

import Foundation
import UIKit
import SnapKit

protocol tokenCellOutputDelegate: AnyObject {
    func buyToken()
}

final class TokenCell: UITableViewCell {
    
    static let identifier = "TokenCell"
    
    private let containerView = UIView()
    private let titleLabel = UILabel()
    private let descLabel = UILabel()
    private let actionButton = UIButton()
    
    weak var output: tokenCellOutputDelegate?
    
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private let iconImageView = UIImageView()
    
    private func setupUI() {
        
        selectionStyle = .none
        backgroundColor = .clear
        
        containerView.backgroundColor = UIColor(red: 0.16, green: 0.08, blue: 0.28, alpha: 1.0)
        containerView.layer.cornerRadius = 12
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor(red: 0.35, green: 0.2, blue: 0.5, alpha: 1.0).cgColor
        
        contentView.addSubview(containerView)
        
        containerView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(4)
            make.trailing.bottom.equalToSuperview().inset(4)
            
        }
        
        iconImageView.image = UIImage(systemName: "arrow.triangle.2.circlepath.circle.fill")
        iconImageView.tintColor = .systemYellow
        iconImageView.contentMode = .scaleAspectFill
        
        titleLabel.text = "Current Tokens"
        titleLabel.font = .boldSystemFont(ofSize: 16)
        titleLabel.textColor = .white
        
        descLabel.text = "No tokens left. Load now and continue chat where you left off..."
        descLabel.numberOfLines = 0
        descLabel.font = .systemFont(ofSize: 12)
        descLabel.textColor = .lightGray
        
        actionButton.setTitle("Buy Token", for: .normal)
        actionButton.setTitleColor(.white, for: .normal)
        actionButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        actionButton.backgroundColor = UIColor(red: 0.9, green: 0.3, blue: 0.5, alpha: 1)
        actionButton.layer.cornerRadius = 8
        
        containerView.addSubview(iconImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(descLabel)
        containerView.addSubview(actionButton)
        
        iconImageView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(16)
            make.size.equalTo(40)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(6)
            make.leading.equalTo(iconImageView.snp.trailing).offset(12)
            make.trailing.equalToSuperview().inset(6)
        }
        
        descLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.equalTo(titleLabel.snp.leading)
            make.trailing.equalToSuperview().inset(16)
        }
        
        actionButton.snp.makeConstraints { make in
            make.top.equalTo(descLabel.snp.bottom).offset(6)
            make.leading.equalToSuperview().offset(50)
            make.trailing.equalToSuperview().inset(6)
            make.height.equalTo(45)
            make.bottom.equalToSuperview().offset(-16)
        }
        
        actionButton.addTarget(self, action: #selector(buyTokenTapped), for: .touchUpInside)
        
        
    }
    
    
    func configure(coins: Int) {
        titleLabel.text = String(format: "wallet_coins".localized, coins)
        actionButton.setTitle("wallet_buy_button".localized, for: .normal)
        
        if coins > 0 {
            descLabel.text = "wallet_coins_enough".localized
        } else {
            descLabel.text = "wallet_coins_not_enough".localized
        }
    }
    
    @objc func buyTokenTapped() {
        self.output?.buyToken()
    }
}

