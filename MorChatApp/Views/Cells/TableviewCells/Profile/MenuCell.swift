//
//  MenuCell.swift
//  MorChatApp
//
//  Created by bora ateş on 12.02.2026.
//

import Foundation
import UIKit
import SnapKit


final class MenuCell: UITableViewCell {

    static let identifier = "MenuCell"

    let containerView = UIView()
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let chevronImageView = UIImageView()
    private let separatorView = UIView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {

        selectionStyle = .none
        backgroundColor = .clear

        containerView.backgroundColor = UIColor(red: 0.16, green: 0.08, blue: 0.28, alpha: 1.0)
        containerView.layer.borderWidth = 0.5
        containerView.layer.borderColor = UIColor(red: 0.35, green: 0.2, blue: 0.5, alpha: 1.0).cgColor
        
        separatorView.backgroundColor = UIColor.white.withAlphaComponent(0.1)

        contentView.addSubview(containerView)
        containerView.addSubview(separatorView)

        containerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.bottom.equalToSuperview()
            make.height.equalTo(50)
        }
        
        separatorView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(1)
        }

        iconImageView.tintColor = .white
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 17, weight: .medium)

        chevronImageView.image = UIImage(systemName: "chevron.right")
        chevronImageView.tintColor = .lightGray

        containerView.addSubview(iconImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(chevronImageView)

        iconImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.size.equalTo(22)
        }

        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconImageView.snp.trailing).offset(16)
            make.centerY.equalToSuperview()
        }

        chevronImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
    }

    func configure(with item: AccountMenuItem) {
        titleLabel.text = item.title
        iconImageView.image = UIImage(systemName: item.icon)
    }
}
