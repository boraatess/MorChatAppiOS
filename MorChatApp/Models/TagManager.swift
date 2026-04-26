import Foundation

/// Singleton class to fetch and map tags globally
class TagManager {
    static let shared = TagManager()
    
    private(set) var allTags: [TagModel] = []
    
    private init() {}
    
    /// Call this once when the app starts or when users login
    func fetchTags(completion: @escaping () -> Void = {}) {
        FirestoreService.shared.fetchPublisherTags { result in
            switch result {
            case .success(let tags):
                self.allTags = tags
                print("✅ TagManager: \(tags.count) etiket (tag) başarıyla yüklendi.")
            case .failure(let error):
                print("❌ TagManager Error: \(error.localizedDescription)")
            }
            completion()
        }
    }
    
    // Convert array of Int IDs to Names (For PublisherProfile)
    func getTagNames(fromIntIds ids: [Int]) -> [String] {
        return ids.compactMap { id in
            self.allTags.first(where: { $0.id == id })?.name
        }
    }
    
    // Convert array of String IDs to Names (For UserWatcher)
    func getTagNames(fromStringIds ids: [String]) -> [String] {
        return ids.compactMap { idStr in
            guard let id = Int(idStr.trimmingCharacters(in: .whitespaces)) else { return nil }
            return self.allTags.first(where: { $0.id == id })?.name
        }
    }
    
    // (Optional) Get actual TagModel objects if needed
    func getTags(fromIntIds ids: [Int]) -> [TagModel] {
        return ids.compactMap { id in
            self.allTags.first(where: { $0.id == id })
        }
    }
    
    func getTags(fromStringIds ids: [String]) -> [TagModel] {
        return ids.compactMap { idStr in
            guard let id = Int(idStr.trimmingCharacters(in: .whitespaces)) else { return nil }
            return self.allTags.first(where: { $0.id == id })
        }
    }
}
