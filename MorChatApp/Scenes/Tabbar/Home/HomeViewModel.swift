//
//  HomeViewModel.swift
//  MorChatApp
//
//  Created by bora ateş on 12.02.2026.
//

import Foundation
import UIKit

protocol HomeViewModelInputprotocol: AnyObject {
    func viewDidLoad()
}

protocol HomeViewModelOutputprotocol: AnyObject {
    func didFetchUsers(with users: [UserCardModel])
    func didFetchTags(_ tags: [String])
    func didFail(with error: String)
}


class HomeViewModel: HomeViewModelInputprotocol {
    
    weak var output: HomeViewModelOutputprotocol?
    
    // UI’da kullanılacak tek kaynak
    private(set) var users: [UserCardModel] = []
    
    // Tüm veriler (değişmez)
    private var allProfiles: [PublisherProfile] = []
    
    private let firestoreService: FirestoreServiceProtocol
    
    let availableTags = [
        "Spiritual Talks", "Dream", "Mystery", "Books", "Poetry", "Astrology", "Psychology",
        "Love", "Travel", "Romance", "Martial Arts", "Real Estate", "Health", "Economy",
        "Technology", "Plumber", "Electrician", "Beauty / Cosmetics", "Child Development", "Music",
        "Cars", "Food", "Fashion", "Football", "Games", "Fun", "Politics", "History", "Cinema", "Drinks"
    ]
    
    private var selectedTag: String?
    
    init(firestoreService: FirestoreServiceProtocol = FirestoreService.shared) {
        self.firestoreService = firestoreService
    }
    
    // MARK: - Lifecycle
    
    func viewDidLoad() {
        output?.didFetchTags(availableTags)
        fetchUsers()
    }
    
    // MARK: - Filtering
    
    func filterByTag(_ tag: String?) {
        self.selectedTag = tag
        applyFilter()
    }
    
    // MARK: - Fetch
    
    private func fetchUsers() {
        firestoreService.fetchPublisherProfiles { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let remoteProfiles):
                    self?.allProfiles = remoteProfiles
                    self?.applyFilter()
                    
                case .failure(let error):
                    self?.output?.didFail(with: error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - Filter + Mapping
    
    private func applyFilter() {
        
        // 1. Filtre uygula
        let filteredProfiles: [PublisherProfile]
        
        if let tag = selectedTag {
            filteredProfiles = allProfiles.filter { profile in
                let tagNames = profile.tagList?.compactMap { self.availableTags[safe: $0] } ?? []
                return tagNames.contains(tag)
            }
        } else {
            filteredProfiles = allProfiles
        }
        
        // 2. UI modeline çevir (AMA referansı KORU 🔥)
        users = filteredProfiles.map { profile in
            
            let isOnline = (profile.status == "Çevrimiçi")
            let tagNames = profile.tagList?.compactMap { self.availableTags[safe: $0] } ?? []
            
            return UserCardModel(
                name: profile.name ?? "İsimsiz",
                age: profile.age,
                imageURL: profile.profilePic,
                status: isOnline ? "Online" : "Away",
                tags: tagNames,
                profile: profile   // 🔥 EN KRİTİK SATIR
            )
        }
        
        // 3. UI güncelle
        output?.didFetchUsers(with: users)
    }
}

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
