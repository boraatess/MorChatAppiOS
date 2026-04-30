import Foundation
import FirebaseAuth
import FirebaseFirestore
import UIKit

protocol ProfileViewModelOutput: AnyObject {
    func didFetchUser(_ user: UserModel)
    func didUpdateInterests()
    func didUpdatePhoto(url: String)
    func didFail(with error: String)
    func setLoader(isVisible: Bool)
    func didLogout()
}

protocol ProfileViewModelInput {
    func fetchData()
    func updateInterests(_ tags: [InterestModel])
    func uploadPhoto(_ image: UIImage)
    func logout()
}

final class ProfileViewModel: ProfileViewModelInput {
    
    weak var output: ProfileViewModelOutput?
    private let firestoreService = FirestoreService.shared
    private let storageService = StorageService.shared
    private let authService = FirebaseAuthService.shared
    
    private(set) var currentUser: UserModel?
    private(set) var selectedInterests: [InterestModel] = []
    
    func fetchData() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        output?.setLoader(isVisible: true)
        firestoreService.fetchUserProfile(uid: uid) { [weak self] result in
            guard let self = self else { return }
            self.output?.setLoader(isVisible: false)
            
            switch result {
            case .success(let user):
                self.currentUser = user
                self.mapInterests(user.interests)
                self.output?.didFetchUser(user)
            case .failure(let error):
                self.output?.didFail(with: error.localizedDescription)
            }
        }
    }
    
    private func mapInterests(_ remoteInterests: [String]?) {
        guard let remoteInterests = remoteInterests, !remoteInterests.isEmpty else {
            self.selectedInterests = []
            return
        }
        
        let restored = remoteInterests.compactMap { name -> InterestModel? in
            if let category = SharedTagsCloudView.categories.first(where: { $0.name == name }) {
                return InterestModel(id: category.id, name: category.name, icon: category.icon ?? "", color: category.color)
            }
            return nil
        }
        self.selectedInterests = restored
    }
    
    func updateInterests(_ tags: [InterestModel]) {
        self.selectedInterests = tags
        let names = tags.map { $0.name }
        UserDefaults.standard.set(names, forKey: "user_selected_interests")
        
        guard var user = currentUser else { return }
        
        let tagNames = tags.map { $0.name }
        let tagIndices = tags.compactMap { interest -> Int? in
            SharedTagsCloudView.categories.firstIndex(where: { $0.name == interest.name })
        }
        
        let updatedUser = UserModel(
            uid: user.uid,
            name: user.name,
            email: user.email,
            photoURL: user.photoURL,
            createdAt: user.createdAt,
            interests: tagNames,
            tagList: tagIndices,
            age: user.age,
            status: user.status,
            blockedPublisherList: user.blockedPublisherList
        )
        
        output?.setLoader(isVisible: true)
        firestoreService.saveUserProfile(user: updatedUser) { [weak self] error in
            self?.output?.setLoader(isVisible: false)
            if let error = error {
                self?.output?.didFail(with: error.localizedDescription)
            } else {
                self?.currentUser = updatedUser
                self?.output?.didUpdateInterests()
            }
        }
    }
    
    func uploadPhoto(_ image: UIImage) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        output?.setLoader(isVisible: true)
        storageService.uploadProfileImage(uid: uid, image: image) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let downloadURL):
                self.firestoreService.updateProfileImageURL(uid: uid, url: downloadURL) { error in
                    self.output?.setLoader(isVisible: false)
                    if let error = error {
                        self.output?.didFail(with: error.localizedDescription)
                    } else {
                        self.output?.didUpdatePhoto(url: downloadURL)
                    }
                }
            case .failure(let error):
                self.output?.setLoader(isVisible: false)
                self.output?.didFail(with: error.localizedDescription)
            }
        }
    }
    
    func logout() {
        authService.signOut()
        output?.didLogout()
    }
}
