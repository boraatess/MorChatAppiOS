import UIKit
import SnapKit
import Kingfisher

protocol PublisherProfileHeaderViewDelegate: AnyObject {
    func publisherHeaderDidTapPhoto()
    func publisherHeaderDidTapAddStory()
}

final class PublisherProfileHeaderView: UIView {
    
    weak var delegate: PublisherProfileHeaderViewDelegate?
    
    // MARK: - UI Components
    
    private let profileImageContainer: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 50
        v.layer.borderWidth = 3
        v.layer.borderColor = UIColor.white.cgColor
        v.clipsToBounds = true
        return v
    }()
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.image = UIImage(systemName: "person.fill")
        iv.tintColor = .lightGray
        return iv
    }()
    
    private let cameraIconContainer: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.systemPink
        v.layer.cornerRadius = 14
        v.layer.borderWidth = 2
        v.layer.borderColor = UIColor.white.cgColor
        return v
    }()
    
    private let cameraIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "camera.fill"))
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private let editPhotoLabel: UILabel = {
        let l = UILabel()
        l.text = "Edit Photo"
        l.textColor = .white
        l.font = .systemFont(ofSize: 12, weight: .medium)
        l.textAlignment = .center
        return l
    }()
    
    private let likesIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "flame.fill"))
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private let likesLabel: UILabel = {
        let l = UILabel()
        l.text = "0 Likes"
        l.textColor = .white
        l.font = .systemFont(ofSize: 14, weight: .bold)
        return l
    }()
    
    // Right Side Components
    private let starsStack: UIStackView = {
        let s = UIStackView()
        s.axis = .horizontal
        s.spacing = 4
        s.distribution = .fillEqually
        for _ in 0..<5 {
            let iv = UIImageView(image: UIImage(systemName: "star.fill"))
            iv.tintColor = UIColor.white.withAlphaComponent(0.2)
            iv.contentMode = .scaleAspectFit
            s.addArrangedSubview(iv)
        }
        return s
    }()
    
    private let descriptionLabel: UILabel = {
        let l = UILabel()
        l.text = "As viewers rate your broadcasts, your stars increase. Higher stars mean you appear first on the home page."
        l.textColor = UIColor.white.withAlphaComponent(0.8)
        l.font = .systemFont(ofSize: 12)
        l.numberOfLines = 0
        return l
    }()
    
    private let addStoryButton: UIButton = {
        let b = UIButton(type: .system)
        var config = UIButton.Configuration.filled()
        config.title = "Add Story"
        config.image = UIImage(systemName: "plus")
        config.imagePadding = 8
        config.baseBackgroundColor = UIColor.systemPink
        config.cornerStyle = .capsule
        b.configuration = config
        return b
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupUI() {
        // Build Left column
        addSubview(profileImageContainer)
        profileImageContainer.addSubview(profileImageView)
        addSubview(cameraIconContainer)
        cameraIconContainer.addSubview(cameraIcon)
        addSubview(editPhotoLabel)
        addSubview(likesIcon)
        addSubview(likesLabel)
        
        // Build Right column
        addSubview(starsStack)
        addSubview(descriptionLabel)
        addSubview(addStoryButton)
        
        let photoBtn = UIButton()
        addSubview(photoBtn)
        photoBtn.addTarget(self, action: #selector(photoTapped), for: .touchUpInside)
        addStoryButton.addTarget(self, action: #selector(addStoryTapped), for: .touchUpInside)
        
        // Constraints Left
        profileImageContainer.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(20)
            make.size.equalTo(100)
        }
        
        profileImageView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        cameraIconContainer.snp.makeConstraints { make in
            make.bottom.trailing.equalTo(profileImageContainer)
            make.size.equalTo(28)
        }
        
        cameraIcon.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(16)
        }
        
        editPhotoLabel.snp.makeConstraints { make in
            make.top.equalTo(profileImageContainer.snp.bottom).offset(8)
            make.centerX.equalTo(profileImageContainer)
        }
        
        likesIcon.snp.makeConstraints { make in
            make.top.equalTo(editPhotoLabel.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(30)
            make.size.equalTo(16)
        }
        
        likesLabel.snp.makeConstraints { make in
            make.centerY.equalTo(likesIcon)
            make.leading.equalTo(likesIcon.snp.trailing).offset(6)
        }
        
        photoBtn.snp.makeConstraints { $0.edges.equalTo(profileImageContainer) }
        
        // Constraints Right
        starsStack.snp.makeConstraints { make in
            make.top.equalTo(profileImageContainer).offset(4)
            make.leading.equalTo(profileImageContainer.snp.trailing).offset(24)
            make.width.equalTo(120)
            make.height.equalTo(24)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(starsStack.snp.bottom).offset(12)
            make.leading.equalTo(starsStack)
            make.trailing.equalToSuperview().inset(20)
        }
        
        addStoryButton.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(16)
            make.leading.equalTo(starsStack)
            make.height.equalTo(36)
            make.width.equalTo(140)
        }
    }
    
    @objc private func photoTapped() { delegate?.publisherHeaderDidTapPhoto() }
    @objc private func addStoryTapped() { delegate?.publisherHeaderDidTapAddStory() }
    
    func setProfileImage(_ image: UIImage) { profileImageView.image = image }
    func setProfileImage(url: String?) {
        guard let urlString = url, let url = URL(string: urlString) else { return }
        profileImageView.kf.setImage(with: url, placeholder: UIImage(systemName: "person.fill"))
    }
}
