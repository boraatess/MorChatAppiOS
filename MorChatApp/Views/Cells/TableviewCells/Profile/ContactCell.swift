//
//  ContactCell.swift
//  MorChatApp
//
//  Created by bora ateş on 12.02.2026.
//

import Foundation
import UIKit
import SnapKit


final class ContactTableViewCell: UITableViewCell {
    
    static let identifier = "ContactTableViewCell"
    private let containerView = UIView()
    private let iconContainer = UIView()
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let emailLabel = UILabel()
    
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
        containerView.addSubview(emailLabel)
        
        containerView.layer.cornerRadius = 20
        containerView.backgroundColor = .systemBackground
        
        iconContainer.layer.cornerRadius = 30
        iconContainer.backgroundColor = UIColor.systemPurple.withAlphaComponent(0.1)
        
        iconImageView.image = UIImage(systemName: "envelope.fill")
        iconImageView.tintColor = .systemPurple
        
        titleLabel.text = "E-Posta"
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        
        emailLabel.text = "destek@morchat.com"
        emailLabel.textColor = .gray
        emailLabel.font = .systemFont(ofSize: 16)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(12)
        }
        
        iconContainer.snp.makeConstraints {
            $0.left.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(60)
        }
        
        iconImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(24)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(iconContainer.snp.top)
            $0.left.equalTo(iconContainer.snp.right).offset(16)
        }
        
        emailLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(6)
            $0.left.equalTo(titleLabel)
        }
    }
}
