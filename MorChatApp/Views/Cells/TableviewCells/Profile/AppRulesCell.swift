//
//  AppRulesCell.swift
//  MorChatApp
//
//  Created by bora ateş on 12.02.2026.
//

import Foundation
import UIKit
import SnapKit

final class AppRulesCell: UITableViewCell {
    
    static let identifier = "AppRulesCell"
    
    private let containerView = UIView()
    private let iconContainer = UIView()
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        
        contentView.addSubview(containerView)
        containerView.addSubview(iconContainer)
        iconContainer.addSubview(iconImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(messageLabel)
        
        containerView.layer.cornerRadius = 20
        
        iconContainer.layer.cornerRadius = 20
        iconContainer.clipsToBounds = true
        
        iconImageView.contentMode = .scaleAspectFit
        
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        
        messageLabel.font = .systemFont(ofSize: 16)
        messageLabel.numberOfLines = 0
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(12)
        }
        
        iconContainer.snp.makeConstraints {
            $0.top.left.equalToSuperview().offset(16)
            $0.width.height.equalTo(40)
        }
        
        iconImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(20)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(iconContainer)
            $0.left.equalTo(iconContainer.snp.right).offset(12)
            $0.right.equalToSuperview().offset(-16)
        }
        
        messageLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(6)
            $0.left.right.equalTo(titleLabel)
            $0.bottom.equalToSuperview().offset(-16)
        }
    }
    
    func configure(with item: RuleItem) {
        iconImageView.image = item.icon
        iconContainer.backgroundColor = item.iconBackgroundColor
        titleLabel.text = item.title
        messageLabel.text = item.message
        containerView.backgroundColor = item.containerColor
    }
}
