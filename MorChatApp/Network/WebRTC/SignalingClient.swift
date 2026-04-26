
//
//  SignalingClient.swift
//  MorChatApp
//
//  Created by bora ateş on 12.02.2026.
//


import Foundation
import FirebaseFirestore
import FirebaseAuth
// WebRTC importu sildik


protocol SignalingClientDelegate: AnyObject {
    func signalingClient(_ client: SignalingClient, didChangeStatus status: String)
}

// MARK: - SignalingClient
final class SignalingClient {
    weak var delegate: SignalingClientDelegate?
    private let db = Firestore.firestore()
    private var callId: String = ""
    private var listener: ListenerRegistration?

    static let shared = SignalingClient()
    private init() {}

    deinit {
        listener?.remove()
    }

    // MARK: - Caller Flow
    func createCall(receiverId: String, isVideo: Bool, completion: @escaping (String) -> Void) {
        guard let callerId = Auth.auth().currentUser?.uid else { return }
        let userType = UserDefaults.standard.string(forKey: "userType") ?? "user"
        
        print("📞 Arama Başlatılıyor...")
        
        let callDoc = db.collection("Calls").document()
        let roomId = callDoc.documentID
        self.callId = roomId

        // 1. Önce her iki tarafın bilgilerini toplayalım
        fetchCallParticipantsInfo(callerId: callerId, receiverId: receiverId, userType: userType) { participantsData in
            
            var callData: [String: Any] = participantsData
            callData["roomId"] = roomId
            callData["status"] = "ringing"
            callData["isCall"] = true
            callData["isVoiceOnly"] = !isVideo
            callData["type"] = isVideo ? "video" : "voice"
            callData["timestamp"] = FieldValue.serverTimestamp()
            callData["createdAt"] = FieldValue.serverTimestamp() // Eski uyumluluk için

            callDoc.setData(callData) { [weak self] error in
                guard let self = self else { return }
                if error == nil {
                    // Karşı tarafın bildirim listesine döküman yaz
                    self.createNotificationLog(callId: roomId, receiverId: receiverId, isVideo: isVideo)
                    completion(roomId)
                }
            }
        }

        // Durum takibi
        listener = callDoc.addSnapshotListener { [weak self] snapshot, _ in
            guard let self = self, let data = snapshot?.data() else { return }
            if let status = data["status"] as? String {
                self.delegate?.signalingClient(self, didChangeStatus: status)
            }
        }
    }

    private func fetchCallParticipantsInfo(callerId: String, receiverId: String, userType: String, completion: @escaping ([String: Any]) -> Void) {
        let myCollection = (userType == "guide") ? "PublisherProfile" : "UserWatcher"
        let otherCollection = (userType == "guide") ? "UserWatcher" : "PublisherProfile"
        
        var resultData: [String: Any] = [
            "callerId": callerId,
            "calleeId": receiverId
        ]
        
        let group = DispatchGroup()
        
        // Kendi bilgilerimi çek (Arayan)
        group.enter()
        db.collection(myCollection).document(callerId).getDocument { snapshot, _ in
            if let data = snapshot?.data() {
                let name = data["name"] as? String ?? ""
                resultData["callerName"] = name
                // Eğer ben publisher isem
                if userType == "guide" {
                    resultData["publisherId"] = callerId
                    resultData["publisherName"] = name
                    resultData["publisherImage"] = (data["profilePic"] as? String) ?? ""
                } else {
                    resultData["watcherId"] = callerId
                    resultData["watcherName"] = name
                }
            }
            group.leave()
        }
        
        // Karşı tarafın bilgilerini çek (Aranan)
        group.enter()
        db.collection(otherCollection).document(receiverId).getDocument { snapshot, _ in
            if let data = snapshot?.data() {
                let name = data["name"] as? String ?? ""
                resultData["calledUserName"] = name
                // Eğer karşı taraf publisher ise
                if userType == "user" {
                    resultData["publisherId"] = receiverId
                    resultData["publisherName"] = name
                    resultData["publisherImage"] = (data["profilePic"] as? String) ?? ""
                } else {
                    resultData["watcherId"] = receiverId
                    resultData["watcherName"] = name
                }
            }
            group.leave()
        }
        
        group.notify(queue: .main) {
            completion(resultData)
        }
    }

    private func createNotificationLog(callId: String, receiverId: String, isVideo: Bool) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        let userType = UserDefaults.standard.string(forKey: "userType") ?? "user"
        
        // Kendi profil bilgilerimizi (Ad, Resim vb.) almak için profil tablomuza bakmalıyız
        let myCollection = (userType == "guide") ? "PublisherProfile" : "UserWatcher"
        
        Firestore.firestore().collection(myCollection).document(currentUid).getDocument { snapshot, _ in
            guard let data = snapshot?.data() else { return }
            let myName = data["name"] as? String ?? "Bilinmeyen"
            let myImage = (data["profilePic"] as? String) ?? (data["profileImage"] as? String) ?? ""
            let myPhone = data["phoneNumber"] as? String ?? ""
            
            let notificationData: [String: Any] = [
                "callId": callId,
                "image": myImage,
                "isVoiceOnly": !isVideo,
                "name": myName,
                "phone": myPhone,
                "publisherId": (userType == "guide") ? currentUid : receiverId,
                "watcherId": (userType == "guide") ? receiverId : currentUid,
                "timeStamp": FieldValue.serverTimestamp()
            ]
            
            let targetCollection = (userType == "user") ? "NotificationListPublisher" : "NotificationListWatcher"
            
            print("📣 Bildirim Hazırlanıyor...")
            print("📣 Hedef Koleksiyon: \(targetCollection)")
            print("📣 Aranan Kişi (ReceiverID): \(receiverId)")
            
            Firestore.firestore().collection(targetCollection).addDocument(data: notificationData) { error in
                if let error = error {
                    print("❌ Bildirim oluşturulamadı: \(error.localizedDescription)")
                } else {
                    print("✅ Bildirim '\(targetCollection)' koleksiyonuna başarıyla yazıldı. Hedef: \(receiverId)")
                }
            }
        }
        
    }

    // MARK: - Receiver Flow
    func joinCall(callId: String) {
        self.callId = callId
        let callDoc = db.collection("Calls").document(callId)

        listener = callDoc.addSnapshotListener { [weak self] snapshot, _ in
            guard let self = self, let data = snapshot?.data() else { return }
            if let status = data["status"] as? String {
                self.delegate?.signalingClient(self, didChangeStatus: status)
            }
        }
    }

    func endCall() {
        guard !callId.isEmpty else { return }
        db.collection("Calls").document(callId).updateData(["status": "ended"])
        callId = ""
        listener?.remove()
        listener = nil
    }

    func acceptCall(callId: String) {
        db.collection("Calls").document(callId).updateData(["status": "accepted"])
        self.delegate?.signalingClient(self, didChangeStatus: "accepted")
    }

    func rejectCall(callId: String) {
        db.collection("Calls").document(callId).updateData(["status": "rejected"])
    }

    // MARK: - Incoming Call Listener
    func listenForIncomingCalls(completion: @escaping (String, String, Bool) -> Void) -> ListenerRegistration? {
        guard let currentUid = Auth.auth().currentUser?.uid else { return nil }
        
        return db.collection("Calls")
            .whereField("receiverId", isEqualTo: currentUid)
            .whereField("status", isEqualTo: "ringing")
            .addSnapshotListener { snippet, _ in
                guard let changes = snippet?.documentChanges else { return }
                for change in changes where change.type == .added {
                    let doc = change.document
                    let data = doc.data()
                    let callId = doc.documentID
                    let callerId = data["callerId"] as? String ?? ""
                    let isVideo = (data["type"] as? String) == "video"
                    completion(callId, callerId, isVideo)
                    
                }
            }
        
    }
}
