
import UIKit
import FirebaseFirestore
import FirebaseAuth
import CallKit
import AVFoundation
import PushKit

final class CallManager: NSObject {
    static let shared = CallManager()
    
    private let signalingClient = SignalingClient.shared
    private var incomingCallListener: ListenerRegistration?
    private var authListener: AuthStateDidChangeListenerHandle?
    
    // CallKit Bileşenleri
    private let callController = CXCallController()
    private let provider: CXProvider
    private var activeCallId: UUID?
    private var currentCallData: (callId: String, profile: PublisherProfile, isVideo: Bool)?
    
    // PushKit (VoIP) Bileşenleri
    private var voipRegistry: PKPushRegistry?
    
    private override init() {
        let configuration = CXProviderConfiguration(localizedName: "Mor Chat")
        configuration.supportsVideo = true
        configuration.maximumCallGroups = 1
        configuration.supportedHandleTypes = [.generic]
        
        provider = CXProvider(configuration: configuration)
        super.init()
        provider.setDelegate(self, queue: nil)
        
        // PushKit Kurulumu
        setupVoIP()
    }
    
    private func setupVoIP() {
        voipRegistry = PKPushRegistry(queue: nil)
        voipRegistry?.delegate = self
        voipRegistry?.desiredPushTypes = [.voIP]
    }
    
    func start() {
        print("📞 CallManager: Starting...")
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
        stop()
        incomingCallListener = signalingClient.listenForIncomingCalls { [weak self] callId, callerId, isVideo in
            print("📞 CallManager: Incoming call detected via Firestore! ID: \(callId)")
            self?.handleIncomingCall(callId: callId, callerId: callerId, isVideo: isVideo)
        }
    }
    
    func stop() {
        incomingCallListener?.remove()
        incomingCallListener = nil
    }
    
    private func handleIncomingCall(callId: String, callerId: String, isVideo: Bool) {
        // Eğer zaten bir arama aktifse veya sistem ekranı açıksa yeni gösterme
        guard activeCallId == nil else { return }
        
        FirestoreService.shared.fetchPublisherProfile(publisherId: callerId) { [weak self] result in
            DispatchQueue.main.async {
                let profile = (try? result.get()) ?? PublisherProfile.empty
                self?.reportIncomingCallToSystem(callId: callId, profile: profile, isVideo: isVideo)
            }
        }
    }
    
    private func reportIncomingCallToSystem(callId: String, profile: PublisherProfile, isVideo: Bool) {
        let uuid = UUID()
        self.activeCallId = uuid
        self.currentCallData = (callId, profile, isVideo)
        
        let update = CXCallUpdate()
        update.remoteHandle = CXHandle(type: .generic, value: profile.name ?? "Bilinmeyen")
        update.hasVideo = isVideo
        
        provider.reportNewIncomingCall(with: uuid, update: update) { [weak self] error in
            if let error = error {
                print("❌ CallKit Error: \(error.localizedDescription)")
                self?.activeCallId = nil
            }
        }
    }
    
    func endCall() {
        guard let uuid = activeCallId else { return }
        let endAction = CXEndCallAction(call: uuid)
        let transaction = CXTransaction(action: endAction)
        callController.request(transaction) { error in
            if let error = error { print("❌ End Call Error: \(error)") }
        }
    }
}

// MARK: - CXProviderDelegate
extension CallManager: CXProviderDelegate {
    func providerDidReset(_ provider: CXProvider) {
        activeCallId = nil
    }
    
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        guard let data = currentCallData else {
            action.fail()
            return
        }
        
        DispatchQueue.main.async {
            self.showCallViewController(profile: data.profile, isVideo: data.isVideo, callId: data.callId)
            action.fulfill()
        }
    }
    
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        if let data = currentCallData {
            SignalingClient.shared.rejectCall(callId: data.callId)
        }
        activeCallId = nil
        currentCallData = nil
        action.fulfill()
    }
    
    private func showCallViewController(profile: PublisherProfile, isVideo: Bool, callId: String) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController else { return }
        
        let callVC = CallViewController(profile: profile, isVideoCall: isVideo, callId: callId)
        callVC.modalPresentationStyle = .fullScreen
        
        var topVC = rootVC
        while let presented = topVC.presentedViewController {
            topVC = presented
        }
        topVC.present(callVC, animated: true)
    }
}

// MARK: - PKPushRegistryDelegate (PushKit)
extension CallManager: PKPushRegistryDelegate {
    
    // VoIP Token alındığında veya güncellendiğinde (iOS 13+)
    func pushRegistry(_ registry: PKPushRegistry, didUpdate credentials: PKPushCredentials, for type: PKPushType) {
        if type == .voIP {
            
            let pToken = credentials.token.map { String(format: "%02.2hhx", $0)
            }.joined()
            
           /* let token = credentials.pushToken.map { String(format: "%02.2hhx", $0) }.joined()*/
            
            print("🚀 VoIP Token Received: \(pToken)")
            
            FirestoreService.shared.updateVoIPToken(token: pToken)
            
        }
    }
    
    // Uygulama kapalıyken veya arkadayken VoIP bildirimi geldiğinde
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        
        let data = payload.dictionaryPayload
        
        if let callId = data["callId"] as? String,
           let callerId = data["callerId"] as? String {
            
            let isVideo = (data["video"] as? Bool) ?? true
            
            // Arka planda sistemi uyandırıp CallKit ekranını gösteriyoruz
            handleIncomingCall(callId: callId, callerId: callerId, isVideo: isVideo)
        }
        
        // İşlem bittiğinde Apple'a bildiriyoruz
        completion()
    }
}
