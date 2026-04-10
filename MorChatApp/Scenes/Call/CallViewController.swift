import UIKit
import SnapKit
import AgoraRtcKit
import AVFoundation
import AudioToolbox
import AgoraInfra_iOS


final class CallViewController: BaseVC {

    private let profile: PublisherProfile
    private let isVideoCall: Bool
    private let incomingCallId: String?

    // MARK: - Core Agora & Signaling
    private let agoraManager = AgoraManager.shared
    private let signalingClient = SignalingClient.shared
    private var systemSoundID: SystemSoundID = 0

    // MARK: - UI
    private let backgroundImageView = UIImageView()
    private let remoteVideoView = UIView() // Agora için standart UIView yeterlidir
    private let localVideoView = UIView()  // Agora için standart UIView yeterlidir
    private let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))

    private let topInfoContainer = UIView()
    private let nameLabel = UILabel()
    private let durationLabel = UILabel()
    fileprivate let connectingLabel = UILabel()
    private let pulseAnimationView = UIView()
    private let bottomControlsContainer = UIView()
    private let muteButton = UIButton(type: .system)
    private let switchCameraButton = UIButton(type: .system)
    private let cameraOffButton = UIButton(type: .system)
    private let endCallButton = UIButton(type: .system)

    // MARK: - State
    private var isMuted = false
    private var isCameraOff = false
    private var timer: Timer?
    private var secondsElapsed = 0
    private var callDidConnect = false
    private var remoteTrackAdded = false
    
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
        headerView.isHidden = true

        setupUI()
        setupConstraints()
        setupActions()
        configureData()
        startCallAnimation()
        showLoading()

        // 1. Agora Hazırlığı
        agoraManager.delegate = self
        agoraManager.initializeAgora()
        
        // 2. Sinyalleşme Hazırlığı
        signalingClient.delegate = self

        if let callId = incomingCallId {
            print("📞 Agora: Gelen arama kanalına katılıyor: \(callId)")
            connectingLabel.text = "Bağlanıyor..."
            signalingClient.joinCall(callId: callId)
            // 🔥 BURASI KRİTİK: Durumu "accepted" yap ki arayan taraf bağlandığını anlasın
            signalingClient.acceptCall(callId: callId) 
            
            agoraManager.joinChannel(channelId: callId)
        } else {
            print("📞 Agora: Giden arama başlatılıyor...")
            startCallerFlow()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Ekran yerleşimi bittiğinde görüntüyü bağla (frame 0 olmamalı)
        if isVideoCall && localVideoView.frame.width > 0 {
            agoraKitSetupLocalVideo()
        }
    }
    
    private func agoraKitSetupLocalVideo() {
        agoraManager.setupLocalVideo(view: localVideoView)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isBeingDismissed {
            agoraManager.leaveChannel()
            signalingClient.endCall()
            stopAudio()
            timer?.invalidate()
        }
    }

    // MARK: - Call Flow
    private func startCallerFlow() {
        guard let receiverId = profile.id else { return }
        signalingClient.createCall(receiverId: receiverId, isVideo: isVideoCall) { [weak self] callId in
            guard let self = self else { return }
            print("✅ Firestore: Arama oluşturuldu ID: \(callId)")
            
            // 🔥 KRİTİK: Agora kanalına bu ID ile katılıyoruz
            self.agoraManager.joinChannel(channelId: callId)
            
            DispatchQueue.main.async {
                self.playAudio(named: "calling")
            }
        }
    }

    // MARK: - Setup UI (Agora için sadeleşti)
    private func setupUI() {
        view.backgroundColor = .black

        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.clipsToBounds = true
        view.addSubview(backgroundImageView)

        remoteVideoView.backgroundColor = .black
        remoteVideoView.layer.borderColor = UIColor.green.cgColor // DEBUG
        remoteVideoView.layer.borderWidth = 2
        view.addSubview(remoteVideoView)

        if !isVideoCall {
            blurEffectView.frame = view.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view.addSubview(blurEffectView)
        }

        if isVideoCall {
            localVideoView.backgroundColor = .darkGray
            localVideoView.layer.borderColor = UIColor.red.cgColor // DEBUG
            localVideoView.layer.borderWidth = 2
            localVideoView.layer.cornerRadius = 16
            localVideoView.clipsToBounds = true
            view.addSubview(localVideoView)
            view.bringSubviewToFront(localVideoView) // En öne getir
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

        connectingLabel.text = isVideoCall ? "Görüntülü Arıyor..." : "Sesli Arıyor..."
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
        backgroundImageView.snp.makeConstraints { $0.edges.equalToSuperview() }
        remoteVideoView.snp.makeConstraints { $0.edges.equalToSuperview() }

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
            make.centerY.equalToSuperview()
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
        nameLabel.text = profile.name ?? "Bilinmiyor"
    }

    private func setupActions() {
        endCallButton.addTarget(self, action: #selector(endTapped), for: .touchUpInside)
        muteButton.addTarget(self, action: #selector(muteTapped), for: .touchUpInside)
        cameraOffButton.addTarget(self, action: #selector(cameraOffTapped), for: .touchUpInside)
        switchCameraButton.addTarget(self, action: #selector(switchCameraTapped), for: .touchUpInside)
    }

    // MARK: - Animation & Timer
    private func startCallAnimation() {
        UIView.animate(withDuration: 1.0, delay: 0, options: [.autoreverse, .repeat, .curveEaseInOut]) {
            self.pulseAnimationView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            self.pulseAnimationView.alpha = 0.5
        }
    }

    private func stopCallAnimationAndConnect() {
        guard !callDidConnect else { return }
        callDidConnect = true
        hideLoading()
        pulseAnimationView.layer.removeAllAnimations()
        pulseAnimationView.isHidden = true
        connectingLabel.isHidden = true
        stopAudio()
        startTimer()
    }

    private func startTimer() {
        timer?.invalidate()
        secondsElapsed = 0
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.secondsElapsed += 1
            let m = self.secondsElapsed / 60
            let s = self.secondsElapsed % 60
            self.durationLabel.text = String(format: "%02d:%02d", m, s)
        }
    }

    private func playAudio(named: String) {
        systemSoundID = 1001
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] t in
            guard let self = self, self.systemSoundID != 0 else {
                t.invalidate()
                return
            }
            AudioServicesPlayAlertSound(self.systemSoundID)
        }
    }

    private func stopAudio() {
        systemSoundID = 0
    }

    // MARK: - Actions
    @objc private func endTapped() {
        timer?.invalidate()
        hideLoading()
        agoraManager.leaveChannel()
        signalingClient.endCall()
        stopAudio()
        dismiss(animated: true)
    }

    @objc private func muteTapped() {
        isMuted.toggle()
        muteButton.backgroundColor = isMuted ? .white : .darkGray
        muteButton.tintColor = isMuted ? .black : .white
        muteButton.setImage(UIImage(systemName: isMuted ? "mic.slash.fill" : "mic.fill"), for: .normal)
        agoraManager.muteAudio(isMuted)
    }

    @objc private func cameraOffTapped() {
        isCameraOff.toggle()
        cameraOffButton.backgroundColor = isCameraOff ? .white : .darkGray
        cameraOffButton.tintColor = isCameraOff ? .black : .white
        cameraOffButton.setImage(UIImage(systemName: isCameraOff ? "video.slash.fill" : "video.fill"), for: .normal)
        localVideoView.isHidden = isCameraOff
        agoraManager.disableVideo(isCameraOff)
    }

    @objc private func switchCameraTapped() {
        agoraManager.switchCamera()
        UIView.animate(withDuration: 0.2) {
            self.switchCameraButton.transform = self.switchCameraButton.transform.rotated(by: .pi)
        }
    }
}

// MARK: - AgoraManagerDelegate
extension CallViewController: AgoraManagerDelegate {
    
    func agoraManager(_ manager: AgoraManager, didJoinedRemoteUser uid: UInt, withView view: UIView) {
        
        print("👤 Agora: Karşı taraf ekrana bağlanıyor. UID: \(uid)")

        DispatchQueue.main.async {
            print("👤 Agora: Karşı taraf ekrana bağlanıyor. UID: \(uid)")
            
            // Agora'nın oluşturduğu view'ı bizim remoteVideoView'ın içine gömüyoruz
            let videoCanvas = AgoraRtcVideoCanvas()
            videoCanvas.uid = uid
            videoCanvas.view = self.remoteVideoView
            videoCanvas.renderMode = .hidden
            self.agoraManager.agoraKit?.setupRemoteVideo(videoCanvas)
            
            self.stopCallAnimationAndConnect()
            
        }
    }
    
    func agoraManager(_ manager: AgoraManager, didOfflineOfUid uid: UInt) {
        DispatchQueue.main.async {
            self.endTapped()
        }
    }
    
    func agoraManager(_ manager: AgoraManager, didJoinedChannel channel: String) {
        print("✅ Agora: Kanala katılım başarılı: \(channel)")
        DispatchQueue.main.async {
            // Loader ve arkasındaki kutuyu tamamen gizle
            self.loadingIndicator.stopAnimating()
            self.loadingIndicator.isHidden = true
            self.loadingContainer.isHidden = true
            self.connectingLabel.text = "Bağlanıyor..."
        }
        
        
    }
}

// MARK: - SignalingClientDelegate (Sadece durum takibi için)
extension CallViewController: SignalingClientDelegate {
    func signalingClient(_ client: SignalingClient, didChangeStatus status: String) {
        DispatchQueue.main.async {
            print("📞 Signaling status: \(status)")
            switch status {
            case "rejected", "ended":
                self.endTapped()
            default:
                break
            }
        }
    }
}
