//
//  ProfileHeaderView.swift
//  MorChatApp
//
//  Created by bora ateş on 17.02.2026.
//

import Foundation
import UIKit
import SnapKit
import SwiftUI

protocol ProfileHeaderViewDelegate: AnyObject {
    func didTapBack()
    
}

final class ProfileHeaderView: UIView {

    weak var delegate: ProfileHeaderViewDelegate?
    
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "chevron.left")
        button.setImage(image, for: .normal)
        button.tintColor = UIColor.App.primaryText
        button.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        return button
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    // MARK: - UI
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = UIColor.App.primaryText
        return label
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.App.screenBackground
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func configure(with title: String, image: String) {
        titleLabel.text = title
        if image == "" {
            iconImageView.isHidden = true
        }
        else {
            iconImageView.isHidden = false
            iconImageView.image = UIImage(named: image)
        }
        
    }

    @objc private func didTapBack() {
        delegate?.didTapBack()
    }
    
    // MARK: - Setup
    private func setupUI() {
        addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().inset(5)
            make.width.height.equalTo(32)
        }
        addSubview(iconImageView)
        iconImageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalTo(backButton.snp.trailing).offset(10)
        }
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalTo(iconImageView.snp.trailing).offset(10)
            make.centerY.equalTo(backButton.snp.centerY)
            
        }
        
    }
    
}

#Preview {
    ProfileHeaderView().asPreview()
    
}
