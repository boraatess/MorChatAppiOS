import Foundation
import FirebaseFirestore
import FirebaseAuth

protocol FirestoreServiceProtocol {
    func fetchPublisherProfiles(completion: @escaping (Result<[PublisherProfile], Error>) -> Void)
    func listenPublisherProfiles(completion: @escaping (Result<[PublisherProfile], Error>) -> Void) -> ListenerRegistration?
    func fetchPublisherProfile(publisherId: String, completion: @escaping (Result<PublisherProfile, Error>) -> Void)
   //  func fetchNotifications(completion: @escaping (Result<[NotificationModel], Error>) -> Void)
    func fetchLikedPublishers(completion: @escaping (Result<[PublisherProfile], Error>) -> Void)
    func saveUserProfile(user: UserModel, completion: @escaping (Error?) -> Void)
    func savePublisherProfile(profile: PublisherProfile, completion: @escaping (Error?) -> Void)
    func fetchUserProfile(uid: String, completion: @escaping (Result<UserModel, Error>) -> Void)
    func fetchWatchers(completion: @escaping (Result<[UserModel], Error>) -> Void)
    func updateFCMToken(token: String)
    func fetchWatcherNotifications(completion: @escaping (Result<[NotificationModel], Error>) -> Void)
    func listenWatcherNotifications(completion: @escaping (Result<[NotificationModel], Error>) -> Void) -> ListenerRegistration?
    func fetchPublisherNotifications(completion: @escaping (Result<[NotificationModel], Error>) -> Void)
    func listenPublisherNotifications(completion: @escaping (Result<[NotificationModel], Error>) -> Void) -> ListenerRegistration?
    func fetchPublisherTags(completion: @escaping (Result<[TagModel], Error>) -> Void)
    func blockUser(targetId: String, targetName: String, completion: @escaping (Error?) -> Void)
    func unblockUser(targetId: String, targetName: String, completion: @escaping (Error?) -> Void)
    func addCoins(amount: Int, completion: @escaping (Error?) -> Void)
    func deductCoins(amount: Int, completion: @escaping (Error?) -> Void)
    func applyCoinPurchase(transactionId: String, productId: String, amount: Int, completion: @escaping (Result<Bool, Error>) -> Void)
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
            
            let profiles = documents.compactMap { self.parseProfile(from: $0) }
            completion(.success(profiles))
        }
    }
    
    // 🔥 ANLIK DİNLEME: Veriler değiştikçe tetiklenir
    func listenPublisherProfiles(completion: @escaping (Result<[PublisherProfile], Error>) -> Void) -> ListenerRegistration? {
        return db.collection("PublisherProfile").addSnapshotListener { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let documents = snapshot?.documents else {
                completion(.success([]))
                return
            }
            
            let profiles = documents.compactMap { self.parseProfile(from: $0) }
            completion(.success(profiles))
        }
    }

    // Ortak Parser Metodu
    private func parseProfile(from document: DocumentSnapshot) -> PublisherProfile? {
        guard let data = document.data() else { return nil }
        
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
        let photos = data["photos"] as? [String]
        
        // Story parse mantığı (Map dizisinden StoryModel'e)
        let storyData = data["stories"] as? [[String: Any]] ?? []
        let stories = storyData.map { dict in
            StoryModel(
                id: dict["id"] as? String,
                url: dict["url"] as? String,
                timestamp: dict["timestamp"] as? Int64,
                type: dict["type"] as? String,
                viewCount: dict["viewCount"] as? Int
            )
        }
        
        let tagList = data["tagList"] as? [Int]
        let blockedWatcherList = data["blockedWatcherList"] as? [[String: String]]
        
        return PublisherProfile(
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
            tagList: tagList,
            photos: photos,
            stories: stories.isEmpty ? nil : stories,
            blockedWatcherList: blockedWatcherList
        )
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
            let photos = data["photos"] as? [String]
            
            let storyData = data["stories"] as? [[String: Any]] ?? []
            let stories = storyData.map { dict in
                StoryModel(
                    id: dict["id"] as? String,
                    url: dict["url"] as? String,
                    timestamp: dict["timestamp"] as? Int64,
                    type: dict["type"] as? String,
                    viewCount: dict["viewCount"] as? Int
                )
            }
            
            let tagList = data["tagList"] as? [Int]
            let blockedWatcherList = data["blockedWatcherList"] as? [[String: String]]

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
                tagList: tagList,
                photos: photos,
                stories: stories.isEmpty ? nil : stories,
                blockedWatcherList: blockedWatcherList
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
    
    func updateProfileImageURL(uid: String, url: String, completion: @escaping (Error?) -> Void) {
        let userType = UserDefaults.standard.string(forKey: "userType") ?? "user"
        
        let myCollection = (userType == "guide") ? "PublisherProfile" : "UserWatcher"
        
        // Yayıncı/Rehber ise farklı koleksiyon ve alan adı kullanılır
        if userType == "guide" {
            db.collection("PublisherProfile").document(uid).updateData([
                "profilePic": url
            ]) { error in
                completion(error)
            }
        } else {
            // İzleyici ise standart UserWatcher ve profileImage
            db.collection("UserWatcher").document(uid).updateData([
                "profileImage": url
            ]) { error in
                completion(error)
            }
        }
    }
    
    func saveUserProfile(user: UserModel, completion: @escaping (Error?) -> Void) {
        var dict = user.dictionary
        
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
            "tagList": profile.tagList ?? [],
            "photos": profile.photos ?? [],
            "stories": profile.stories?.map { $0.dictionary } ?? []
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
        db.collection("PublisherProfile").document(uid).setData(["msgToken": token], merge: true)
    }

    func updateVoIPToken(token: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        db.collection("UserWatcher").document(uid).setData(["voipToken": token], merge: true)
        db.collection("PublisherProfile").document(uid).setData(["voipToken": token], merge: true)
    }

    func applyCoinPurchase(transactionId: String, productId: String, amount: Int, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            let error = NSError(
                domain: "Firestore",
                code: 401,
                userInfo: [NSLocalizedDescriptionKey: "User must be logged in to complete purchase."]
            )
            completion(.failure(error))
            return
        }

        let userRef = db.collection("UserWatcher").document(uid)
        let purchaseRef = userRef.collection("coinPurchases").document(transactionId)

        db.runTransaction({ transaction, errorPointer in
            do {
                let existingPurchase = try transaction.getDocument(purchaseRef)
                if existingPurchase.exists {
                    return false
                }

                transaction.setData([
                    "creditCount": FieldValue.increment(Int64(amount))
                ], forDocument: userRef, merge: true)

                transaction.setData([
                    "transactionId": transactionId,
                    "productId": productId,
                    "amount": amount,
                    "createdAt": FieldValue.serverTimestamp()
                ], forDocument: purchaseRef)

                return true
            } catch {
                errorPointer?.pointee = error as NSError
                return nil
            }
        }) { result, error in
            if let error {
                completion(.failure(error))
                return
            }

            completion(.success((result as? Bool) ?? false))
        }
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
            let blockedPublisherList = data["blockedPublisherList"] as? [[String: String]]
            
            // New fields from snapshot
            let creditCount = data["creditCount"] as? Int ?? 0
            let adsWatchedTotal = data["adsWatchedTotal"] as? Int ?? 0
            let calledPublisherId = data["calledPublisherId"] as? String
            let isOnline = data["isOnline"] as? Bool ?? true
            let language = data["language"] as? String ?? "tr"
            let lastAdWatchedTime = data["lastAdWatchedTime"] as? Int64
            let phone = data["phone"] as? String
            let msgToken = data["msgToken"] as? String
            
            let user = UserModel(
                uid: uid,
                name: name,
                email: email,
                photoURL: photoURL,
                createdAt: createdAt,
                interests: interests,
                tagList: tagList,
                age: age,
                status: status,
                blockedPublisherList: blockedPublisherList,
                creditCount: creditCount,
                adsWatchedTotal: adsWatchedTotal,
                calledPublisherId: calledPublisherId,
                isOnline: isOnline,
                language: language,
                lastAdWatchedTime: lastAdWatchedTime,
                phone: phone,
                msgToken: msgToken
            )
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
                
                // Extra fields for robustness
                let creditCount = data["creditCount"] as? Int ?? 0
                let adsWatchedTotal = data["adsWatchedTotal"] as? Int ?? 0
                
                return UserModel(
                    uid: uid,
                    name: name,
                    email: email,
                    photoURL: photoURL,
                    createdAt: createdAt,
                    interests: interests,
                    tagList: tagList,
                    age: age,
                    status: status,
                    blockedPublisherList: nil,
                    creditCount: creditCount,
                    adsWatchedTotal: adsWatchedTotal,
                    calledPublisherId: data["calledPublisherId"] as? String,
                    isOnline: data["isOnline"] as? Bool ?? true,
                    language: data["language"] as? String ?? "tr",
                    lastAdWatchedTime: data["lastAdWatchedTime"] as? Int64,
                    phone: data["phone"] as? String,
                    msgToken: data["msgToken"] as? String
                )
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
    
    func blockUser(targetId: String, targetName: String, completion: @escaping (Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userType = UserDefaults.standard.string(forKey: "userType") ?? "user"
        let myCollection = (userType == "guide") ? "PublisherProfile" : "UserWatcher"
        let listName = (userType == "guide") ? "blockedWatcherList" : "blockedPublisherList"
        
        let blockData: [String: Any] = [
            "id": targetId,
            "name": targetName
        ]
        
        db.collection(myCollection).document(uid).updateData([
            listName: FieldValue.arrayUnion([blockData])
        ]) { error in
            completion(error)
        }
    }
    
    func unblockUser(targetId: String, targetName: String, completion: @escaping (Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let userType = UserDefaults.standard.string(forKey: "userType") ?? "user"
        let myCollection = (userType == "guide") ? "PublisherProfile" : "UserWatcher"
        let listName = (userType == "guide") ? "blockedWatcherList" : "blockedPublisherList"
        
        let blockData: [String: Any] = [
            "id": targetId,
            "name": targetName
        ]
        
        db.collection(myCollection).document(uid).updateData([
            listName: FieldValue.arrayRemove([blockData])
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
    
    // 🔥 ANLIK DİNLEME: Watcher Bildirimleri (Sadece bana gelenler)
    func listenWatcherNotifications(completion: @escaping (Result<[NotificationModel], Error>) -> Void) -> ListenerRegistration? {
        guard let uid = Auth.auth().currentUser?.uid else { return nil }
        return db.collection("NotificationListWatcher")
            .whereField("watcherId", isEqualTo: uid)
            .addSnapshotListener { snapshot, error in
                self.mapNotifications(snapshot: snapshot, error: error, completion: completion)
            }
    }
    
    // 🔥 ANLIK DİNLEME: Publisher Bildirimleri (Sadece bana gelenler)
    func listenPublisherNotifications(completion: @escaping (Result<[NotificationModel], Error>) -> Void) -> ListenerRegistration? {
        guard let uid = Auth.auth().currentUser?.uid else { return nil }
        return db.collection("NotificationListPublisher")
            .whereField("publisherId", isEqualTo: uid)
            .addSnapshotListener { snapshot, error in
                self.mapNotifications(snapshot: snapshot, error: error, completion: completion)
            }
    }
    
    private func mapNotifications(snapshot: QuerySnapshot?, error: Error?, completion: @escaping (Result<[NotificationModel], Error>) -> Void) {
        if let error = error {
            completion(.failure(error))
            return
        }
        
        let docs = snapshot?.documents ?? []
        print("📡 Firestore: \(docs.count) adet döküman bulundu.")

        let notifications = docs.compactMap { doc -> NotificationModel? in
            let data = doc.data()
            let id = doc.documentID
            
            let pId = data["publisherId"] as? String
            let wId = data["watcherId"] as? String
            
            // Eğer liste boşsa buraları kontrol edeceğiz:
            print("📄 DocID: \(id) | pId: \(pId ?? "nil") | wId: \(wId ?? "nil") | name: \(data["name"] ?? "nil")")
            
            let callId = (data["callId"] as? String) ?? (data["callID"] as? String)
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
    
    func addCoins(amount: Int, completion: @escaping (Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        db.collection("UserWatcher").document(uid).updateData([
            "creditCount": FieldValue.increment(Int64(amount))
        ]) { error in
            completion(error)
        }
    }
    
    func deductCoins(amount: Int, completion: @escaping (Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        db.collection("UserWatcher").document(uid).updateData([
            "creditCount": FieldValue.increment(Int64(-amount))
        ]) { error in
            completion(error)
        }
    }
}
