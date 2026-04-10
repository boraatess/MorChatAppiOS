//
//  NotificationsVC.swift
//  MorChatApp
//
//  Created by bora ateş on 21.01.2026.
//

import Foundation
import UIKit
import SnapKit


final class NotificationsVC: BaseVC {
    
    // MARK: - Properties
    
    private var notifications: [NotificationModel] = [] {
        didSet {
            updateUI()
        }
    }
    
    private let viewModel = NotifiesViewModel()
    
    // MARK: - UI
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 16
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.delegate = self
        cv.dataSource = self
        cv.register(NotificationCell.self, forCellWithReuseIdentifier: "NotificationCell")
        return cv
    }()
    
    private let emptyStateView = EmptyStateView()
    private let subHeaderView = SubHeaderView()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.isHidden = true

        setupUI()
        configureEmptyState()
        
        subHeaderView.configure(title: "notif_title".localized, subtitle: "notif_subtitle".localized)
        
        viewModel.output = self
        viewModel.viewDidLoad()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.navigationBar.isHidden = true
        updateUI()
        viewModel.viewDidLoad()
        
        
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.addSubview(subHeaderView)
        view.addSubview(collectionView)
        
        subHeaderView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            // Below the logo header
            make.leading.trailing.equalToSuperview()
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(subHeaderView.snp.bottom).offset(8)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        view.addSubview(emptyStateView)
        
        emptyStateView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(20)
            
        }
    }
    
    private func configureEmptyState() {
        
        emptyStateView.configure(with: EmptyStateModel(title: "notif_empty_title".localized, description: "notif_empty_desc".localized, image: UIImage(systemName: "flame.fill")) )
        
        emptyStateView.isHidden = true
    }
    
    // MARK: - UI State Update
    private func updateUI() {
        let isEmpty = notifications.isEmpty
        
        emptyStateView.isHidden = !isEmpty
        collectionView.isHidden = isEmpty
        
        if !isEmpty {
            collectionView.reloadData()
        }
    }
    
}

extension NotificationsVC: NotifiesViewModelOutputProtocol {
    func didFetchNotifications(with notifications: [NotificationModel]) {
        self.notifications = notifications
    }
    
    func didFail(with error: String) {
        print("Hata: \(error)")
        self.updateUI()
    }
    
    func didSelectCallRoom(profile: PublisherProfile, isVideo: Bool, callId: String) {
        let callVC = CallViewController(profile: profile, isVideoCall: isVideo, callId: callId)
        callVC.modalPresentationStyle = .fullScreen
        self.present(callVC, animated: true)
    }
}


// MARK: - Custom Notification Cell
final class NotificationCell: UICollectionViewCell {
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let timeLabel = UILabel()
    private let iconImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupUI() {
        backgroundColor = UIColor(red: 0.16, green: 0.08, blue: 0.28, alpha: 1.0)
        layer.cornerRadius = 12
        layer.borderWidth = 1
        layer.borderColor = UIColor(red: 0.35, green: 0.2, blue: 0.5, alpha: 1.0).cgColor
        
        iconImageView.image = UIImage(systemName: "bell.fill")
        iconImageView.tintColor = .systemPink
        iconImageView.contentMode = .scaleAspectFit
        
        titleLabel.font = .boldSystemFont(ofSize: 14)
        titleLabel.textColor = .white
        
        messageLabel.font = .systemFont(ofSize: 12)
        messageLabel.textColor = .lightGray
        messageLabel.numberOfLines = 2
        
        timeLabel.font = .systemFont(ofSize: 10)
        timeLabel.textColor = .gray
        timeLabel.textAlignment = .right
        
        contentView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(messageLabel)
        contentView.addSubview(timeLabel)
        
        iconImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.size.equalTo(24)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.equalTo(iconImageView.snp.trailing).offset(12)
            make.trailing.equalTo(timeLabel.snp.leading).offset(-8)
        }
        
        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.equalTo(titleLabel.snp.leading)
            make.trailing.equalToSuperview().inset(12)
        }
        
        timeLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.trailing.equalToSuperview().inset(12)
            make.width.equalTo(60)
        }
    }
    
    func configure(with model: NotificationModel) {
        titleLabel.text = model.title ?? "Bildirim"
        messageLabel.text = model.message ?? ""
        if let ts = model.timestamp {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            timeLabel.text = formatter.string(from: ts)
        } else {
            timeLabel.text = "Şimdi"
        }
    }
}

// MARK: - CollectionView Setup
extension NotificationsVC: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.selectNotification(at: indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        notifications.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "NotificationCell",
            for: indexPath
        ) as! NotificationCell
        
        cell.configure(with: notifications[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.frame.width - 40, height: 80)
    }
}
