import Foundation
import FirebaseAuth
import UIKit

protocol PublisherProfileInputProtocol: AnyObject {
    var currentPublisher: PublisherProfile? { get }
    var selectedInterests: [InterestModel] { get }
    
    func fetchProfile()
    func saveProfile(name: String?, about: String?, age: Int?, phone: String?)
    func updateInterests(_ tags: [InterestModel])
    func uploadProfileImage(_ image: UIImage)
    func uploadGalleryImage(_ image: UIImage)
    func uploadStoryImage(_ image: UIImage)
    func deleteGalleryImage(at index: Int)
    func deleteStory(at index: Int)
}

protocol PublisherProfileOutputProtocol: AnyObject {
    func didUpdateProfile()
    func didUpdateLoading(isLoading: Bool)
    func didFailWithError(message: String)
}

class PublisherProfileViewModel: PublisherProfileInputProtocol {
    
    weak var output: PublisherProfileOutputProtocol?
    
    private(set) var currentPublisher: PublisherProfile?
    private(set) var selectedInterests: [InterestModel] = []
    
    func fetchProfile() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        output?.didUpdateLoading(isLoading: true)
        
        // Doğrudan Publisher verisini çek
        FirestoreService.shared.fetchPublisherProfile(publisherId: uid) { [weak self] result in
            guard let self = self else { return }
            self.output?.didUpdateLoading(isLoading: false)
            
            switch result {
            case .success(let pub):
                print("publisher profile: \(pub)")
                self.handleFetchedPublisher(pub)
            case .failure(let error):
                self.output?.didFailWithError(message: error.localizedDescription)
            }
        }
    }
    
    private func handleFetchedPublisher(_ pub: PublisherProfile) {
        self.currentPublisher = pub
        
        // Etiketleri map'le
        FirestoreService.shared.fetchPublisherTags { [weak self] tagResult in
            guard let self = self else { return }
            
            switch tagResult {
            case .success(let allTags):
                if let tagList = pub.tagList {
                    self.selectedInterests = tagList.compactMap { id in
                        if let tag = allTags.first(where: { $0.id == id }) {
                            let ui = SharedTagsCloudView.defaultCategories.first(where: { $0.name == tag.name })
                            return InterestModel(id: tag.id, name: tag.name, icon: ui?.icon ?? "number", color: ui?.color ?? .systemIndigo)
                        }
                        return nil
                    }
                }
                self.output?.didUpdateProfile()
                
            case .failure:
                self.output?.didUpdateProfile()
            }
        }
    }
    
    func saveProfile(name: String?, about: String?, age: Int?, phone: String?) {
        guard var pub = currentPublisher else { return }
        
        if let name = name { pub.name = name }
        if let about = about { pub.about = about }
        if let age = age { pub.age = age }
        if let phone = phone { pub.phoneNumber = phone }
        
        self.currentPublisher = pub
        performSave(pub: pub)
    }
    
    func updateInterests(_ tags: [InterestModel]) {
        guard var pub = currentPublisher else { return }
        self.selectedInterests = tags
        pub.tagList = tags.compactMap { t in SharedTagsCloudView.defaultCategories.firstIndex(where: { $0.name == t.name }) }
        self.currentPublisher = pub
        performSave(pub: pub)
    }
    
    func uploadProfileImage(_ image: UIImage) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        output?.didUpdateLoading(isLoading: true)
        StorageService.shared.uploadProfileImage(uid: uid, image: image) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let url):
                FirestoreService.shared.updateProfileImageURL(uid: uid, url: url) { error in
                    self.output?.didUpdateLoading(isLoading: false)
                    if let error = error {
                        self.output?.didFailWithError(message: error.localizedDescription)
                    } else {
                        self.currentPublisher?.profilePic = url
                        self.output?.didUpdateProfile()
                    }
                }
            case .failure(let error):
                self.output?.didUpdateLoading(isLoading: false)
                self.output?.didFailWithError(message: error.localizedDescription)
            }
        }
    }
    
    func uploadStoryImage(_ image: UIImage) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        output?.didUpdateLoading(isLoading: true)
        
        StorageService.shared.uploadStoryImage(uid: uid, image: image) { [weak self] result in
            guard let self = self else { return }
            self.output?.didUpdateLoading(isLoading: false)
            
            switch result {
            case .success(let url):
                var pub = self.currentPublisher
                var currentStories = pub?.stories ?? []
                
                // Yeni StoryModel oluşturuluyor
                let newStory = StoryModel(
                    id: UUID().uuidString,
                    url: url,
                    timestamp: Int64(Date().timeIntervalSince1970 * 1000),
                    type: "image",
                    viewCount: 0
                )
                
                currentStories.append(newStory)
                pub?.stories = currentStories
                self.currentPublisher = pub
                
                if let finalPub = pub {
                    self.performSave(pub: finalPub)
                }
                
            case .failure(let error):
                self.output?.didFailWithError(message: error.localizedDescription)
            }
        }
    }
    
    func uploadGalleryImage(_ image: UIImage) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        output?.didUpdateLoading(isLoading: true)
        
        StorageService.shared.uploadGalleryImage(uid: uid, image: image) { [weak self] result in
            guard let self = self else { return }
            self.output?.didUpdateLoading(isLoading: false)
            
            switch result {
            case .success(let url):
                var pub = self.currentPublisher
                var currentPhotos = pub?.photos ?? []
                currentPhotos.append(url)
                pub?.photos = currentPhotos
                self.currentPublisher = pub
                
                if let finalPub = pub {
                    self.performSave(pub: finalPub)
                }
                
            case .failure(let error):
                self.output?.didFailWithError(message: error.localizedDescription)
            }
        }
    }
    
    func deleteGalleryImage(at index: Int) {
        guard var pub = currentPublisher, var photos = pub.photos, index < photos.count else { return }
        let urlToDelete = photos[index]
        
        output?.didUpdateLoading(isLoading: true)
        StorageService.shared.deleteFile(at: urlToDelete) { [weak self] error in
            guard let self = self else { return }
            // Hata olsa bile (örneğin dosya bulunamadı) Firestore'dan linki temizliyoruz ki UI düzeltsin
            photos.remove(at: index)
            pub.photos = photos
            self.currentPublisher = pub
            self.performSave(pub: pub)
        }
    }
    
    func deleteStory(at index: Int) {
        guard var pub = currentPublisher, var stories = pub.stories, index < stories.count else { return }
        guard let urlToDelete = stories[index].url else { return }
        
        output?.didUpdateLoading(isLoading: true)
        StorageService.shared.deleteFile(at: urlToDelete) { [weak self] error in
            guard let self = self else { return }
            stories.remove(at: index)
            pub.stories = stories
            self.currentPublisher = pub
            self.performSave(pub: pub)
        }
    }

    private func performSave(pub: PublisherProfile) {
        output?.didUpdateLoading(isLoading: true)
        
        // Sadece PublisherProfile'ı güncelle
        FirestoreService.shared.savePublisherProfile(profile: pub) { [weak self] error in
            self?.output?.didUpdateLoading(isLoading: false)
            if let error = error {
                self?.output?.didFailWithError(message: error.localizedDescription)
            } else {
                self?.output?.didUpdateProfile()
            }
        }
        
        // Eğer UserWatcher'ın da güncellenmesi gerekiyorsa (filtreleme için), 
        // burada bir UserModel oluşturup saveUserProfile çağrısı da yapılabilir.
    }
}
