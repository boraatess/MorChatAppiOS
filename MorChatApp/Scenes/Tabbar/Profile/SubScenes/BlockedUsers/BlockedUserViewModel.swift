//
//  BlockedUserViewModel.swift
//  MorChatApp
//
//  Created by bora ateş on 20.04.2026.
//

import FirebaseAuth

struct BlockedUserUIModel {
    let id: String
    let name: String
}

protocol BlockedUserViewModelProtocol: AnyObject {
    func fetchBlockedUsers()
    func unblockUser(at index: Int)
}

protocol BlockedUsersOutputProtocol: AnyObject {
    func didLoadBlockedUsers(_ users: [BlockedUserUIModel])
    func didFailWithError(_ error: Error)
    func didUnblockSuccessfully(at index: Int)
}

class BlockedUserViewModel: BlockedUserViewModelProtocol {
    
    weak var output: BlockedUsersOutputProtocol?
    private let firestoreService: FirestoreServiceProtocol
    private var blockedUsers: [BlockedUserUIModel] = []
    
    init(firestoreService: FirestoreServiceProtocol = FirestoreService.shared) {
        self.firestoreService = firestoreService
    }
    
    func fetchBlockedUsers() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userType = UserDefaults.standard.string(forKey: "userType") ?? "user"
        
        if userType == "guide" {
            firestoreService.fetchPublisherProfile(publisherId: uid) { [weak self] result in
                switch result {
                case .success(let profile):
                    let users = profile.blockedWatcherList?.compactMap { 
                        BlockedUserUIModel(id: $0["id"] ?? "", name: $0["name"] ?? "Unknown")
                    } ?? []
                    self?.blockedUsers = users
                    self?.output?.didLoadBlockedUsers(users)
                case .failure(let error):
                    self?.output?.didFailWithError(error)
                }
            }
        } else {
            firestoreService.fetchUserProfile(uid: uid) { [weak self] result in
                switch result {
                case .success(let user):
                    let users = user.blockedPublisherList?.compactMap {
                        BlockedUserUIModel(id: $0["id"] ?? "", name: $0["name"] ?? "Unknown")
                    } ?? []
                    self?.blockedUsers = users
                    self?.output?.didLoadBlockedUsers(users)
                case .failure(let error):
                    self?.output?.didFailWithError(error)
                }
            }
        }
    }
    
    func unblockUser(at index: Int) {
        guard index < blockedUsers.count else { return }
        let targetUser = blockedUsers[index]
        
        firestoreService.unblockUser(targetId: targetUser.id, targetName: targetUser.name) { [weak self] error in
            if let error = error {
                self?.output?.didFailWithError(error)
            } else {
                self?.blockedUsers.remove(at: index)
                self?.output?.didUnblockSuccessfully(at: index)
            }
        }
    }
}
