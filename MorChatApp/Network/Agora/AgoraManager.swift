
import AgoraRtcKit
import UIKit

protocol AgoraManagerDelegate: AnyObject {
    func agoraManager(_ manager: AgoraManager, didJoinedRemoteUser uid: UInt, withView view: UIView)
    func agoraManager(_ manager: AgoraManager, didOfflineOfUid uid: UInt)
    func agoraManager(_ manager: AgoraManager, didJoinedChannel channel: String)
}

class AgoraManager: NSObject {
    static let shared = AgoraManager()
    
    // ⚠️ DİKKAT: Buraya Agora Konsolu'ndan aldığınız App ID'yi yapıştırın!
    private var appId: String = "cea6f9fff71043659e499bf8b909f7e2"
    
    // Agora Konsolu'ndan aldığınız Geçici Token (Şifre)
    private let tempToken = "007eJxTYOA9a/K+Xch5Y3Cl0m3ZQG+bybOPPOhkdGh83Zz68cp8Z1EFhuTURLM0y7S0NHNDAxNjM1PLVBNLy6Q0iyRLA8s081Qj5/r/mQ2BjAwqWxWYGRkgEMRnZUhOzMkpZmAAADnSHy0="
    
    
    // 007eJxTYOA9a/K+Xch5Y3Cl0m3ZQG+bybOPPOhkdGh83Zz68cp8Z1EFhuTURLM0y7S0NHNDAxNjM1PLVBNLy6Q0iyRLA8s081Qj5/r/mQ2BjAwqWxWYGRkgEMRnZUhOzMkpZmAAADnSHy0=
    
    
    var agoraKit: AgoraRtcEngineKit?
    weak var delegate: AgoraManagerDelegate?
    
    private override init() {
        super.init()
    }
    
    func initializeAgora(appId: String? = nil) {
        if let id = appId { self.appId = id }
        
        print("🛠️ Agora: Başlatılıyor AppID: \(self.appId)")
        
        let config = AgoraRtcEngineConfig()
        config.appId = self.appId
        config.areaCode = .global
        
        agoraKit = AgoraRtcEngineKit.sharedEngine(with: config, delegate: self)
        
        // Önemli: Ses ve Video motorunu aç
        agoraKit?.enableAudio()
        agoraKit?.enableVideo()
        
        agoraKit?.setVideoEncoderConfiguration(AgoraVideoEncoderConfiguration(size: AgoraVideoDimension640x360, frameRate: AgoraVideoFrameRate.fps15.rawValue, bitrate: AgoraVideoBitrateStandard, orientationMode: .adaptative, mirrorMode: .auto))
        
        agoraKit?.startPreview()
    }
    
    func setupLocalVideo(view: UIView) {
        print("📹 Agora: Yerel video setup ediliyor. View Frame: \(view.frame)")
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = 0 
        videoCanvas.view = view
        videoCanvas.renderMode = .hidden
        let result = agoraKit?.setupLocalVideo(videoCanvas)
        print("📹 Agora: Local Video Setup Sonucu: \(result ?? -1)")
    }
    
    func joinChannel(channelId: String) {
        print("🔑 Kullanılan Token (ilk 10 hane): \(tempToken.prefix(10))...")
        print("📺 Katılınan Kanal: \(channelId)")
        
        // Kanala girmeden önce önizlemeyi tekrar tetikle
        agoraKit?.startPreview()

        // 🛡️ KRİTİK AYAR: Rolümüzü "Broadcaster" (Yayıncı) yapıyoruz. 
        // Aksi takdirde karşı taraf bizi odada göremez.
        let options = AgoraRtcChannelMediaOptions()
        options.publishCameraTrack = true
        options.publishMicrophoneTrack = true
        options.clientRoleType = .broadcaster // <--- BEN YAYINCIYIM!

        let result = agoraKit?.joinChannel(byToken: tempToken, channelId: channelId, uid: 0, mediaOptions: options) { [weak self] (channel, uid, elapsed) in
            print("✅✅✅ AGORA BAĞLANDI! Kanal: \(channel), UID: \(uid)")
            self?.delegate?.agoraManager(self!, didJoinedChannel: channel)
        }
        
        if result != 0 {
            print("❌ Agora: joinChannel anlık hatası: \(result ?? -1)")
        }
    }
    
    func leaveChannel() {
        print("🚪 Agora: Kanaldan ayrılıyor.")
        agoraKit?.leaveChannel(nil)
        agoraKit = nil
    }
    
    func switchCamera() {
        agoraKit?.switchCamera()
    }
    
    func muteAudio(_ isMuted: Bool) {
        agoraKit?.muteLocalAudioStream(isMuted)
    }
    
    func disableVideo(_ isDisabled: Bool) {
        agoraKit?.muteLocalVideoStream(isDisabled)
    }
    
}

extension AgoraManager: AgoraRtcEngineDelegate {
    
    // ⚠️ HATA YAKALAYICI: Eğer bir sorun varsa burada görünecek
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOccurError errorCode: AgoraErrorCode) {
        print("❌❌❌ AGORA HATASI: \(errorCode.rawValue)")
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOccurWarning warningCode: AgoraWarningCode) {
        print("⚠️ AGORA UYARISI: \(warningCode.rawValue)")
    }

    func rtcEngine(_ engine: AgoraRtcEngineKit, connectionChangedTo state: AgoraConnectionState, reason: AgoraConnectionChangedReason) {
        print("🔌 Agora Bağlantı Durumu Değişti: \(state.rawValue), Sebep: \(reason.rawValue)")
    }

    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed: Int) {
        print("👤 Agora: Karşı kullanıcı bağlandı: \(uid)")
        delegate?.agoraManager(self, didJoinedRemoteUser: uid, withView: UIView())
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOfflineOfUid uid: UInt, reason: AgoraUserOfflineReason) {
        print("📴 Agora: Karşı kullanıcı ayrıldı.")
        delegate?.agoraManager(self, didOfflineOfUid: uid)
    }
}
