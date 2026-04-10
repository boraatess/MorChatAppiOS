//
//  WebRTCClient.swift
//  MorChatApp
//
//  Created by bora ateş on 21.01.2026.
//


import Foundation
import WebRTC
import CoreMedia
import AVFoundation

protocol WebRTCClientDelegate: AnyObject {
    func webRTCClient(_ client: WebRTCClient, didDiscoverLocalCandidate candidate: RTCIceCandidate)
    func webRTCClient(_ client: WebRTCClient, didChangeConnectionState state: RTCIceConnectionState)
    func webRTCClient(_ client: WebRTCClient, didReceiveRemoteVideoTrack track: RTCVideoTrack)
}

final class WebRTCClient: NSObject {

    weak var delegate: WebRTCClientDelegate?
    private let factory: RTCPeerConnectionFactory
    private var peerConnection: RTCPeerConnection?

    var localVideoTrack: RTCVideoTrack?
    private var localAudioTrack: RTCAudioTrack?
    private var localVideoSource: RTCVideoSource?
    private var videoCapturer: RTCCameraVideoCapturer?

    // FIX 1: Candidate race condition için kuyruk
    private var pendingCandidates: [RTCIceCandidate] = []
    private var hasRemoteSdp = false

    private let mediaConstraints = RTCMediaConstraints(
        mandatoryConstraints: nil,
        optionalConstraints: nil
    )

    private let defaultIceServers: [RTCIceServer] = [
        RTCIceServer(urlStrings: [
            "stun:stun.l.google.com:19302",
            "stun:stun1.l.google.com:19302",
            "stun:stun2.l.google.com:19302"
        ]),
        // Hata ayıklama için geçici test TURN sunucusu (Symmetric NAT / 4G engelini aşmak için)
        RTCIceServer(urlStrings: [
            "turn:openrelay.metered.ca:80",
            "turn:openrelay.metered.ca:443",
            "turn:openrelay.metered.ca:443?transport=tcp"
        ], username: "openrelayproject", credential: "openrelayproject")
    ]

    override init() {
        RTCInitializeSSL()
        let videoEncoderFactory = RTCDefaultVideoEncoderFactory()
        let videoDecoderFactory = RTCDefaultVideoDecoderFactory()
        self.factory = RTCPeerConnectionFactory(
            encoderFactory: videoEncoderFactory,
            decoderFactory: videoDecoderFactory
        )
        super.init()
        setupLocalTracks()
    }

    func createPeerConnection() {
        let config = RTCConfiguration()
        config.sdpSemantics = .unifiedPlan
        config.continualGatheringPolicy = .gatherContinually
        config.iceServers = defaultIceServers

        let constraints = RTCMediaConstraints(
            mandatoryConstraints: nil,
            optionalConstraints: ["DtlsSrtpKeyAgreement": kRTCMediaConstraintsValueTrue]
        )

        peerConnection = factory.peerConnection(with: config, constraints: constraints, delegate: self)
        setupTransceivers()
    }

    private func setupTransceivers() {
        guard let peerConnection = peerConnection else { return }

        // Mükemmel Eşleşme (Perfect Mapping) için addTransceiver yerine add(track) kullanılır.
        // Bu sayede Karşı taraf (Answer) teklif aldığında yeni transceiver yaratmaz, olanı eşler!
        if let audioTrack = localAudioTrack {
            peerConnection.add(audioTrack, streamIds: ["stream0"])
        }

        if let videoTrack = localVideoTrack {
            peerConnection.add(videoTrack, streamIds: ["stream0"])
        } else {
            // Eğer yerel kamera yoksa, izleyici olabilmek için boş receiver ekliyoruz.
            let init_ = RTCRtpTransceiverInit()
            init_.direction = .recvOnly
            peerConnection.addTransceiver(of: .video, init: init_)
        }
    }

    private func setupLocalTracks() {
        let audioSession = RTCAudioSession.sharedInstance()
        audioSession.lockForConfiguration()
        do {
            try audioSession.setCategory(
                AVAudioSession.Category(rawValue: AVAudioSession.Category.playAndRecord.rawValue),
                with: [.allowBluetoothA2DP, .defaultToSpeaker]
            )
            try audioSession.setMode(
                AVAudioSession.Mode(rawValue: AVAudioSession.Mode.videoChat.rawValue)
            )
            try audioSession.setActive(true)
        } catch {
            print("❌ WebRTC: Audio Session Error: \(error)")
        }
        audioSession.unlockForConfiguration()

        let audioSource = factory.audioSource(with: RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: nil))
        localAudioTrack = factory.audioTrack(with: audioSource, trackId: "audio0")

        let videoSource = factory.videoSource()
        localVideoSource = videoSource

        #if !targetEnvironment(simulator)
        let devices = RTCCameraVideoCapturer.captureDevices()
        if let device = devices.first(where: { $0.position == .front }) ?? devices.first {
            // FIX 2: Max çözünürlük yerine 720p hedefle
            let formats = RTCCameraVideoCapturer.supportedFormats(for: device)
            let format = formats.first(where: {
                let d = CMVideoFormatDescriptionGetDimensions($0.formatDescription)
                return d.width == 1280 && d.height == 720
            }) ?? formats.first(where: {
                let d = CMVideoFormatDescriptionGetDimensions($0.formatDescription)
                return d.width <= 1280
            }) ?? formats.last

            if let targetFormat = format {
                videoCapturer = RTCCameraVideoCapturer(delegate: videoSource)
                let fps: Int
                let ranges = targetFormat.videoSupportedFrameRateRanges
                if ranges.contains(where: { $0.maxFrameRate >= 30 && $0.minFrameRate <= 30 }) {
                    fps = 30
                } else {
                    fps = Int(ranges.max(by: { $0.maxFrameRate < $1.maxFrameRate })?.maxFrameRate ?? 30)
                }
                videoCapturer?.startCapture(with: device, format: targetFormat, fps: fps)
                print("📹 WebRTC: Kamera başlatıldı \(fps) FPS")
            }
        }
        #endif

        let videoTrack = factory.videoTrack(with: videoSource, trackId: "video0")
        videoTrack.isEnabled = true
        localVideoTrack = videoTrack
    }

    func offer(completion: @escaping (_ sdp: RTCSessionDescription) -> Void) {
        peerConnection?.offer(for: mediaConstraints) { sdp, error in
            guard let sdp = sdp else {
                print("❌ WebRTC: Offer Error: \(error?.localizedDescription ?? "Bilinmiyor")")
                return
            }
            self.peerConnection?.setLocalDescription(sdp) { _ in
                completion(sdp)
            }
        }
    }

    func answer(completion: @escaping (_ sdp: RTCSessionDescription) -> Void) {
        peerConnection?.answer(for: mediaConstraints) { sdp, error in
            guard let sdp = sdp else {
                print("❌ WebRTC: Answer Error: \(error?.localizedDescription ?? "Bilinmiyor")")
                return
            }
            self.peerConnection?.setLocalDescription(sdp) { _ in
                completion(sdp)
            }
        }
    }

    // FIX 3: setRemoteDescription tamamlanana kadar candidate'leri kuyruğa al
    func set(remoteSdp: RTCSessionDescription, completion: @escaping (Error?) -> Void) {
        peerConnection?.setRemoteDescription(remoteSdp) { [weak self] error in
            guard let self = self else { return }
            if error == nil {
                self.hasRemoteSdp = true
                self.pendingCandidates.forEach { candidate in
                    self.peerConnection?.add(candidate) { _ in }
                }
                self.pendingCandidates.removeAll()
            }
            completion(error)
        }
    }

    func set(remoteCandidate: RTCIceCandidate, completion: @escaping (Error?) -> Void) {
        if hasRemoteSdp {
            peerConnection?.add(remoteCandidate, completionHandler: completion)
        } else {
            pendingCandidates.append(remoteCandidate)
            completion(nil)
        }
    }

    // FIX 4: endCall'da tüm state sıfırla
    func endCall() {
        videoCapturer?.stopCapture()
        peerConnection?.close()
        peerConnection = nil
        localVideoTrack = nil
        localAudioTrack = nil
        pendingCandidates.removeAll()
        hasRemoteSdp = false
    }

    func muteAudio(_ isMuted: Bool) {
        localAudioTrack?.isEnabled = !isMuted
    }

    func disableVideo(_ isDisabled: Bool) {
        localVideoTrack?.isEnabled = !isDisabled
    }

    func switchCamera() {
        guard let capturer = videoCapturer else { return }
        let devices = RTCCameraVideoCapturer.captureDevices()
        let currentPosition = (capturer.captureSession.inputs.first as? AVCaptureDeviceInput)?.device.position ?? .front
        let newPosition: AVCaptureDevice.Position = currentPosition == .front ? .back : .front

        guard let newDevice = devices.first(where: { $0.position == newPosition }) else { return }
        let formats = RTCCameraVideoCapturer.supportedFormats(for: newDevice)
        let format = formats.first(where: {
            let d = CMVideoFormatDescriptionGetDimensions($0.formatDescription)
            return d.width == 1280 && d.height == 720
        }) ?? formats.last

        if let targetFormat = format {
            capturer.stopCapture {
                capturer.startCapture(with: newDevice, format: targetFormat, fps: 30)
            }
        }
    }
}

extension WebRTCClient: RTCPeerConnectionDelegate {
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange stateChanged: RTCSignalingState) {
        print("🚥 Signaling State: \(stateChanged.rawValue)")
    }

    // FIX: Unified Plan'da sadece didAdd receiver kullan, stream metodunu boşalt
    func peerConnection(_ peerConnection: RTCPeerConnection, didAdd stream: RTCMediaStream) {}

    func peerConnection(_ peerConnection: RTCPeerConnection, didAdd receiver: RTCRtpReceiver, streams: [RTCMediaStream]) {
        print("📡 Receiver track: \(receiver.track?.kind ?? "yok")")
        if let videoTrack = receiver.track as? RTCVideoTrack {
            DispatchQueue.main.async {
                self.delegate?.webRTCClient(self, didReceiveRemoteVideoTrack: videoTrack)
            }
        }
    }

    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove stream: RTCMediaStream) {}
    func peerConnectionShouldNegotiate(_ peerConnection: RTCPeerConnection) {}

    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceConnectionState) {
        print("❄️ ICE State: \(newState.rawValue)")
        delegate?.webRTCClient(self, didChangeConnectionState: newState)
    }

    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceGatheringState) {
        print("🧊 Gathering: \(newState.rawValue)")
    }

    func peerConnection(_ peerConnection: RTCPeerConnection, didGenerate candidate: RTCIceCandidate) {
        delegate?.webRTCClient(self, didDiscoverLocalCandidate: candidate)
    }

    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove candidates: [RTCIceCandidate]) {}
    func peerConnection(_ peerConnection: RTCPeerConnection, didOpen dataChannel: RTCDataChannel) {}
}
