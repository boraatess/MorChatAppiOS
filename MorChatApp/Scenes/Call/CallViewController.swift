import UIKit
import SnapKit
import WebRTC
import AVFoundation
import AudioToolbox

final class CallViewController: UIViewController {

    private let profile: PublisherProfile
    private let isVideoCall: Bool
    private let incomingCallId: String?
    
    // MARK: - Core WebRTC Elements
    private let rtcClient = WebRTCClient()
    private let signalingClient = SignalingClient.shared
    private var systemSoundID: SystemSoundID = 0
    
    // MARK: - UI Elements
    private let backgroundImageView = UIImageView()
    private let remoteVideoView = RTCMTLVideoView()
    private let localVideoView = RTCMTLVideoView()
    private let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    
    private let topInfoContainer = UIView()
    private let nameLabel = UILabel()
    private let durationLabel = UILabel()
    
    private let connectingLabel = UILabel()
    private let pulseAnimationView = UIView()
    
    private let bottomControlsContainer = UIView()
    private let muteButton = UIButton(type: .system)
    private let switchCameraButton = UIButton(type: .system)
    private let cameraOffButton = UIButton(type: .system)
    private let endCallButton = UIButton(type: .system)
    
    // State Tracker
    private var isMuted = false
    private var isCameraOff = false
    private var timer: Timer?
    private var secondsElapsed = 0

    
    // MARK: - Init
    init(profile: PublisherProfile, isVideoCall: Bool, callId: String? = nil) {
        self.profile = profile
        self.isVideoCall = isVideoCall
        self.incomingCallId = callId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
        configureData()
        startCallAnimation()
        
        // Start camera feed instantly
        rtcClient.delegate = self
        rtcClient.createPeerConnection()
        
        // Setup Signaling
        signalingClient.delegate = self
        
        if let callId = incomingCallId {
            // RECEIVER FLOW
            print("📞 ViewController: Handling Incoming Call \(callId)")
            connectingLabel.text = "Incoming Call..."
            signalingClient.joinCall(callId: callId)
        } else {
            // CALLER FLOW
            print("📞 ViewController: Starting Outgoing Call to \(profile.name ?? "User")")
            startCallerFlow()
        }

        // Connect local video track to our small view
        if let localVideoTrack = rtcClient.localVideoTrack {
            localVideoTrack.add(localVideoView)
        }
    }
    
    private func startCallerFlow() {
        guard let receiverId = profile.id else { return }
        signalingClient.createCall(receiverId: receiverId, isVideo: isVideoCall) { [weak self] callId in
            guard let self = self else { return }
            print("📞 Call created with ID: \(callId)")
            
            // Create WebRTC Offer
            self.rtcClient.offer { sdp in
                self.signalingClient.sendOffer(sdp: sdp)
                print("📤 Offer sent!")
                self.playAudio(named: "calling") // Uses system sounds now
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    deinit {
        rtcClient.endCall()
        signalingClient.endCall()
        stopAudio()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .black
        
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.clipsToBounds = true
        view.addSubview(backgroundImageView)
        
        if isVideoCall {
            remoteVideoView.videoContentMode = .scaleAspectFill
            view.addSubview(remoteVideoView)
        } else {
            blurEffectView.frame = view.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view.addSubview(blurEffectView)
        }
        
        localVideoView.backgroundColor = .darkGray
        localVideoView.layer.cornerRadius = 16
        localVideoView.clipsToBounds = true
        localVideoView.videoContentMode = .scaleAspectFill
        if isVideoCall {
            view.addSubview(localVideoView)
        }
        
        topInfoContainer.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        topInfoContainer.layer.cornerRadius = 20
        view.addSubview(topInfoContainer)
        
        nameLabel.font = .systemFont(ofSize: 22, weight: .bold)
        nameLabel.textColor = .white
        topInfoContainer.addSubview(nameLabel)
        
        durationLabel.text = "00:00"
        durationLabel.font = .systemFont(ofSize: 16, weight: .medium)
        durationLabel.textColor = UIColor(white: 0.9, alpha: 1.0)
        topInfoContainer.addSubview(durationLabel)
        
        pulseAnimationView.backgroundColor = UIColor(red: 0.8, green: 0.1, blue: 0.8, alpha: 0.5)
        pulseAnimationView.layer.cornerRadius = 60
        view.addSubview(pulseAnimationView)
        
        connectingLabel.text = isVideoCall ? "Video Calling..." : "Voice Calling..."
        connectingLabel.textColor = .white
        connectingLabel.font = .systemFont(ofSize: 20, weight: .bold)
        view.addSubview(connectingLabel)
        
        view.addSubview(bottomControlsContainer)
        
        setupControl(button: muteButton, icon: "mic.fill", bg: .darkGray)
        setupControl(button: switchCameraButton, icon: "arrow.triangle.2.circlepath.camera", bg: .darkGray)
        setupControl(button: cameraOffButton, icon: "video.fill", bg: .darkGray)
        setupControl(button: endCallButton, icon: "phone.down.fill", bg: .systemRed)
        
        if !isVideoCall {
            switchCameraButton.isHidden = true
            cameraOffButton.isHidden = true
        }
    }
    
    private func setupControl(button: UIButton, icon: String, bg: UIColor) {
        button.setImage(UIImage(systemName: icon), for: .normal)
        button.tintColor = .white
        button.backgroundColor = bg
        button.layer.cornerRadius = 32
        bottomControlsContainer.addSubview(button)
    }

    private func setupConstraints() {
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        if isVideoCall {
            remoteVideoView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
        
        topInfoContainer.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(64)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.centerX.equalToSuperview()
        }
        
        durationLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
        }
        
        if isVideoCall {
            localVideoView.snp.makeConstraints { make in
                make.top.equalTo(topInfoContainer.snp.bottom).offset(16)
                make.trailing.equalToSuperview().inset(16)
                make.width.equalTo(100)
                make.height.equalTo(150)
            }
        }
        
        pulseAnimationView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(120)
        }
        
        connectingLabel.snp.makeConstraints { make in
            make.top.equalTo(pulseAnimationView.snp.bottom).offset(24)
            make.centerX.equalToSuperview()
        }
        
        bottomControlsContainer.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(24)
            make.leading.trailing.equalToSuperview().inset(32)
            make.height.equalTo(64)
        }
        
        endCallButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
            make.size.equalTo(64)
        }
        
        if isVideoCall {
            muteButton.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.trailing.equalTo(endCallButton.snp.leading).offset(-32)
                make.size.equalTo(64)
            }
            
            cameraOffButton.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.leading.equalTo(endCallButton.snp.trailing).offset(32)
                make.size.equalTo(64)
            }
            
            switchCameraButton.snp.makeConstraints { make in
                make.bottom.equalTo(cameraOffButton.snp.top).offset(-16)
                make.centerX.equalTo(cameraOffButton)
                make.size.equalTo(48)
            }
            switchCameraButton.layer.cornerRadius = 24
        } else {
            muteButton.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.trailing.equalTo(endCallButton.snp.leading).offset(-40)
                make.size.equalTo(64)
            }
        }
    }
    
    private func configureData() {
        nameLabel.text = profile.name ?? "Unknown"
    }
    
    private func setupActions() {
        endCallButton.addTarget(self, action: #selector(endTapped), for: .touchUpInside)
        muteButton.addTarget(self, action: #selector(muteTapped), for: .touchUpInside)
        cameraOffButton.addTarget(self, action: #selector(cameraOffTapped), for: .touchUpInside)
        switchCameraButton.addTarget(self, action: #selector(switchCameraTapped), for: .touchUpInside)
    }

    private func startCallAnimation() {
        UIView.animate(withDuration: 1.0, delay: 0, options: [.autoreverse, .repeat, .curveEaseInOut]) {
            self.pulseAnimationView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            self.pulseAnimationView.alpha = 0.5
        } completion: { _ in }
    }
    
    private func stopCallAnimationAndConnect() {
        guard pulseAnimationView.isHidden == false else { return }
        pulseAnimationView.layer.removeAllAnimations()
        pulseAnimationView.isHidden = true
        connectingLabel.isHidden = true
        stopAudio()
        startTimer()
    }
    
    private func playAudio(named: String) {
        print("🔊 Playing system sound...")
        // 1001 is a more common 'Ringtone' tone
        let soundID: SystemSoundID = 1001
        self.systemSoundID = soundID
        
        // Loop the sound
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] timer in
            guard let self = self, self.systemSoundID != 0 else {
                timer.invalidate()
                return
            }
            print("🔊 Triggering sound \(self.systemSoundID)")
            AudioServicesPlayAlertSound(self.systemSoundID) // Alert sound is more reliable than SystemSound
        }
    }

    
    private func stopAudio() {
        self.systemSoundID = 0
    }
    
    private func startTimer() {
        timer?.invalidate()
        secondsElapsed = 0
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateTimerLabel()
        }
    }
    
    private func updateTimerLabel() {
        secondsElapsed += 1
        let minutes = secondsElapsed / 60
        let seconds = secondsElapsed % 60
        durationLabel.text = String(format: "%02d:%02d", minutes, seconds)
    }

    @objc private func endTapped() {
        signalingClient.endCall()
        rtcClient.endCall()
        stopAudio()
        dismiss(animated: true)
    }
    
    @objc private func muteTapped() {
        isMuted.toggle()
        muteButton.backgroundColor = isMuted ? .white : .darkGray
        muteButton.tintColor = isMuted ? .black : .white
        let icon = isMuted ? "mic.slash.fill" : "mic.fill"
        muteButton.setImage(UIImage(systemName: icon), for: .normal)
    }
    
    @objc private func cameraOffTapped() {
        isCameraOff.toggle()
        cameraOffButton.backgroundColor = isCameraOff ? .white : .darkGray
        cameraOffButton.tintColor = isCameraOff ? .black : .white
        let icon = isCameraOff ? "video.slash.fill" : "video.fill"
        cameraOffButton.setImage(UIImage(systemName: icon), for: .normal)
        localVideoView.isHidden = isCameraOff
    }
    
    @objc private func switchCameraTapped() {
        rtcClient.switchCamera()
        UIView.animate(withDuration: 0.2, animations: {
            self.switchCameraButton.transform = self.switchCameraButton.transform.rotated(by: .pi)
        })
    }
}

extension CallViewController: WebRTCClientDelegate {
    func webRTCClient(_ client: WebRTCClient, didDiscoverLocalCandidate candidate: RTCIceCandidate) {
        signalingClient.send(candidate: candidate, isCaller: incomingCallId == nil)
    }
    
    func webRTCClient(_ client: WebRTCClient, didChangeConnectionState state: RTCIceConnectionState) {
        DispatchQueue.main.async {
            switch state {
            case .connected, .completed:
                self.stopCallAnimationAndConnect()
            case .failed, .disconnected:
                self.endTapped()
            default:
                break
            }
        }
    }
    
    func webRTCClient(_ client: WebRTCClient, didReceiveRemoteVideoTrack track: RTCVideoTrack) {
        DispatchQueue.main.async {
            track.add(self.remoteVideoView)
            self.stopCallAnimationAndConnect()
        }
    }
}

extension CallViewController: SignalingClientDelegate {
    func signalingClient(_ client: SignalingClient, didReceiveRemoteSdp sdp: RTCSessionDescription) {
        rtcClient.set(remoteSdp: sdp) { [weak self] error in
            if let error = error {
                print("❌ Error setting remote SDP: \(error)")
                return
            }
            
            if sdp.type == .offer {
                self?.rtcClient.answer { answerSdp in
                    self?.signalingClient.sendAnswer(sdp: answerSdp)
                }
            }
        }
    }
    
    func signalingClient(_ client: SignalingClient, didReceiveCandidate candidate: RTCIceCandidate) {
        rtcClient.set(remoteCandidate: candidate) { error in
            if let error = error {
                print("❌ Error setting remote candidate: \(error)")
            }
        }
    }
    
    func signalingClient(_ client: SignalingClient, didChangeStatus status: String) {
        DispatchQueue.main.async {
            print("📞 Signaling Status Changed: \(status)")
            if status == "accepted" {
                self.stopCallAnimationAndConnect()
            } else if status == "rejected" || status == "ended" {
                self.endTapped()
            }
        }
    }
}
