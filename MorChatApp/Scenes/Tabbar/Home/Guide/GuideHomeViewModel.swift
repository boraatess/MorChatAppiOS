import Foundation
import FirebaseAuth

protocol GuideHomeViewModelOutput: AnyObject {
    func didFetchWatchers(_ watchers: [UserModel])
    func didFail(with error: String)
    func setLoader(isVisible: Bool)
}

final class GuideHomeViewModel {
    weak var output: GuideHomeViewModelOutput?
    private let firestoreService: FirestoreServiceProtocol
    
    init(firestoreService: FirestoreServiceProtocol = FirestoreService.shared) {
        self.firestoreService = firestoreService
    }
    
    func viewDidLoad() {
        fetchData()
    }
    
    func fetchData() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        output?.setLoader(isVisible: true)
        firestoreService.fetchPublisherProfile(publisherId: uid) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let profile):
                self.firestoreService.fetchPublisherTags { [weak self] tagResult in
                    guard let self = self else { return }
                    
                    switch tagResult {
                    case .success(let allTags):
                        let guideTagsIDs = profile.tagList ?? []
                        
                        // Tag ID listesinden Name listesine çevrim yapıyoruz
                        let guideInterests = guideTagsIDs.compactMap { id in
                            allTags.first(where: { $0.id == id })?.name
                        }
                        
                        self.fetchAndFilterWatchers(guideTags: guideTagsIDs, guideInterests: guideInterests, allTags: allTags)
                    case .failure(let error):
                        self.output?.setLoader(isVisible: false)
                        self.output?.didFail(with: "Tags Fetch Error: \(error.localizedDescription)")
                    }
                }
                
            case .failure(let error):
                self.output?.setLoader(isVisible: false)
                self.output?.didFail(with: error.localizedDescription)
            }
        }
    }
    
    private func fetchAndFilterWatchers(guideTags: [Int], guideInterests: [String], allTags: [TagModel]) {
        print("DEBUG: Guide Interest IDs: \(guideTags)")
        
        firestoreService.fetchWatchers { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let rawWatchers):
                let guideTagSet = Set(guideTags)
                let guideNameSet = Set(guideInterests.map { $0.lowercased().trimmingCharacters(in: .whitespaces) })
                
                // 1. Filter and Map in one go to ensure all fields are populated correctly
                let mappedWatchers = rawWatchers.map { watcher -> UserModel in
                    var updated = watcher
                    
                    // --- Ensure interest NAMES are populated from tagList ---
                    if let tags = watcher.tagList, !tags.isEmpty {
                        let mappedNames = tags.compactMap { id in allTags.first(where: { $0.id == id })?.name }
                        if !mappedNames.isEmpty {
                            updated.interests = (updated.interests ?? []) + mappedNames
                        }
                    }
                    
                    // --- Ensure tagList is populated from numeric interest strings (if not already) ---
                    // (This shouldn't be strictly necessary if FirestoreService does its job, but good defensively)
                    
                    return updated
                }.map { watcher -> UserModel in
                    // De-duplicate interests
                    var updated = watcher
                    if let interestsSet = watcher.interests {
                        updated.interests = Array(Set(interestsSet))
                    }
                    return updated
                }
                
                // 2. Perform Sorting (Instead of Filtering to not show an empty screen)
                let sorted = mappedWatchers.sorted { w1, w2 in
                    let overlap1 = Set(w1.tagList ?? []).intersection(guideTagSet).count
                    let overlap2 = Set(w2.tagList ?? []).intersection(guideTagSet).count
                    
                    if overlap1 != overlap2 {
                        return overlap1 > overlap2 // Daha çok eşleşen üstte
                    }
                    
                    // Eşitlik durumunda online olanları öne çıkar
                    let isOnline1 = (w1.status == "Online" || w1.status == "Çevrimiçi") ? 1 : 0
                    let isOnline2 = (w2.status == "Online" || w2.status == "Çevrimiçi") ? 1 : 0
                    return isOnline1 > isOnline2
                }
                
                print("DEBUG: Watchers count: \(sorted.count)")
                self.output?.setLoader(isVisible: false)
                self.output?.didFetchWatchers(sorted)
                
            case .failure(let error):
                self.output?.setLoader(isVisible: false)
                self.output?.didFail(with: error.localizedDescription)
            }
        }
    }
}
