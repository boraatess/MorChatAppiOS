import UIKit
import FirebaseFirestore
import FirebaseAuth

final class CallManager {
    static let shared = CallManager()
    
    private let signalingClient = SignalingClient.shared
    private var incomingCallListener: ListenerRegistration?
    private var authListener: AuthStateDidChangeListenerHandle?
    
    private init() {}
    
    func start() {
        print("📞 CallManager: Starting...")
        
        // Listen for Auth changes
        authListener = Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            if let user = user {
                print("✅ CallManager: User logged in (\(user.uid)), starting call listener.")
                self?.listen()
            } else {
                print("⚠️ CallManager: User logged out, stopping call listener.")
                self?.stop()
            }
        }
    }
    
    private func listen() {
        stop() // Clear existing listener
        incomingCallListener = signalingClient.listenForIncomingCalls { [weak self] callId, callerId, isVideo in
            print("📞 CallManager: Incoming call detected! ID: \(callId)")
            self?.handleIncomingCall(callId: callId, callerId: callerId, isVideo: isVideo)
        }
    }

    
    func stop() {
        incomingCallListener?.remove()
        incomingCallListener = nil
    }
    
    private func handleIncomingCall(callId: String, callerId: String, isVideo: Bool) {
        // Avoid showing duplicate call screens if one is already active
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController else { return }
        
        if let presented = rootVC.presentedViewController, presented is CallViewController {
            return
        }
        
        // Fetch caller profile info first
        FirestoreService.shared.fetchPublisherProfile(publisherId: callerId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let profile):
                    self?.showIncomingCallUI(callId: callId, profile: profile, isVideo: isVideo)
                case .failure:
                    // If we can't find profile, still show something with defaults
                    let defaultProfile = PublisherProfile(id: callerId, about: nil, age: nil, email: nil, language: nil, last_seen: nil, msgToken: nil, name: "Unknown Caller", phoneNumber: nil, point: nil, profilePic: nil, status: nil, tagList: nil)
                    self?.showIncomingCallUI(callId: callId, profile: defaultProfile, isVideo: isVideo)
                }
            }
        }
    }
    
    private func showIncomingCallUI(callId: String, profile: PublisherProfile, isVideo: Bool) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController else { return }
        
        let title = isVideo ? "Incoming Video Call" : "Incoming Voice Call"
        let message = "\(profile.name ?? "Someone") is calling you."
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Decline", style: .destructive, handler: { _ in
            SignalingClient.shared.rejectCall(callId: callId)
        }))
        
        alert.addAction(UIAlertAction(title: "Accept", style: .default, handler: { [weak rootVC] _ in
            let callVC = CallViewController(profile: profile, isVideoCall: isVideo, callId: callId)
            callVC.modalPresentationStyle = .fullScreen
            rootVC?.present(callVC, animated: true)
        }))
        
        rootVC.present(alert, animated: true)
    }
}
