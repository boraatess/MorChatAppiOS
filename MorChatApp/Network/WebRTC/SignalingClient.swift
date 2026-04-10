
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
        
        print("📞 Arama Başlatılıyor...")
        print("📞 Arayan (Kimliğim): \(callerId)")
        print("📞 Aranan (Karşı Taraf): \(receiverId)")
        
        let callDoc = db.collection("Calls").document()
        self.callId = callDoc.documentID

        let callData: [String: Any] = [
            "callerId": callerId,
            "receiverId": receiverId,
            "status": "ringing",
            "type": isVideo ? "video" : "voice",
            "createdAt": FieldValue.serverTimestamp()
        ]

        callDoc.setData(callData) { [weak self] error in
            guard let self = self else { return }
            if error == nil {
                // 🔥 Arama kaydı oluşturulduğunda bildirimi de patlatalım
                self.createNotificationLog(callId: self.callId, receiverId: receiverId, isVideo: isVideo)
                completion(self.callId)
            }
        }

        // Sadece durum takibi yapıyoruz
        listener = callDoc.addSnapshotListener { [weak self] snapshot, _ in
            guard let self = self, let data = snapshot?.data() else { return }
            if let status = data["status"] as? String {
                self.delegate?.signalingClient(self, didChangeStatus: status)
            }
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
