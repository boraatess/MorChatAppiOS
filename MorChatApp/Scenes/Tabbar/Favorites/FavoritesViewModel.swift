//
//  FavoritesViewModel.swift
//  MorChatApp
//
//  Created by bora ateş on 12.02.2026.
//

import Foundation

protocol FavoritesViewModelInputProtocol: AnyObject {
    func viewDidLoad()
}

protocol FavoritesViewModelOutputProtocol: AnyObject {
    func didFetchFavorites(with profiles: [UserCardModel])
    func didFail(with error: String)
}

final class FavoritesViewModel: FavoritesViewModelInputProtocol {
    
    weak var output: FavoritesViewModelOutputProtocol?
    private let firestoreService: FirestoreServiceProtocol
    var likedUsers: [UserCardModel] = []
    var publisherProfiles: [PublisherProfile] = []

    
    init(firestoreService: FirestoreServiceProtocol = FirestoreService.shared) {
        self.firestoreService = firestoreService
    }
    
    func viewDidLoad() {
        fetchFavorites()
    }
    
    private func fetchFavorites() {
        firestoreService.fetchLikedPublishers { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let profiles):
                    self?.publisherProfiles = profiles
                    self?.likedUsers = profiles.compactMap { profile in

                        // Convert tagList [Int] indices to tag name strings safely
                        /*
                        let tagNames: [String]
                        if let tagList = profile.tagList {
                            tagNames = tagList.compactMap { index in
                                guard index >= 0 && index < SharedTagsCloudView.categories.count else { return nil }
                                return SharedTagsCloudView.categories[index].name
                            }
                        } else {
                            tagNames = []
                        }
                        */
                        
                        return UserCardModel(name: profile.name ?? "", age: profile.age, imageURL: profile.profilePic, status: profile.status, tags: profile.interests ?? [], profile: profile)
                    }

                    if let users = self?.likedUsers {
                        self?.output?.didFetchFavorites(with: users)
                    }
                case .failure(let error):
                    self?.output?.didFail(with: error.localizedDescription)
                }
            }
        }
    }
}
