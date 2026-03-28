//
//  PublisherActionSheetVC.swift
//  MorChatApp
//
//  Created by bora ateş.
//

import UIKit
import SnapKit

protocol PublisherActionSheetDelegate: AnyObject {
    func didTapAddToFavorites()
    func didTapBlock()
    func didTapReport()
}

final class PublisherActionSheetVC: UIViewController {
    
    weak var delegate: PublisherActionSheetDelegate?
    private let isFavorited: Bool
    
    // UI Elements
    private let containerView = UIView()
    private let handleView = UIView()
    
    private let favoritesButton = UIButton(type: .system)
    private let separatorView = UIView()
    
    private let blockButton = UIButton(type: .system)
    private let reportButton = UIButton(type: .system)
    
    init(isFavorited: Bool = false) {
        self.isFavorited = isFavorited
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    
    private func setupUI() {
        view.backgroundColor = .clear // will use sheet presentation
        
        containerView.backgroundColor = UIColor(red: 0.25, green: 0.1, blue: 0.45, alpha: 1.0) // Koyu Mor
        containerView.layer.cornerRadius = 24
        containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.addSubview(containerView)
        
        handleView.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        handleView.layer.cornerRadius = 2
        containerView.addSubview(handleView)
        
        // Setup Buttons
        let favTitle = isFavorited ? "action_remove_favorites".localized : "action_add_favorites".localized
        let favIcon = isFavorited ? "heart.fill" : "heart"
        setupActionButton(favoritesButton, title: favTitle, icon: favIcon, color: .systemPink)

        setupActionButton(blockButton, title: "action_block".localized, icon: "nosign", color: .white)
        setupActionButton(reportButton, title: "action_report".localized, icon: "exclamationmark.triangle", color: .white)
        
        separatorView.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        
        containerView.addSubview(favoritesButton)
        containerView.addSubview(separatorView)
        containerView.addSubview(blockButton)
        containerView.addSubview(reportButton)
        
        favoritesButton.addTarget(self, action: #selector(favoritesTapped), for: .touchUpInside)
        blockButton.addTarget(self, action: #selector(blockTapped), for: .touchUpInside)
        reportButton.addTarget(self, action: #selector(reportTapped), for: .touchUpInside)
        
        // Constraints
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        handleView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.centerX.equalToSuperview()
            make.width.equalTo(40)
            make.height.equalTo(4)
        }
        
        favoritesButton.snp.makeConstraints { make in
            make.top.equalTo(handleView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(44)
        }
        
        separatorView.snp.makeConstraints { make in
            make.top.equalTo(favoritesButton.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(1)
        }
        
        blockButton.snp.makeConstraints { make in
            make.top.equalTo(separatorView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(44)
        }
        
        reportButton.snp.makeConstraints { make in
            make.top.equalTo(blockButton.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(44)
        }
    }
    
    private func setupActionButton(_ button: UIButton, title: String, icon: String, color: UIColor) {
        button.setTitle(" \(title)", for: .normal)
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .regular)
        let image = UIImage(systemName: icon, withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = color
        button.setTitleColor(color, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.contentHorizontalAlignment = .left
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
    }
    
    // MARK: - Actions
    @objc private func favoritesTapped() {
        dismiss(animated: true) { [weak self] in
            self?.delegate?.didTapAddToFavorites()
        }
    }
    
    @objc private func blockTapped() {
        dismiss(animated: true) { [weak self] in
            self?.delegate?.didTapBlock()
        }
    }
    
    @objc private func reportTapped() {
        dismiss(animated: true) { [weak self] in
            self?.delegate?.didTapReport()
        }
    }
}
