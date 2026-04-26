
import Foundation
import FirebaseStorage
import UIKit


class StorageService {
    
    
    static let shared = StorageService()
    private let storage = Storage.storage().reference()
    
    
    private init() {}
    
    /// Profil fotoğrafını Firebase Storage'a yükler
    func uploadProfileImage(uid: String, image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        // Görseli sıkıştırıp Data formatına çeviriyoruz
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            completion(.failure(NSError(domain: "MorChat", code: -1, userInfo: [NSLocalizedDescriptionKey: "Görsel işlenemedi"])))
            return
        }
        
        // Storage yolu: profile_images/{uid}.jpg
        let profileImageRef = storage.child("profile_images").child("\(uid).jpg")
        
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
}
