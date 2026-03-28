//
//  PublisherDetailViewController.swift
//  MorChatApp
//
//  Created by bora ateş.
//

import UIKit
import SnapKit
import Kingfisher
import FirebaseAuth
import FirebaseFirestore



final class PublisherDetailViewController: UIViewController {

    private let profile: PublisherProfile
    private var isFavorited = false

    
    // UI Elements
    private let backgroundImageView = UIImageView()
    private let backButtonContainer = UIView()
    private let backButton = UIButton(type: .system)
    private let moreButtonContainer = UIView()
    private let moreButton = UIButton(type: .system)
    
    private let contentView = UIView()
    private let nameLabel = UILabel()
    
    private let statusContainer = UIView()
    private let statusLabel = UILabel()
    
    private let tagsScrollView = UIScrollView()
    private let tagsStackView = UIStackView()
    
    private let flagLabel = UILabel()
    private let descLabel = UILabel()
    
    private let bottomActionStack = UIStackView()
    private let callNowButton = UIButton(type: .system)
    private let voiceCallButton = UIButton(type: .system)
    
    private let infoFooterLabel = UILabel()

    // MARK: - Init
    init(profile: PublisherProfile) {
        self.profile = profile
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        configureData()
        checkIfFavorited()
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .white
        
        // Background Image
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.clipsToBounds = true
        view.addSubview(backgroundImageView)
        
        // Back Button
        backButtonContainer.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        backButtonContainer.layer.cornerRadius = 20
        backButtonContainer.clipsToBounds = true
        
        let backIcon = UIImage(systemName: "arrow.left")
        backButton.setImage(backIcon, for: .normal)
        backButton.tintColor = .white
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        
        backButtonContainer.addSubview(backButton)
        view.addSubview(backButtonContainer)
        
        // More Button
        moreButtonContainer.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        moreButtonContainer.layer.cornerRadius = 20
        moreButtonContainer.clipsToBounds = true
        
        let moreIcon = UIImage(systemName: "ellipsis")
        moreButton.setImage(moreIcon, for: .normal)
        moreButton.tintColor = .white
        moreButton.addTarget(self, action: #selector(moreTapped), for: .touchUpInside)
        
        moreButtonContainer.addSubview(moreButton)
        view.addSubview(moreButtonContainer)
        
        // Content Area
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 24
        contentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.addSubview(contentView)
        
        // Header (Name & Status)
        nameLabel.font = .systemFont(ofSize: 26, weight: .bold) // Increased from 22

        nameLabel.textColor = .black
        contentView.addSubview(nameLabel)
        
        statusContainer.backgroundColor = UIColor(red: 1.0, green: 0.85, blue: 0.85, alpha: 1.0)
        statusContainer.layer.cornerRadius = 12
        statusContainer.clipsToBounds = true
        
        statusLabel.font = .systemFont(ofSize: 12, weight: .medium)
        statusLabel.textColor = .systemRed
        statusLabel.textAlignment = .center
        
        statusContainer.addSubview(statusLabel)
        contentView.addSubview(statusContainer)
        
        // Tags area
        tagsScrollView.showsHorizontalScrollIndicator = false
        tagsStackView.axis = .horizontal
        tagsStackView.spacing = 8
        
        tagsScrollView.addSubview(tagsStackView)
        contentView.addSubview(tagsScrollView)
        
        // Flag
        flagLabel.text = "🇹🇷" // Or custom icon
        flagLabel.font = .systemFont(ofSize: 16)
        contentView.addSubview(flagLabel)
        
        // Description
        descLabel.font = .systemFont(ofSize: 16) // Increased from 14
        descLabel.textColor = .systemPurple

        descLabel.numberOfLines = 0
        contentView.addSubview(descLabel)
        
        // Action Buttons
        bottomActionStack.axis = .horizontal
        bottomActionStack.spacing = 16
        bottomActionStack.distribution = .fillEqually
        
        setupActionButton(callNowButton, title: "pub_call_now".localized, icon: "video.fill")
        setupActionButton(voiceCallButton, title: "pub_voice_call".localized, icon: "phone.fill")
        
        callNowButton.addTarget(self, action: #selector(startVideoCallTapped), for: .touchUpInside)
        voiceCallButton.addTarget(self, action: #selector(startVoiceCallTapped), for: .touchUpInside)
        
        bottomActionStack.addArrangedSubview(callNowButton)
        bottomActionStack.addArrangedSubview(voiceCallButton)
        contentView.addSubview(bottomActionStack)
        
        // Footer Label
        infoFooterLabel.text = "pub_footer_info".localized
        infoFooterLabel.font = .systemFont(ofSize: 10)
        infoFooterLabel.textColor = .gray
        infoFooterLabel.numberOfLines = 2
        infoFooterLabel.textAlignment = .center
        contentView.addSubview(infoFooterLabel)
    }
    
    private func setupActionButton(_ button: UIButton, title: String, icon: String) {
        button.setTitle(" \(title)", for: .normal)
        let image = UIImage(systemName: icon)
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold) // Increased from 14
        button.backgroundColor = UIColor(red: 0.35, green: 0.1, blue: 0.45, alpha: 1.0) 

        button.layer.cornerRadius = 8
    }

    private func setupConstraints() {
        backgroundImageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.65) // Take 65% height
        }
        
        backButtonContainer.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.leading.equalToSuperview().offset(16)
            make.size.equalTo(40)
        }
        
        backButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        moreButtonContainer.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.trailing.equalToSuperview().inset(16)
            make.size.equalTo(40)
        }
        
        moreButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.top.equalTo(backgroundImageView.snp.bottom).offset(-40) // Overlap background
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        nameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.leading.equalToSuperview().offset(20)
        }
        
        statusContainer.snp.makeConstraints { make in
            make.centerY.equalTo(nameLabel)
            make.trailing.equalToSuperview().inset(20)
            make.height.equalTo(24)
        }
        
        statusLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(12)
            make.centerY.equalToSuperview()
        }
        
        tagsScrollView.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalTo(flagLabel.snp.leading).offset(-8)
            make.height.equalTo(24)
        }
        
        tagsStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalToSuperview()
        }
        
        flagLabel.snp.makeConstraints { make in
            make.centerY.equalTo(tagsScrollView)
            make.trailing.equalToSuperview().inset(20)
            make.width.equalTo(20)
        }
        
        descLabel.snp.makeConstraints { make in
            make.top.equalTo(tagsScrollView.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().inset(20)
        }
        
        infoFooterLabel.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(8)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        bottomActionStack.snp.makeConstraints { make in
            make.bottom.equalTo(infoFooterLabel.snp.top).offset(-12)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(48)
        }
    }

    // MARK: - Configure Data
    private func configureData() {
        nameLabel.text = profile.name ?? "pub_name_unknown".localized
        
        let isOnline = (profile.status == "Çevrimiçi" || profile.status == "Online")
        statusLabel.text = isOnline ? "pub_status_online".localized : "pub_status_away".localized
        
        if isOnline {
            statusContainer.backgroundColor = UIColor(red: 0.85, green: 1.0, blue: 0.85, alpha: 1.0)
            statusLabel.textColor = UIColor(red: 0.1, green: 0.6, blue: 0.1, alpha: 1.0)
        } else {
            statusContainer.backgroundColor = UIColor(red: 1.0, green: 0.85, blue: 0.85, alpha: 1.0)
            statusLabel.textColor = .systemRed
        }
        
        if let urlStr = profile.profilePic, let url = URL(string: urlStr) {
            backgroundImageView.kf.setImage(with: url)
        } else {
            backgroundImageView.backgroundColor = .lightGray
            backgroundImageView.image = UIImage(systemName: "person.crop.rectangle.fill")
            backgroundImageView.tintColor = .darkGray
        }
        
        descLabel.text = profile.about ?? "pub_about_default".localized
        
        // Setup Tags
        let defaultTags = ["Psychology", "Economy", "Technology", "History"]
        for t in defaultTags {
            addTag(t)
        }
    }
    
    private func addTag(_ title: String) {
        let container = UIView()
        container.backgroundColor = UIColor(red: 1.0, green: 0.9, blue: 0.95, alpha: 1.0) // Light pink
        container.layer.cornerRadius = 6
        
        let lbl = UILabel()
        lbl.text = title
        lbl.textColor = UIColor(red: 0.9, green: 0.4, blue: 0.6, alpha: 1.0) // Dark pink
        lbl.font = .systemFont(ofSize: 11, weight: .bold)
        
        container.addSubview(lbl)
        lbl.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(8)
            make.top.bottom.equalToSuperview().inset(4)
        }
        
        tagsStackView.addArrangedSubview(container)
    }

    // MARK: - Actions
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func moreTapped() {
        let actionSheet = PublisherActionSheetVC(isFavorited: isFavorited)
        actionSheet.delegate = self
        
        if let sheet = actionSheet.sheetPresentationController {
            sheet.detents = [.custom(resolver: { context in
                return 220
            })]
            sheet.prefersGrabberVisible = false
            sheet.preferredCornerRadius = 24
        }
        
        present(actionSheet, animated: true)
    }

    
    @objc private func startVideoCallTapped() {
        let callVC = CallViewController(profile: profile, isVideoCall: true)
        callVC.modalPresentationStyle = .fullScreen
        self.present(callVC, animated: true)
    }
    
    @objc private func startVoiceCallTapped() {
        let callVC = CallViewController(profile: profile, isVideoCall: false)
        callVC.modalPresentationStyle = .fullScreen
        self.present(callVC, animated: true)
    }
}

extension PublisherDetailViewController: PublisherActionSheetDelegate {
    
    func didTapAddToFavorites() {
        guard let publisherId = profile.id else { return }
        
        if isFavorited {
            // Remove from favorites
            FirestoreService.shared.removeFromFavorites(publisherId: publisherId) { [weak self] error in
                DispatchQueue.main.async {
                    if error == nil {
                        self?.isFavorited = false
                        self?.showAutoDismissAlert(title: "Favorilerden Çıkarıldı", message: "\(self?.profile.name ?? "Yayıncı") favorilerinizden çıkarıldı.", duration: 1.5)
                    }
                }
            }
        } else {
            // Add to favorites
            FirestoreService.shared.addToFavorites(publisherId: publisherId) { [weak self] error in
                DispatchQueue.main.async {
                    if error == nil {
                        self?.isFavorited = true
                        self?.showAutoDismissAlert(title: "✅ Favorilere Eklendi", message: "\(self?.profile.name ?? "Yayıncı") favorilerinize eklendi!", duration: 1.5)
                    }
                }
            }
        }
    }
    
    func didTapBlock() {
        print("Block tapped")
    }
    
    func didTapReport() {
        print("Report tapped")
    }
    
    private func checkIfFavorited() {
        guard let uid = Auth.auth().currentUser?.uid,
              let publisherId = profile.id else { return }
        
        Firestore.firestore().collection("UserWatcherFavList").document(uid).getDocument { [weak self] snapshot, _ in
            guard let data = snapshot?.data(),
                  let favList = data["likedPublisherList"] as? [String] else { return }
            DispatchQueue.main.async {
                self?.isFavorited = favList.contains(publisherId)
            }
        }
    }
}
