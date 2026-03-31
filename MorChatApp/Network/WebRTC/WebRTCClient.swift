import Foundation
import WebRTC

protocol WebRTCClientDelegate: AnyObject {
    func webRTCClient(_ client: WebRTCClient, didDiscoverLocalCandidate candidate: RTCIceCandidate)
    func webRTCClient(_ client: WebRTCClient, didChangeConnectionState state: RTCIceConnectionState)
    func webRTCClient(_ client: WebRTCClient, didReceiveRemoteVideoTrack track: RTCVideoTrack)
}

final class WebRTCClient: NSObject {
    
    weak var delegate: WebRTCClientDelegate?
    private let factory: RTCPeerConnectionFactory
    private var peerConnection: RTCPeerConnection?
    
    // Tracks
    var localVideoTrack: RTCVideoTrack?
    private var localAudioTrack: RTCAudioTrack?
    private var localVideoSource: RTCVideoSource?
    private var localAudioSource: RTCAudioSource?
    private var videoCapturer: RTCCameraVideoCapturer?
    
    // Constraints
    private let mediaConstraints = RTCMediaConstraints(
        mandatoryConstraints: [
            kRTCMediaConstraintsOfferToReceiveAudio: kRTCMediaConstraintsValueTrue,
            kRTCMediaConstraintsOfferToReceiveVideo: kRTCMediaConstraintsValueTrue
        ],
        optionalConstraints: nil
    )
    
    private let rtcAudioSession = RTCAudioSession.sharedInstance()
    
    // Google'nin bedava STUN sunucuları (P2P bağlantı sağlar ama Tunnelsuzdur)
    private let defaultIceServers = ["stun:stun.l.google.com:19302",
                                     "stun:stun1.l.google.com:19302"]
    
    override init() {
        RTCInitializeSSL()
        let videoEncoderFactory = RTCDefaultVideoEncoderFactory()
        let videoDecoderFactory = RTCDefaultVideoDecoderFactory()
        
        self.factory = RTCPeerConnectionFactory(encoderFactory: videoEncoderFactory, decoderFactory: videoDecoderFactory)
        
        super.init()
        self.setupLocalTracks()
    }
    
    func createPeerConnection() {
        let config = RTCConfiguration()
        config.sdpSemantics = .unifiedPlan
        config.continualGatheringPolicy = .gatherContinually
        // STUN server ayarı - Gerçek sunucu IP'mizi bulmamızı sağlar
        config.iceServers = [RTCIceServer(urlStrings: defaultIceServers)]
        
        // Bazı sürümlerde constraints nil kabul etmez, boş bir nesne verelim
        let constraints = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: nil)
        peerConnection = factory.peerConnection(with: config, constraints: constraints, delegate: self)
        
        // Audio Track ekleme
        if let audioTrack = self.localAudioTrack {
            peerConnection?.add(audioTrack, streamIds: ["stream0"])
        }
        
        // Video Track için Transceiver kullanımı (Unified Plan için önerilen)
        if let videoTrack = self.localVideoTrack {
            let transceiverInit = RTCRtpTransceiverInit()
            transceiverInit.streamIds = ["stream0"]
            // Güçlendirilmiş: Hem gönderelim hem alalım (.sendRecv kullanılır)
            transceiverInit.direction = .sendRecv
            peerConnection?.addTransceiver(with: videoTrack, init: transceiverInit)
        }
    }
    
    private func setupLocalTracks() {
        // Ses ayarlamaları
        rtcAudioSession.lockForConfiguration()
        do {
            try rtcAudioSession.setCategory(AVAudioSession.Category(rawValue: AVAudioSession.Category.playAndRecord.rawValue) ?? .playAndRecord)
            try rtcAudioSession.setMode(AVAudioSession.Mode(rawValue: AVAudioSession.Mode.voiceChat.rawValue) ?? .default)
        } catch let error {
            print("Error parsing audio session: \(error)")
        }
        rtcAudioSession.unlockForConfiguration()
        
        // Ses Track ekleme
        let audioConstrains = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: nil)
        let audioSource = factory.audioSource(with: audioConstrains)
        let audioTrack = factory.audioTrack(with: audioSource, trackId: "audio0")
        self.localAudioSource = audioSource
        self.localAudioTrack = audioTrack
        
        // Video Track ekleme (Ön Kamera)
        let videoSource = factory.videoSource()
        self.localVideoSource = videoSource
        
        #if targetEnvironment(simulator)
        // Simulator kamera desteklemez
        print("Kamera simülatörde çalışmaz.")
        #else
        let cameraDevice = RTCCameraVideoCapturer.captureDevices().first { $0.position == .front } ?? RTCCameraVideoCapturer.captureDevices().first
        if let device = cameraDevice,
           let format = RTCCameraVideoCapturer.supportedFormats(for: device).max(by: {
               let d1 = CMVideoFormatDescriptionGetDimensions($0.formatDescription)
               let d2 = CMVideoFormatDescriptionGetDimensions($1.formatDescription)
               return (d1.width * d1.height) < (d2.width * d2.height)
           }) {
            
            self.videoCapturer = RTCCameraVideoCapturer(delegate: videoSource)
            
            // FPS listesinden 30'a en yakın olanı veya 30'dan küçük en büyük olanı seçelim
            let fpsRanges = format.videoSupportedFrameRateRanges
            let targetFps = 30.0
            let fps = fpsRanges.contains(where: { $0.maxFrameRate >= targetFps }) ? targetFps : (fpsRanges.max(by: { $0.maxFrameRate < $1.maxFrameRate })?.maxFrameRate ?? targetFps)
            
            self.videoCapturer?.startCapture(with: device, format: format, fps: Int(fps))
        }
        #endif
        
        let videoTrack = factory.videoTrack(with: videoSource, trackId: "video0")
        self.localVideoTrack = videoTrack    
    }
    
    func offer(completion: @escaping (_ sdp: RTCSessionDescription) -> Void) {
        // 'nil' kabul etmiyorsa boş veya tanımlı constraints kullanılır
        peerConnection?.offer(for: mediaConstraints) { (sdp, _) in
            guard let sdp = sdp else { return }
            self.peerConnection?.setLocalDescription(sdp, completionHandler: { (_) in
                completion(sdp)
            })
        }
    }

    
    func answer(completion: @escaping (_ sdp: RTCSessionDescription) -> Void) {
        peerConnection?.answer(for: mediaConstraints) { (sdp, _) in
            guard let sdp = sdp else { return }
            self.peerConnection?.setLocalDescription(sdp, completionHandler: { (_) in
                completion(sdp)
            })
        }
    }

    
    func set(remoteSdp: RTCSessionDescription, completion: @escaping (Error?) -> ()) {
        peerConnection?.setRemoteDescription(remoteSdp, completionHandler: completion)
    }
    
    func set(remoteCandidate: RTCIceCandidate, completion: @escaping (Error?) -> ()) {
        peerConnection?.add(remoteCandidate, completionHandler: completion)
    }
    
    func endCall() {
        self.peerConnection?.close()
        self.peerConnection = nil
    }
    
    func switchCamera() {
        guard let capturer = self.videoCapturer else { return }
        let devices = RTCCameraVideoCapturer.captureDevices()
        
        // Mevcut pozisyonu bulamıyorsa front kabul et
        let currentPosition = (capturer.captureSession.inputs.first as? AVCaptureDeviceInput)?.device.position ?? .front
        let newPosition: AVCaptureDevice.Position = currentPosition == .front ? .back : .front
        
        guard let newDevice = devices.first(where: { $0.position == newPosition }) else { return }
        
        let formats = RTCCameraVideoCapturer.supportedFormats(for: newDevice)
        guard let format = formats.max(by: {
            let d1 = CMVideoFormatDescriptionGetDimensions($0.formatDescription)
            let d2 = CMVideoFormatDescriptionGetDimensions($1.formatDescription)
            return (d1.width * d1.height) < (d2.width * d2.height)
        }) else { return }
        
        let fpsRanges = format.videoSupportedFrameRateRanges
        let fps = fpsRanges.contains(where: { $0.maxFrameRate >= 30 }) ? 30 : (fpsRanges.max(by: { $0.maxFrameRate < $1.maxFrameRate })?.maxFrameRate ?? 30)
        
        capturer.stopCapture {
            capturer.startCapture(with: newDevice, format: format, fps: Int(fps))
        }
    }
}


extension WebRTCClient: RTCPeerConnectionDelegate {
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange stateChanged: RTCSignalingState) {}
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didAdd stream: RTCMediaStream) {
        if let videoTrack = stream.videoTracks.first {
            print("Remote video stream received!")
            self.delegate?.webRTCClient(self, didReceiveRemoteVideoTrack: videoTrack)
        }
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didAdd receiver: RTCRtpReceiver, streams: [RTCMediaStream]) {
        if let videoTrack = receiver.track as? RTCVideoTrack {
            print("Remote video track received via receiver!")
            self.delegate?.webRTCClient(self, didReceiveRemoteVideoTrack: videoTrack)
        }
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove stream: RTCMediaStream) {}
    func peerConnectionShouldNegotiate(_ peerConnection: RTCPeerConnection) {}
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceConnectionState) {
        self.delegate?.webRTCClient(self, didChangeConnectionState: newState)
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceGatheringState) {}
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didGenerate candidate: RTCIceCandidate) {
        self.delegate?.webRTCClient(self, didDiscoverLocalCandidate: candidate)
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove candidates: [RTCIceCandidate]) {}
    func peerConnection(_ peerConnection: RTCPeerConnection, didOpen dataChannel: RTCDataChannel) {}
}
