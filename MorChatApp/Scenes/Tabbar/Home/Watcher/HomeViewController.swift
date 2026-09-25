//
//  HomeViewController.swift
//  MorChatApp
//
//  Created by bora ateş on 21.01.2026.
//

import Foundation
import UIKit
import SnapKit
import SwiftUI

class HomeViewController: BaseVC {

    private let viewModel = HomeViewModel()

    private lazy var tagCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.minimumInteritemSpacing = 8
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.register(TagFilterCell.self, forCellWithReuseIdentifier: "TagFilterCell")
        cv.delegate = self
        cv.dataSource = self
        return cv
    }()

    private lazy var storiesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 72, height: 90)
        layout.minimumInteritemSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.register(HomeStoryCell.self, forCellWithReuseIdentifier: "HomeStoryCell")
        cv.delegate = self
        cv.dataSource = self
        return cv
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 6
        layout.minimumLineSpacing = 6
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.register(PublisherCardCell.self,
                    forCellWithReuseIdentifier: PublisherCardCell.identifier)
        cv.delegate = self
        cv.dataSource = self
        cv.refreshControl = refreshControl
        return cv
    }()

    private lazy var refreshControl: UIRefreshControl = {
        let rc = UIRefreshControl()
        rc.tintColor = .white
        rc.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        return rc
    }()

    // 🔥 TEK DATA SOURCE
    private var users: [UserCardModel] = []
    private var stories: [PublisherProfile] = []
    private var tags: [String] = []
    private var selectedTag: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isHidden = true

        setupUI()
        viewModel.output = self
        viewModel.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Refetch data each time screen appears to show updated interests/profile
        viewModel.viewDidLoad() 
    }

    override func applyLocalization() {
        viewModel.viewDidLoad()
    }
}

private extension HomeViewController {

    func setupUI() {
        
        view.addSubview(storiesCollectionView)
        
        storiesCollectionView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(100)
        }
        
        view.addSubview(tagCollectionView)

        tagCollectionView.snp.makeConstraints { make in
            make.top.equalTo(storiesCollectionView.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(44)
        }
        view.addSubview(collectionView)

        collectionView.snp.makeConstraints {
            $0.top.equalTo(tagCollectionView.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(8)
            $0.bottom.equalToSuperview()
        }
    }

    @objc func handleRefresh() {
        viewModel.viewDidLoad()
    }
}

// MARK: - CollectionView
extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == storiesCollectionView {
            return stories.count
        }
        if collectionView == tagCollectionView {
            return tags.count
        }
        return users.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == storiesCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeStoryCell", for: indexPath) as! HomeStoryCell
            let storyUser = stories[indexPath.row]
            cell.configure(with: storyUser)
            return cell
        }
        
        if collectionView == tagCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagFilterCell", for: indexPath) as! TagFilterCell
            let tag = tags[indexPath.row]
            cell.configure(with: tag, isSelected: tag == selectedTag)
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PublisherCardCell.identifier,
            for: indexPath
        ) as! PublisherCardCell
        
        
        // 🔥 SADECE users kullan
        cell.configure(with: users[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == storiesCollectionView {
            let user = stories[indexPath.row]
            guard let storyUrls = user.stories?.compactMap({ $0.url }) else { return }
            let vc = StoryDetailViewController(
                storyUrls: storyUrls,
                userName: user.name,
                userProfilePic: user.profilePic
            )
            vc.modalPresentationStyle = .fullScreen // Hikayeler tam ekran olur genelde
            self.present(vc, animated: true)
            return
        }
        
        if collectionView == tagCollectionView {
            let tag = tags[indexPath.row]
            
            selectedTag = (selectedTag == tag) ? nil : tag
            
            viewModel.filterByTag(selectedTag)
            tagCollectionView.reloadData()
            return
        }
        
        // 🔥 DOĞRU MODEL
        let selectedUser = users[indexPath.row]
        
        guard let profile = selectedUser.profile else { return }
        let detailVC = PublisherDetailViewController(profile: profile)
        detailVC.hidesBottomBarWhenPushed = true
        
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - ViewModel Output
extension HomeViewController: HomeViewModelOutputprotocol {
    
    func didFetchUsers(with users: [UserCardModel]) {
        self.users = users
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    func didFetchTags(_ tags: [String]) {
        self.tags = tags
        
        DispatchQueue.main.async {
            self.tagCollectionView.reloadData()
        }
    }
    
    func didFetchStories(_ stories: [PublisherProfile]) {
        self.stories = stories
        DispatchQueue.main.async {
            self.storiesCollectionView.reloadData()
            let isEmpty = stories.isEmpty
            self.storiesCollectionView.isHidden = isEmpty
            
            // Layout güncelle (stories yoksa tamamen kapat ve tagCollectionView yukarı çıksın)
            self.storiesCollectionView.snp.updateConstraints { make in
                make.height.equalTo(isEmpty ? 0 : 100)
                make.top.equalTo(self.headerView.snp.bottom).offset(isEmpty ? 0 : 8)
            }
            
            // Animasyonla geçiş yaparsak daha şık durur
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func didFail(with error: String) {
        showAutoDismissAlert(
            title: "home_error_title".localized,
            message: error,
            duration: 2.0
        )
    }

    func setLoader(isVisible: Bool) {
        if isVisible {
            if !refreshControl.isRefreshing {
                showLoading()
            }
        } else {
            hideLoading()
            refreshControl.endRefreshing()
        }
    }
}

// MARK: - Layout
extension HomeViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == tagCollectionView {
            return .zero
        }

        let padding: CGFloat = 4
        let spacing: CGFloat = 6
        
        let total = padding * 2 + spacing
        let width = (collectionView.bounds.width - total) / 2
        
        let height = width * 1.35
        return CGSize(width: width, height: height)
    }
}

// MARK: - TagFilterCell
final class TagFilterCell: UICollectionViewCell {
    private let label: UILabel = {
        let l = UILabel()
        l.textColor = .white
        l.font = .systemFont(ofSize: 13, weight: .semibold)
        return l
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 18
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.white.withAlphaComponent(0.6).cgColor
        contentView.addSubview(label)
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))
        }
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func configure(with tag: String, isSelected: Bool) {
        label.text = tag
        if isSelected {
            contentView.backgroundColor = UIColor.white.withAlphaComponent(0.2)
            contentView.layer.borderColor = UIColor.white.cgColor
        } else {
            contentView.backgroundColor = .clear
            contentView.layer.borderColor = UIColor.white.withAlphaComponent(0.4).cgColor
        }
    }
}

// MARK: - HomeStoryCell
final class HomeStoryCell: UICollectionViewCell {
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 30
        iv.layer.borderWidth = 2
        iv.layer.borderColor = UIColor.systemPink.cgColor
        iv.backgroundColor = .darkGray
        return iv
    }()
    
    private let nameLabel: UILabel = {
        let l = UILabel()
        l.textColor = .white
        l.font = .systemFont(ofSize: 11, weight: .medium)
        l.textAlignment = .center
        return l
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        contentView.addSubview(nameLabel)
        
        imageView.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.size.equalTo(60)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview().inset(4)
        }
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func configure(with publisher: PublisherProfile) {
        nameLabel.text = publisher.name
        if let urlStr = publisher.profilePic, let url = URL(string: urlStr) {
            // Profil resmini yükle (Kingfisher/SDWebImage yoksa basitçe)
            URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data {
                    DispatchQueue.main.async { self.imageView.image = UIImage(data: data) }
                }
            }.resume()
        } else {
            imageView.image = UIImage(systemName: "person.fill")
        }
    }
}

#Preview {
    HomeViewController().asPreview()
    
}
