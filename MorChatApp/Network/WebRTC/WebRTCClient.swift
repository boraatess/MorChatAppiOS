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
        
        let constraints = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: ["DtlsSrtpKeyAgreement": kRTCMediaConstraintsValueTrue])
        
        peerConnection = factory.peerConnection(with: config, constraints: constraints, delegate: self)
        
        if let audioTrack = self.localAudioTrack {
            peerConnection?.add(audioTrack, streamIds: ["stream0"])
        }
        if let videoTrack = self.localVideoTrack {
            peerConnection?.add(videoTrack, streamIds: ["stream0"])
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
        self.localAudioTrack = audioTrack
        
        // Video Track ekleme (Ön Kamera)
        let videoSource = factory.videoSource()
        #if targetEnvironment(simulator)
        // Simulator kamera desteklemez
        print("Kamera simülatörde çalışmaz.")
        #else
        let cameraDevice = RTCCameraVideoCapturer.captureDevices().first { $0.position == .front }
        if let device = cameraDevice,
           let format = RTCCameraVideoCapturer.supportedFormats(for: device).max(by: {
               CMVideoFormatDescriptionGetDimensions($0.formatDescription).width < CMVideoFormatDescriptionGetDimensions($1.formatDescription).width
           }),
           let fps = format.videoSupportedFrameRateRanges.max(by: { return $0.maxFrameRate < $1.maxFrameRate }) {
            
            self.videoCapturer = RTCCameraVideoCapturer(delegate: videoSource)
            self.videoCapturer?.startCapture(with: device, format: format, fps: Int(fps.maxFrameRate))
        }
        #endif
        
        let videoTrack = factory.videoTrack(with: videoSource, trackId: "video0")
        self.localVideoTrack = videoTrack    
    }
    
    func offer(completion: @escaping (_ sdp: RTCSessionDescription) -> Void) {
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
        
        guard let currentDevice = (capturer.captureSession.inputs.first as? AVCaptureDeviceInput)?.device else { return }
        let newPosition: AVCaptureDevice.Position = currentDevice.position == .front ? .back : .front
        
        guard let newDevice = devices.first(where: { $0.position == newPosition }) else { return }
        
        let formats = RTCCameraVideoCapturer.supportedFormats(for: newDevice)
        guard let format = formats.max(by: {
            CMVideoFormatDescriptionGetDimensions($0.formatDescription).width < CMVideoFormatDescriptionGetDimensions($1.formatDescription).width
        }) else { return }
        
        let fps = format.videoSupportedFrameRateRanges.max(by: { return $0.maxFrameRate < $1.maxFrameRate })?.maxFrameRate ?? 30
        
        capturer.stopCapture {
            capturer.startCapture(with: newDevice, format: format, fps: Int(fps))
        }
    }
}


extension WebRTCClient: RTCPeerConnectionDelegate {
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange stateChanged: RTCSignalingState) {}
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didAdd stream: RTCMediaStream) {
        if let videoTrack = stream.videoTracks.first {
            print("Uzak baglanti kuruldu, video geldi!")
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
