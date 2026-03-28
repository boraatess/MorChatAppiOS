import Foundation
import FirebaseFirestore
import FirebaseAuth
import WebRTC

protocol SignalingClientDelegate: AnyObject {
    func signalingClient(_ client: SignalingClient, didReceiveRemoteSdp sdp: RTCSessionDescription)
    func signalingClient(_ client: SignalingClient, didReceiveCandidate candidate: RTCIceCandidate)
    func signalingClient(_ client: SignalingClient, didChangeStatus status: String)
}

final class SignalingClient {
    weak var delegate: SignalingClientDelegate?
    private let db = Firestore.firestore()
    private var callId: String = ""
    private var listener: ListenerRegistration?
    private var candidateListener: ListenerRegistration?
    
    static let shared = SignalingClient()
    
    init() {}
    
    deinit {
        listener?.remove()
        candidateListener?.remove()
    }
    
    // MARK: - Caller Flow
    
    func createCall(receiverId: String, isVideo: Bool, completion: @escaping (String) -> Void) {
        guard let callerId = Auth.auth().currentUser?.uid else { 
            print("❌ Signaling: Caller ID not found (User not logged in)")
            return 
        }
        
        if callerId == receiverId {
            print("⚠️ Signaling: You cannot call yourself.")
            return
        }
        
        print("📞 Signaling: Creating call to \(receiverId)...")
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
            if let error = error {
                print("❌ Signaling: Error creating call doc: \(error.localizedDescription)")
            } else {
                print("✅ Signaling: Call doc created with ID: \(self.callId)")
                completion(self.callId)
            }

        }

        
        // Listen for Answer and Status changes
        listener = callDoc.addSnapshotListener { [weak self] snapshot, _ in
            guard let self = self, let snapshot = snapshot, let data = snapshot.data() else { return }

            
            if let status = data["status"] as? String {
                self.delegate?.signalingClient(self, didChangeStatus: status)
            }
            
            if let answerData = data["answer"] as? [String: Any],
               let sdp = answerData["sdp"] as? String {
                let answerSdp = RTCSessionDescription(type: .answer, sdp: sdp)
                self.delegate?.signalingClient(self, didReceiveRemoteSdp: answerSdp)
            }
        }
        
        // Listen for Receiver Candidates
        candidateListener = callDoc.collection("receiverCandidates").addSnapshotListener { [weak self] snippet, _ in
            guard let self = self, let docChanges = snippet?.documentChanges else { return }

            for change in docChanges {
                if change.type == .added {
                    let data = change.document.data()
                    if let sdp = data["sdp"] as? String,
                       let sdpMLineIndex = data["sdpMLineIndex"] as? Int32,
                       let sdpMid = data["sdpMid"] as? String {
                        let candidate = RTCIceCandidate(sdp: sdp, sdpMLineIndex: sdpMLineIndex, sdpMid: sdpMid)
                        self.delegate?.signalingClient(self, didReceiveCandidate: candidate)
                    }
                }
            }
        }
    }
    
    func sendOffer(sdp: RTCSessionDescription) {
        let offer = SessionDescription(from: sdp)
        let dict: [String: Any] = ["sdp": offer.sdp, "type": offer.type]
        db.collection("Calls").document(callId).updateData(["offer": dict])
    }
    
    // MARK: - Receiver Flow
    
    func joinCall(callId: String) {
        self.callId = callId
        let callDoc = db.collection("Calls").document(callId)
        
        // Listen for Offer
        callDoc.getDocument { [weak self] snapshot, _ in
            guard let self = self, let data = snapshot?.data() else { return }

            
            if let offerData = data["offer"] as? [String: Any],
               let sdp = offerData["sdp"] as? String {
                let offerSdp = RTCSessionDescription(type: .offer, sdp: sdp)
                self.delegate?.signalingClient(self, didReceiveRemoteSdp: offerSdp)
            }
        }
        
        // Listen for Caller Candidates
        candidateListener = callDoc.collection("callerCandidates").addSnapshotListener { [weak self] snippet, _ in
            guard let self = self, let docChanges = snippet?.documentChanges else { return }

            for change in docChanges {
                if change.type == .added {
                    let data = change.document.data()
                    if let sdp = data["sdp"] as? String,
                       let sdpMLineIndex = data["sdpMLineIndex"] as? Int32,
                       let sdpMid = data["sdpMid"] as? String {
                        let candidate = RTCIceCandidate(sdp: sdp, sdpMLineIndex: sdpMLineIndex, sdpMid: sdpMid)
                        self.delegate?.signalingClient(self, didReceiveCandidate: candidate)
                    }
                }
            }
        }
    }
    
    func sendAnswer(sdp: RTCSessionDescription) {
        let answer = SessionDescription(from: sdp)
        let dict: [String: Any] = ["sdp": answer.sdp, "type": answer.type]
        db.collection("Calls").document(callId).updateData(["answer": dict, "status": "accepted"])
    }
    
    func endCall() {
        if !callId.isEmpty {
            db.collection("Calls").document(callId).updateData(["status": "ended"])
            callId = ""
            listener?.remove()
            candidateListener?.remove()
        }
    }
    
    func rejectCall(callId: String) {
        db.collection("Calls").document(callId).updateData(["status": "rejected"])
    }
    
    // MARK: - Global Listener
    
    func listenForIncomingCalls(completion: @escaping (String, String, Bool) -> Void) -> ListenerRegistration? {
        guard let currentUid = Auth.auth().currentUser?.uid else { return nil }
        
        return db.collection("Calls")
            .whereField("receiverId", isEqualTo: currentUid)
            .whereField("status", isEqualTo: "ringing")
            .addSnapshotListener { snippet, _ in
                guard let docs = snippet?.documents else { return }

                for doc in docs {
                    let data = doc.data()
                    let callId = doc.documentID
                    let callerId = data["callerId"] as? String ?? ""
                    let isVideo = (data["type"] as? String) == "video"
                    completion(callId, callerId, isVideo)
                }
            }
    }
    
    // ICE Candidates
    func send(candidate: RTCIceCandidate, isCaller: Bool) {
        let ice = IceCandidate(from: candidate)
        let dict: [String: Any] = [
            "sdp": ice.sdp,
            "sdpMLineIndex": ice.sdpMLineIndex,
            "sdpMid": ice.sdpMid ?? ""
        ]
        let collectionName = isCaller ? "callerCandidates" : "receiverCandidates"
        db.collection("Calls").document(callId).collection(collectionName).addDocument(data: dict)
    }
}
