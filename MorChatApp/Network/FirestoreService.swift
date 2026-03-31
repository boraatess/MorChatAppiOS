import Foundation
import FirebaseFirestore
import FirebaseAuth

protocol FirestoreServiceProtocol {
    func fetchPublisherProfiles(completion: @escaping (Result<[PublisherProfile], Error>) -> Void)
    func fetchPublisherProfile(publisherId: String, completion: @escaping (Result<PublisherProfile, Error>) -> Void)
   //  func fetchNotifications(completion: @escaping (Result<[NotificationModel], Error>) -> Void)
    func fetchLikedPublishers(completion: @escaping (Result<[PublisherProfile], Error>) -> Void)
    func saveUserProfile(user: UserModel, completion: @escaping (Error?) -> Void)
    func savePublisherProfile(profile: PublisherProfile, completion: @escaping (Error?) -> Void)
    func fetchUserProfile(uid: String, completion: @escaping (Result<UserModel, Error>) -> Void)
    func fetchWatchers(completion: @escaping (Result<[UserModel], Error>) -> Void)
    func updateFCMToken(token: String)
    func fetchWatcherNotifications(completion: @escaping (Result<[NotificationModel], Error>) -> Void)
    func fetchPublisherNotifications(completion: @escaping (Result<[NotificationModel], Error>) -> Void)
    func fetchPublisherTags(completion: @escaping (Result<[TagModel], Error>) -> Void)
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
                let interests = data["interests"] as? [String] ?? []
                
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
                    interests: interests,
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
            let interests = data["interests"] as? [String] ?? []
            
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
                interests: interests,
                tagList: tagList
            )
            completion(.success(profile))
        }
    }

    /*
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
    }*/
    
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
            "createdAt": user.createdAt,
            "interests": user.interests ?? [],
            "tagList": user.tagList ?? [],
            "age": user.age ?? 0,
            "status": user.status ?? "Online"
        ]
        
        if let currentFCM = UserDefaults.standard.string(forKey: "fcm_token") {
            dict["msgToken"] = currentFCM
        }
        
        db.collection("UserWatcher").document(user.uid).setData(dict, merge: true) { error in
            completion(error)
        }
    }
    
    func savePublisherProfile(profile: PublisherProfile, completion: @escaping (Error?) -> Void) {
        guard let uid = profile.id else {
            completion(NSError(domain: "Firestore", code: 400, userInfo: [NSLocalizedDescriptionKey: "Publisher ID is missing"]))
            return
        }
        
        var dict: [String: Any] = [
            "id": uid,
            "name": profile.name ?? "",
            "about": profile.about ?? "",
            "age": profile.age ?? 0,
            "email": profile.email ?? "",
            "language": profile.language ?? "en",
            "last_seen": profile.last_seen ?? Date(),
            "phoneNumber": profile.phoneNumber ?? "",
            "point": profile.point ?? 0,
            "profilePic": profile.profilePic ?? "",
            "status": profile.status ?? "Online",
            "interests": profile.interests ?? [],
            "tagList": profile.tagList ?? []
        ]
        
        if let currentFCM = UserDefaults.standard.string(forKey: "fcm_token") {
            dict["msgToken"] = currentFCM
        }
        
        db.collection("PublisherProfile").document(uid).setData(dict, merge: true) { error in
            completion(error)
        }
    }
    
    func updateFCMToken(token: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        // Update UserWatcher (for regular users)
        db.collection("UserWatcher").document(uid).setData(["msgToken": token], merge: true)
        
        // Update PublisherProfile (for guides/publishers)
        // Note: It's safe to call merge:true on both, as we only update the document if it exists or create/update the field.
        db.collection("PublisherProfile").document(uid).setData(["msgToken": token], merge: true)
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
            let interests = data["interests"] as? [String] ?? []
            let tagList = data["tagList"] as? [Int] ?? []
            let age = data["age"] as? Int ?? 0
            let status = data["status"] as? String ?? "Online"
            
            let user = UserModel(uid: uid, name: name, email: email, photoURL: photoURL, createdAt: createdAt, interests: interests, tagList: tagList, age: age, status: status)
            completion(.success(user))
        }
    }
    
    func fetchWatchers(completion: @escaping (Result<[UserModel], Error>) -> Void) {
        db.collection("UserWatcher").getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            let users = snapshot?.documents.compactMap { doc -> UserModel? in
                let data = doc.data()
                guard let uid = (data["id"] as? String) ?? (data["uid"] as? String) else { return nil }
                
                let name = data["name"] as? String
                let email = data["email"] as? String
                let photoURL = data["profileImage"] as? String
                let createdAt = (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
                
                // --- Robust Tag ID (Int) Extraction ---
                var tagList: [Int] = []
                // Priority 1: Direct Int Arrays
                if let tagArrayInt = (data["tagList"] as? [Int]) ?? (data["tag_list"] as? [Int]) {
                    tagList = tagArrayInt
                } 
                // Priority 2: String Arrays (e.g. ["2", "5"]) - Often found in UserWatcher interests field
                else if let tagArrayStr = (data["interests"] as? [String]) ?? (data["tagList"] as? [String]) ?? (data["tag_list"] as? [String]) {
                    // Try to convert each string to an Int. If it fails, it's probably a Name, not an ID.
                    tagList = tagArrayStr.compactMap { Int($0.trimmingCharacters(in: .whitespaces)) }
                }
                // Priority 3: Comma separated string (e.g. "2,5")
                else if let tagStr = (data["tagList"] as? String) ?? (data["tag_list"] as? String) {
                    tagList = tagStr.components(separatedBy: ",").compactMap { Int($0.trimmingCharacters(in: .whitespaces)) }
                }

                // --- Robust Interest (String) Extraction (Names) ---
                var interests: [String] = []
                if let interestsArray = (data["interests"] as? [String]) ?? (data["ilgi_alanlari"] as? [String]) {
                    // If these are actually names (not numeric), keep them as interests
                    // If they are numeric, they are already in tagList as Ints.
                    interests = interestsArray.filter { Int($0) == nil } 
                }

                let age = (data["age"] as? Int) ?? (data["yaş"] as? Int) ?? (data["userAge"] as? Int) ?? 0
                let status = (data["status"] as? String) ?? (data["durum"] as? String) ?? "Online"
                
                return UserModel(uid: uid, name: name, email: email, photoURL: photoURL, createdAt: createdAt, interests: interests, tagList: tagList, age: age, status: status)
            } ?? []
            
            completion(.success(users))
        }
    }
    
    func submitBecomeGuideForm(data: [String: Any], completion: @escaping (Error?) -> Void) {
        db.collection("PublisherSiteForm").addDocument(data: data) { error in
            completion(error)
        }
    }
    
    func fetchPublisherTags(completion: @escaping (Result<[TagModel], Error>) -> Void) {
        db.collection("PublisherTagList").getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            let tags = snapshot?.documents.compactMap { doc -> TagModel? in
                let data = doc.data()
                guard let id = data["id"] as? Int, let name = data["name"] as? String else { return nil }
                return TagModel(id: id, name: name)
            }.sorted(by: { $0.id < $1.id }) ?? []
            
            completion(.success(tags))
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
            let callId = data["callId"] as? String
            let image = data["image"] as? String
            let isVoiceOnly = data["isVoiceOnly"] as? Bool
            let name = data["name"] as? String
            let phone = data["phone"] as? String
            let publisherId = data["publisherId"] as? String
            let watcherId = data["watcherId"] as? String
            
            // User specifically used 'timeStamp' (capitalized T) in example
            let timestampValue = (data["timeStamp"] as? Timestamp) ?? (data["timestamp"] as? Timestamp)
            let timestamp = timestampValue?.dateValue()
            
            return NotificationModel(
                id: id,
                callId: callId,
                image: image,
                isVoiceOnly: isVoiceOnly,
                name: name,
                phone: phone,
                publisherId: publisherId,
                timestamp: timestamp,
                watcherId: watcherId
            )
        } ?? []
        
        completion(.success(notifications))
    }
}

