//
//  FavoritesViewController.swift
//  MorChatApp
//
//  Created by bora ateş on 12.02.2026.
//

import Foundation
import UIKit
import SnapKit


final class FavoritesViewController: BaseVC {

    // MARK: - UI

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 24, right: 16)


        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsVerticalScrollIndicator = false
        cv.register(UserCardCell.self, forCellWithReuseIdentifier: "UserCardCell")
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()

    private let emptyStateView = EmptyStateView()
    private let subHeaderView = SubHeaderView()

    // MARK: - Data

    private var likedUsers: [UserCardModel] = [] 
    private let viewModel = FavoritesViewModel()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.isHidden = true

        setupUI()
        subHeaderView.configure(title: "fav_title".localized, subtitle: String(format: "fav_count_plural".localized, 0))
        
        viewModel.output = self
        viewModel.viewDidLoad()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        // Refresh data every time this tab appears
        viewModel.viewDidLoad()
    }
}


extension FavoritesViewController: FavoritesViewModelOutputProtocol {
    func didFetchFavorites(with profiles: [UserCardModel]) {
        self.likedUsers = profiles
        let countText = profiles.count == 1 ? "fav_count_singular".localized : "fav_count_plural".localized
        self.subHeaderView.updateSubtitle(String(format: countText, profiles.count))
        self.updateUI()
    }
    
    func didFail(with error: String) {
        print("Hata: \(error)")
        self.updateUI()
    }
}

// MARK: - Setup

private extension FavoritesViewController {

    func setupUI() {
        view.addSubview(subHeaderView)
        view.addSubview(collectionView)

        subHeaderView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.leading.trailing.equalToSuperview()
        }

        collectionView.snp.makeConstraints { make in
            make.top.equalTo(subHeaderView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        view.addSubview(emptyStateView)

        emptyStateView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(32)
        }

        emptyStateView.configure(with: EmptyStateModel(title: "fav_empty_title".localized,
        description: "fav_empty_desc".localized, image: UIImage(systemName: "flame.fill")))
       
        
    }

    func updateUI() {
        let isEmpty = likedUsers.isEmpty

        collectionView.isHidden = isEmpty
        emptyStateView.isHidden = !isEmpty
        
        if !isEmpty {
            collectionView.reloadData()
        }
    }
}

extension FavoritesViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return likedUsers.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "UserCardCell",
            for: indexPath
        ) as! UserCardCell

        cell.configure(with: likedUsers[indexPath.row])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let totalSpacing: CGFloat = 16 + 12 + 16 // left + middle + right
        let width = (collectionView.frame.width - totalSpacing) / 2
        let height = width * 1.4
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let profile = viewModel.publisherProfiles[indexPath.row]
        let detailVC = PublisherDetailViewController(profile: profile)
        detailVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
