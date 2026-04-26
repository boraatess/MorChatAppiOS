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
