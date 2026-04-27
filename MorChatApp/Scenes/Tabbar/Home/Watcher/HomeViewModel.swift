//
//  HomeViewModel.swift
//  MorChatApp
//
//  Created by bora ateş on 12.02.2026.
//

import Foundation
import UIKit
import FirebaseFirestore

protocol HomeViewModelInputprotocol: AnyObject {
    func viewDidLoad()
}

protocol HomeViewModelOutputprotocol: AnyObject {
    func didFetchUsers(with users: [UserCardModel])
    func didFetchTags(_ tags: [String])
    func didFetchStories(_ stories: [PublisherProfile])
    func didFail(with error: String)
    func setLoader(isVisible: Bool)
}


class HomeViewModel: HomeViewModelInputprotocol {
    
    weak var output: HomeViewModelOutputprotocol?
    
    // UI’da kullanılacak tek kaynak
    private(set) var users: [UserCardModel] = []
    private(set) var availableStories: [PublisherProfile] = []
    
    // Tüm veriler (değişmez)
    private var allProfiles: [PublisherProfile] = []
    
    private let firestoreService: FirestoreServiceProtocol
    private var profilesListener: FirebaseFirestore.ListenerRegistration?
    // Dinleyiciyi saklamak için
    
    private var availableTags: [String] {
        return SharedTagsCloudView.categories.map { $0.name }
    }
    
    private var selectedTag: String?
    
    init(firestoreService: FirestoreServiceProtocol = FirestoreService.shared) {
        self.firestoreService = firestoreService
    }
    
    deinit {
        // Dinleyiciyi durdur (Memory leak önlemek için)
        profilesListener?.remove()
    }
    
    // MARK: - Lifecycle
    
    func viewDidLoad() {
        output?.didFetchTags(availableTags)
        startListeningUsers()
    }
    
    // MARK: - Filtering
    
    func filterByTag(_ tag: String?) {
        self.selectedTag = tag
        applyFilter()
    }
    
    // MARK: - Fetch (Anlık Dinleme)
    
    private func startListeningUsers() {
        // Eski dinleyici varsa kaldır
        profilesListener?.remove()
        
        output?.setLoader(isVisible: true) // Yükleme başladı
        
        profilesListener = firestoreService.listenPublisherProfiles { [weak self] result in
            DispatchQueue.main.async {
                self?.output?.setLoader(isVisible: false) // Veri geldi, loader'ı kapat
                
                switch result {
                case .success(let remoteProfiles):
                    print("🔄 Home: Veriler anlık olarak güncellendi (Kullanıcı Sayısı: \(remoteProfiles.count))")
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
            
            let isOnline = (profile.status == "Online" || profile.status == "Çevrimiçi")
            let tagNames = profile.tagList?.compactMap { self.availableTags[safe: $0] } ?? []
            let tagIds = profile.tagList ?? []
            
            return UserCardModel(
                name: profile.name ?? "İsimsiz",
                age: profile.age,
                imageURL: profile.profilePic,
                status: isOnline ? "Online" : "Away",
                tags: tagIds,         // [Int] ID Listesi
                interests: tagNames,  // [String] İsim Listesi
                profile: profile      // 🔥 EN KRİTİK SATIR
            )
        }
        
        // 3. Hikayeleri ayıkla
        self.availableStories = allProfiles.filter { !($0.stories?.isEmpty ?? true) }
        output?.didFetchStories(availableStories)
        
        // 4. UI güncelle
        output?.didFetchUsers(with: users)
    }
}

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
