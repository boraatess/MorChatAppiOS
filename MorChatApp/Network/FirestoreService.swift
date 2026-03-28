import Foundation
import FirebaseFirestore
import FirebaseAuth



protocol FirestoreServiceProtocol {
    func fetchPublisherProfiles(completion: @escaping (Result<[PublisherProfile], Error>) -> Void)
    func fetchPublisherProfile(publisherId: String, completion: @escaping (Result<PublisherProfile, Error>) -> Void)
    func fetchNotifications(completion: @escaping (Result<[NotificationModel], Error>) -> Void)
    func fetchLikedPublishers(completion: @escaping (Result<[PublisherProfile], Error>) -> Void)
    func saveUserProfile(user: UserModel, completion: @escaping (Error?) -> Void)
    func fetchUserProfile(uid: String, completion: @escaping (Result<UserModel, Error>) -> Void)
    func updateFCMToken(token: String)
    func fetchWatcherNotifications(completion: @escaping (Result<[NotificationModel], Error>) -> Void)
    func fetchPublisherNotifications(completion: @escaping (Result<[NotificationModel], Error>) -> Void)
}




class FirestoreService: FirestoreServiceProtocol {
    static let shared = FirestoreService()
    private let db = Firestore.firestore()
    
    // publisherprofile koleksiyonundan verileri okur
    func fetchPublisherProfiles(completion: @escaping (Result<[PublisherProfile], Error>) -> Void) {
        db.collection("PublisherProfile").getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let documents = snapshot?.documents else {
                completion(.success([]))
                return
            }
            
            var profiles = [PublisherProfile]()
            for document in documents {
                let data = document.data()
                
                let id = document.documentID
                let about = data["about"] as? String
                let age = data["age"] as? Int
                let email = data["email"] as? String
                let language = data["language"] as? String
                let lastSeenTimestamp = data["last_seen"] as? Timestamp
                let last_seen = lastSeenTimestamp?.dateValue()
                let msgToken = data["msgToken"] as? String
                let name = data["name"] as? String
                let phoneNumber = data["phoneNumber"] as? String
                let point = data["point"] as? Int
                let profilePic = data["profilePic"] as? String
                let status = data["status"] as? String
                let tagList = data["tagList"] as? [Int]
                
                let profile = PublisherProfile(
                    id: id,
                    about: about,
                    age: age,
                    email: email,
                    language: language,
                    last_seen: last_seen,
                    msgToken: msgToken,
                    name: name,
                    phoneNumber: phoneNumber,
                    point: point,
                    profilePic: profilePic,
                    status: status,
                    tagList: tagList
                )
                profiles.append(profile)
            }
            
            completion(.success(profiles))
        }
    }

    func fetchPublisherProfile(publisherId: String, completion: @escaping (Result<PublisherProfile, Error>) -> Void) {
        db.collection("PublisherProfile").document(publisherId).getDocument { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = snapshot?.data() else {
                let err = NSError(domain: "Firestore", code: 404, userInfo: [NSLocalizedDescriptionKey: "Profile not found"])
                completion(.failure(err))
                return
            }
            
            let id = snapshot?.documentID
            let about = data["about"] as? String
            let age = data["age"] as? Int
            let email = data["email"] as? String
            let language = data["language"] as? String
            let last_seen = (data["last_seen"] as? Timestamp)?.dateValue()
            let msgToken = data["msgToken"] as? String
            let name = data["name"] as? String
            let phoneNumber = data["phoneNumber"] as? String
            let point = data["point"] as? Int
            let profilePic = data["profilePic"] as? String
            let status = data["status"] as? String
            let tagList = data["tagList"] as? [Int]
            
            let profile = PublisherProfile(
                id: id,
                about: about,
                age: age,
                email: email,
                language: language,
                last_seen: last_seen,
                msgToken: msgToken,
                name: name,
                phoneNumber: phoneNumber,
                point: point,
                profilePic: profilePic,
                status: status,
                tagList: tagList
            )
            completion(.success(profile))
        }
    }

    
    // notifications koleksiyonundan verileri okur
    func fetchNotifications(completion: @escaping (Result<[NotificationModel], Error>) -> Void) {
        db.collection("notifications").getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let documents = snapshot?.documents else {
                completion(.success([]))
                return
            }
            
            var notifications = [NotificationModel]()
            for document in documents {
                let data = document.data()
                let id = document.documentID
                let title = data["title"] as? String
                let message = data["message"] as? String
                let timestamp = (data["timestamp"] as? Timestamp)?.dateValue()
                let image = data["image"] as? String
                
                let notification = NotificationModel(id: id, title: title, message: message, timestamp: timestamp, image: image)
                notifications.append(notification)
            }
            
            completion(.success(notifications))
        }
    }
    
    // UserWatcherFavList koleksiyonundan favorileri okur, sonra PublisherProfile'dan detayları çeker
    func fetchLikedPublishers(completion: @escaping (Result<[PublisherProfile], Error>) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(.success([]))
            return
        }
        
        db.collection("UserWatcherFavList").document(uid).getDocument { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = snapshot?.data(),
                  let favIds = data["likedPublisherList"] as? [String], !favIds.isEmpty else {

                completion(.success([]))
                return
            }
            
            // Fetch each publisher profile
            var profiles = [PublisherProfile]()
            let group = DispatchGroup()
            
            for publisherId in favIds {
                group.enter()
                self.fetchPublisherProfile(publisherId: publisherId) { result in
                    if case .success(let profile) = result {
                        profiles.append(profile)
                    }
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                completion(.success(profiles))
            }
        }
    }

    
    func saveUserProfile(user: UserModel, completion: @escaping (Error?) -> Void) {
        var dict: [String: Any] = [
            "id": user.uid,
            "name": user.name ?? "",
            "email": user.email ?? "",
            "profileImage": user.photoURL ?? "",
            "createdAt": user.createdAt
        ]
        
        if let currentFCM = UserDefaults.standard.string(forKey: "fcm_token") {
            dict["msgToken"] = currentFCM
        }
        
        db.collection("UserWatcher").document(user.uid).setData(dict, merge: true) { error in
            completion(error)
        }
    }
    
    func updateFCMToken(token: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        db.collection("UserWatcher").document(uid).setData(["msgToken": token], merge: true)
    }
    
    func fetchUserProfile(uid: String, completion: @escaping (Result<UserModel, Error>) -> Void) {

        db.collection("UserWatcher").document(uid).getDocument { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = snapshot?.data(),
                  let uid = data["id"] as? String else {
                let err = NSError(domain: "Firestore", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found"])
                completion(.failure(err))
                return
            }
            
            let name = data["name"] as? String
            let email = data["email"] as? String
            let photoURL = data["profileImage"] as? String
            let createdAt = (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
            
            let user = UserModel(uid: uid, name: name, email: email, photoURL: photoURL, createdAt: createdAt)
            completion(.success(user))
        }
    }
    
    func submitBecomeGuideForm(data: [String: Any], completion: @escaping (Error?) -> Void) {
        db.collection("PublisherSiteForm").addDocument(data: data) { error in
            completion(error)
        }
    }
    
    func addToFavorites(publisherId: String, completion: @escaping (Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not logged in"]))
            return
        }
        
        db.collection("UserWatcherFavList").document(uid).setData([
            "likedPublisherList": FieldValue.arrayUnion([publisherId])
        ], merge: true) { error in

            completion(error)
        }
    }
    
    func removeFromFavorites(publisherId: String, completion: @escaping (Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not logged in"]))
            return
        }
        
        db.collection("UserWatcherFavList").document(uid).updateData([
            "likedPublisherList": FieldValue.arrayRemove([publisherId])
        ]) { error in

            completion(error)
        }
    }
    
    // Fetch notifications for Watcher (User)
    func fetchWatcherNotifications(completion: @escaping (Result<[NotificationModel], Error>) -> Void) {
        db.collection("NotificationListWatcher").getDocuments { snapshot, error in
            self.mapNotifications(snapshot: snapshot, error: error, completion: completion)
        }
    }
    
    // Fetch notifications for Publisher (Guide)
    func fetchPublisherNotifications(completion: @escaping (Result<[NotificationModel], Error>) -> Void) {
        db.collection("NotificationListPublisher").getDocuments { snapshot, error in
            self.mapNotifications(snapshot: snapshot, error: error, completion: completion)
        }
    }
    
    private func mapNotifications(snapshot: QuerySnapshot?, error: Error?, completion: @escaping (Result<[NotificationModel], Error>) -> Void) {
        if let error = error {
            completion(.failure(error))
            return
        }
        
        let notifications = snapshot?.documents.compactMap { doc -> NotificationModel? in
            let data = doc.data()
            let id = doc.documentID
            let title = data["title"] as? String
            let message = data["message"] as? String
            let timestamp = (data["timestamp"] as? Timestamp)?.dateValue()
            let image = data["image"] as? String
            return NotificationModel(id: id, title: title, message: message, timestamp: timestamp, image: image)
        } ?? []
        
        completion(.success(notifications))
    }
}

