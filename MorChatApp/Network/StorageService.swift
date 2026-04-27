
import Foundation
import FirebaseStorage
import UIKit


class StorageService {
    
    
    static let shared = StorageService()
    private let storage = Storage.storage().reference()
    
    
    private init() {}
    
    /// Profil fotoğrafını Firebase Storage'a yükler (UserDefaults üzerinden tip kontrolü yapar)
    func uploadProfileImage(uid: String, image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            completion(.failure(NSError(domain: "MorChat", code: -1, userInfo: [NSLocalizedDescriptionKey: "Görsel işlenemedi"])))
            return
        }
        
        let userType = UserDefaults.standard.string(forKey: "userType") ?? "user"
        let prefix = (userType == "publisher" || userType == "guide") ? "publisherProfile" : "watcherProfile"
        
        let fileName = "\(prefix)+\(uid).jpg"
        let profileImageRef = storage.child(fileName)
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        profileImageRef.putData(imageData, metadata: metadata) { metadata, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // Yükleme başarılı, indirme linkini (Download URL) alıyoruz
            profileImageRef.downloadURL { url, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let downloadURL = url?.absoluteString else {
                    completion(.failure(NSError(domain: "MorChat", code: -1, userInfo: [NSLocalizedDescriptionKey: "URL alınamadı"])))
                    return
                }
                
                completion(.success(downloadURL))
            }
        }
    }

    /// Hikaye fotoğrafını Firebase Storage'a yükler (Root dizin: stories+uid+uuid.jpg)
    func uploadStoryImage(uid: String, image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.6) else {
            completion(.failure(NSError(domain: "MorChat", code: -1, userInfo: [NSLocalizedDescriptionKey: "Görsel işlenemedi"])))
            return
        }
        
        let fileName = "stories+\(uid)+\(UUID().uuidString).jpg"
        let storyRef = storage.child(fileName)
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        storyRef.putData(imageData, metadata: metadata) { metadata, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            storyRef.downloadURL { url, error in
                if let error = error { completion(.failure(error)) }
                else if let downloadURL = url?.absoluteString { completion(.success(downloadURL)) }
            }
        }
    }

    /// Galeri fotoğrafını Firebase Storage'a yükler (Root dizin: gallery+uid+uuid.jpg)
    func uploadGalleryImage(uid: String, image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.6) else {
            completion(.failure(NSError(domain: "MorChat", code: -1, userInfo: [NSLocalizedDescriptionKey: "Görsel işlenemedi"])))
            return
        }
        
        let fileName = "gallery+\(uid)+\(UUID().uuidString).jpg"
        let galleryRef = storage.child(fileName)
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        galleryRef.putData(imageData, metadata: metadata) { metadata, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            galleryRef.downloadURL { url, error in
                if let error = error { completion(.failure(error)) }
                else if let downloadURL = url?.absoluteString { completion(.success(downloadURL)) }
            }
        }
    }

    /// Linki verilen dosyayı Storage'dan fiziksel olarak siler
    func deleteFile(at url: String, completion: @escaping (Error?) -> Void) {
        let ref = Storage.storage().reference(forURL: url)
        ref.delete { error in
            completion(error)
        }
    }
}
