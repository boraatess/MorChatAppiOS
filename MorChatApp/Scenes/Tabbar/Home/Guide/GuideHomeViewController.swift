
import UIKit
import SnapKit
import SwiftUI

final class GuideHomeViewController: BaseVC {
    
    private let viewModel = GuideHomeViewModel()
    private var watchers: [UserModel] = []
    
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 12
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.register(UserCardCell.self, forCellWithReuseIdentifier: UserCardCell.identifier)
        cv.delegate = self
        cv.dataSource = self
        return cv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.output = self
        viewModel.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Refresh watchers to pick up new interest matches
        viewModel.viewDidLoad()
    }
    
    private func setupUI() {
        // headerView.setTitle("MorChat Guide")
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
    }
    
    private func setupConstraints() {
     
       
    }
}

extension GuideHomeViewController: GuideHomeViewModelOutput {
    func didFetchWatchers(_ watchers: [UserModel]) {
        self.watchers = watchers
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    func didFail(with error: String) {
        showAutoDismissAlert(title: "home_error_title".localized, message: error, duration: 2.0)
    }
}

extension GuideHomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return watchers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UserCardCell.identifier, for: indexPath) as! UserCardCell
        
        let watcher = watchers[indexPath.row]
        
        let cardModel = UserCardModel(
            name: watcher.name ?? "pub_name_unknown".localized,
            age: watcher.age,
            imageURL: watcher.photoURL,
            status: watcher.status,
            tags: watcher.tagList ?? [],
            interests: watcher.interests ?? [],
            profile: nil,
            user: watcher
        )
        
        cell.delegate = self
        cell.configure(with: cardModel)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 8) / 2
        return CGSize(width: width, height: width * 1.5) // Increased height to accommodate 3 tag rows better
    }
}

extension GuideHomeViewController: UserCardCellDelegate {
    
    func didTapCallNow(on cell: UserCardCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let watcher = watchers[indexPath.row]
        startCall(with: watcher, isVideo: true)
    }
    
    func didTapVoiceCall(on cell: UserCardCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let watcher = watchers[indexPath.row]
        startCall(with: watcher, isVideo: false)
    }
    
    private func startCall(with watcher: UserModel, isVideo: Bool) {
        // Map UserModel to PublisherProfile for CallViewController
        let profile = PublisherProfile(
            id: watcher.uid,
            about: nil,
            age: watcher.age,
            email: watcher.email,
            language: nil,
            last_seen: nil,
            msgToken: nil,
            name: watcher.name,
            phoneNumber: nil,
            point: 0,
            profilePic: watcher.photoURL,
            status: watcher.status,
            tagList: watcher.tagList,
            photos: [], blockedWatcherList: [[:]]
        )
        
        let callVC = CallViewController(profile: profile, isVideoCall: isVideo)
        callVC.modalPresentationStyle = .fullScreen
        self.present(callVC, animated: true)
    }
}

#Preview {
    GuideHomeViewController().asPreview()
}
