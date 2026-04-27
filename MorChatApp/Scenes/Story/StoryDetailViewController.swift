
import UIKit
import SnapKit
import Kingfisher

final class StoryDetailViewController: UIViewController {
    
    private let storyUrls: [String]
    private var currentIndex: Int = 0
    private var progressViews: [UIView] = []
    private var timer: Timer?
    private var currentProgress: CGFloat = 0
    
    // MARK: - UI Components
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = .black
        iv.isUserInteractionEnabled = true
        return iv
    }()
    
    private let progressBarStack: UIStackView = {
        let s = UIStackView()
        s.axis = .horizontal
        s.spacing = 4
        s.distribution = .fillEqually
        return s
    }()
    
    private let closeButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "xmark"), for: .normal)
        b.tintColor = .white
        return b
    }()
    
    private let deleteButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "trash"), for: .normal)
        b.tintColor = .white
        return b
    }()
    
    private let userStack: UIStackView = {
        let s = UIStackView()
        s.axis = .horizontal
        s.spacing = 8
        s.alignment = .center
        return s
    }()
    
    private let userImageView: UIImageView = {
        let iv = UIImageView()
        iv.layer.cornerRadius = 15
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        return iv
    }()
    
    private let userNameLabel: UILabel = {
        let l = UILabel()
        l.textColor = .white
        l.font = .systemFont(ofSize: 14, weight: .bold)
        return l
    }()

    var onDeleteTapped: ((Int) -> Void)?

    // MARK: - Init
    init(storyUrls: [String], userName: String?, userProfilePic: String?) {
        self.storyUrls = storyUrls
        super.init(nibName: nil, bundle: nil)
        self.userNameLabel.text = userName
        if let url = userProfilePic { self.userImageView.kf.setImage(with: URL(string: url)) }
        modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupUI()
        setupGestures()
        showStory(at: 0)
    }
    
    private func setupUI() {
        view.addSubview(imageView)
        imageView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        view.addSubview(progressBarStack)
        progressBarStack.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            make.leading.trailing.equalToSuperview().inset(8)
            make.height.equalTo(2)
        }
        
        setupProgressBars()
        
        view.addSubview(userStack)
        userStack.addArrangedSubview(userImageView)
        userStack.addArrangedSubview(userNameLabel)
        userImageView.snp.makeConstraints { $0.size.equalTo(30) }
        userStack.snp.makeConstraints { make in
            make.top.equalTo(progressBarStack.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(12)
        }
        
        view.addSubview(closeButton)
        closeButton.snp.makeConstraints { make in
            make.centerY.equalTo(userStack)
            make.trailing.equalToSuperview().inset(12)
            make.size.equalTo(44)
        }
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)

        view.addSubview(deleteButton)
        deleteButton.snp.makeConstraints { make in
            make.centerY.equalTo(userStack)
            make.trailing.equalTo(closeButton.snp.leading).offset(-8)
            make.size.equalTo(44)
        }
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
    }
    
    private func setupProgressBars() {
        progressBarStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        progressViews.removeAll()
        
        for _ in 0..<storyUrls.count {
            let container = UIView()
            container.backgroundColor = UIColor.white.withAlphaComponent(0.3)
            container.layer.cornerRadius = 1
            
            let progressView = UIView()
            progressView.backgroundColor = .white
            progressView.layer.cornerRadius = 1
            container.addSubview(progressView)
            progressView.snp.makeConstraints { make in
                make.top.bottom.leading.equalToSuperview()
                make.width.equalTo(0)
            }
            
            progressBarStack.addArrangedSubview(container)
            progressViews.append(progressView)
        }
    }
    
    private func showStory(at index: Int) {
        guard index >= 0 && index < storyUrls.count else {
            closeTapped()
            return
        }
        
        currentIndex = index
        let url = storyUrls[currentIndex]
        imageView.kf.setImage(with: URL(string: url))
        
        // Reset progress bars
        for i in 0..<progressViews.count {
            progressViews[i].snp.remakeConstraints { make in
                make.top.bottom.leading.equalToSuperview()
                make.width.equalToSuperview().multipliedBy(i < currentIndex ? 1.0 : 0.0)
            }
        }
        
        startTimer()
    }
    
    private func startTimer() {
        timer?.invalidate()
        currentProgress = 0
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.currentProgress += 0.01
            
            self.progressViews[self.currentIndex].snp.remakeConstraints { make in
                make.top.bottom.leading.equalToSuperview()
                make.width.equalToSuperview().multipliedBy(min(self.currentProgress, 1.0))
            }
            
            if self.currentProgress >= 1.0 {
                self.nextStory()
            }
        }
    }
    
    private func nextStory() {
        if currentIndex < storyUrls.count - 1 {
            showStory(at: currentIndex + 1)
        } else {
            closeTapped()
        }
    }
    
    private func previousStory() {
        if currentIndex > 0 {
            showStory(at: currentIndex - 1)
        } else {
            showStory(at: 0)
        }
    }
    
    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        imageView.addGestureRecognizer(tapGesture)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        view.addGestureRecognizer(panGesture)
    }
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: view)
        if location.x < view.bounds.width / 3 {
            previousStory()
        } else {
            nextStory()
        }
    }
    
    @objc private func closeTapped() {
        timer?.invalidate()
        dismiss(animated: true)
    }
    
    @objc private func deleteTapped() {
        timer?.invalidate()
        let alert = UIAlertController(title: "story_delete_title".localized, message: "story_delete_message".localized, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "photo_cancel".localized, style: .cancel) { _ in self.startTimer() })
        alert.addAction(UIAlertAction(title: "photo_delete".localized, style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            self.dismiss(animated: true) {
                self.onDeleteTapped?(self.currentIndex)
            }
        })
        present(alert, animated: true)
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        let velocity = gesture.velocity(in: view)
        
        switch gesture.state {
        case .began: timer?.invalidate()
        case .changed:
            if translation.y > 0 {
                let scale = max(0.8, 1 - (translation.y / 1000))
                view.transform = CGAffineTransform(translationX: 0, y: translation.y).scaledBy(x: scale, y: scale)
            }
        case .ended:
            if translation.y > 150 || velocity.y > 500 {
                closeTapped()
            } else {
                UIView.animate(withDuration: 0.3) {
                    self.view.transform = .identity
                } completion: { _ in self.startTimer() }
            }
        default: break
        }
    }
}
