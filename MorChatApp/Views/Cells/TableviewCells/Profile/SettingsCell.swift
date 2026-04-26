//
//  SettingsCell.swift
//  MorChatApp
//
//  Created by bora ateş on 12.02.2026.
//

import Foundation
import UIKit
import SnapKit
import SwiftUI


final class SettingTableViewCell: UITableViewCell {
    
    static let identifier = "SettingTableViewCell"
    
    private let containerView = UIView()
    private let iconContainer = UIView()
    private let iconImageView = UIImageView()
    
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let labelStackView = UIStackView()
    
    private let toggleSwitch = UISwitch()
    
    var toggleChanged: ((Bool) -> Void)?
    
    
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
        labelStackView.axis = .vertical
        labelStackView.spacing = 4
        labelStackView.alignment = .leading
        
        containerView.addSubview(labelStackView)
        labelStackView.addArrangedSubview(titleLabel)
        labelStackView.addArrangedSubview(subtitleLabel)
        containerView.addSubview(toggleSwitch)
        
        containerView.layer.cornerRadius = 10
        containerView.backgroundColor = .systemBackground
        
        iconContainer.backgroundColor = UIColor.indigoPurple.withAlphaComponent(0.1)
        iconContainer.layer.cornerRadius = 30
        
        iconImageView.tintColor = .indigoPurple
        iconImageView.contentMode = .scaleAspectFit
        
        titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
        
        subtitleLabel.font = .systemFont(ofSize: 14)
        subtitleLabel.textColor = .gray
        subtitleLabel.numberOfLines = 0
        
        toggleSwitch.onTintColor = .systemPurple
        toggleSwitch.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        containerView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(6)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.greaterThanOrEqualTo(90) 
        }
        
        iconContainer.snp.makeConstraints {
            $0.left.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(60)
        }
        
        iconImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(26)
        }
        
        toggleSwitch.snp.makeConstraints {
            $0.right.equalToSuperview().offset(-16)
            $0.centerY.equalToSuperview()
        }
        
        labelStackView.snp.makeConstraints {
            $0.left.equalTo(iconContainer.snp.right).offset(16)
            $0.right.lessThanOrEqualTo(toggleSwitch.snp.left).offset(-8)
            $0.centerY.equalToSuperview()
            $0.top.greaterThanOrEqualToSuperview().offset(16)
            $0.bottom.lessThanOrEqualToSuperview().offset(-16)
        }
    }
    
    @objc private func switchChanged() {
        toggleChanged?(toggleSwitch.isOn)
    }
    
    func configure(with item: SettingItem) {
        iconImageView.image = item.icon
        titleLabel.text = item.title
        subtitleLabel.text = item.subtitle
        
        switch item.type {
        case .toggle(let isOn):
            toggleSwitch.isHidden = false
            toggleSwitch.isOn = isOn
            accessoryType = .none
        case .normal:
            toggleSwitch.isHidden = true
            accessoryType = .none
        case .actionSheet:
            toggleSwitch.isHidden = true
            accessoryType = .none
            
        }
    }
}
