import UIKit
import SnapKit
import Kingfisher

protocol ProfileTableHeaderViewDelegate: AnyObject {
    func profileHeaderDidTapPhoto()
}

final class ProfileTableHeaderView: UIView {
    
    weak var delegate: ProfileTableHeaderViewDelegate?
    
    // UI Elements
    private let subHeaderView = SubHeaderView()
    private let profileImageContainer = UIView()
    private let profileImageView = UIImageView()
    private let cameraIconContainer = UIView()
    private let photoOverlayButton = UIButton()
    
    private let nameLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 20, weight: .bold)
        l.textColor = .white
        l.textAlignment = .center
        return l
    }()
    
    private let interestsScrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsHorizontalScrollIndicator = false
        return sv
    }()
    
    private let interestsStack: UIStackView = {
        let s = UIStackView()
        s.axis = .horizontal
        s.spacing = 8
        return s
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupUI() {
        subHeaderView.configure(title: "My Account", subtitle: "Determine your interest, chat.")
        
        // Circular profile pic
        profileImageContainer.backgroundColor = UIColor.white
        profileImageContainer.layer.cornerRadius = 50
        profileImageContainer.layer.borderWidth = 3
        profileImageContainer.layer.borderColor = UIColor(red: 0.6, green: 0.4, blue: 0.8, alpha: 0.5).cgColor
        profileImageContainer.clipsToBounds = true
        
        profileImageView.image = UIImage(systemName: "plus")
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .bold)
        profileImageView.preferredSymbolConfiguration = config
        profileImageView.tintColor = UIColor(red: 0.8, green: 0.85, blue: 1.0, alpha: 1.0)
        profileImageView.contentMode = .center
        
        cameraIconContainer.backgroundColor = UIColor(red: 0.9, green: 0.3, blue: 0.8, alpha: 1.0)
        cameraIconContainer.layer.cornerRadius = 14
        let cameraIcon = UIImageView(image: UIImage(systemName: "camera.fill"))
        cameraIcon.tintColor = .white
        cameraIcon.contentMode = .scaleAspectFit
        
        addSubview(profileImageContainer)
        profileImageContainer.addSubview(profileImageView)
        addSubview(cameraIconContainer)
        cameraIconContainer.addSubview(cameraIcon)
        
        addSubview(photoOverlayButton)
        
        photoOverlayButton.addTarget(self, action: #selector(photoTapped), for: .touchUpInside)
        
        profileImageContainer.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.centerX.equalToSuperview()
            make.size.equalTo(100)
        }
        
        profileImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        cameraIconContainer.snp.makeConstraints { make in
            make.bottom.equalTo(profileImageContainer)
            make.trailing.equalTo(profileImageContainer)
            make.size.equalTo(28)
        }
        
        cameraIcon.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(16)
        }
        
        photoOverlayButton.snp.makeConstraints { make in
            make.edges.equalTo(profileImageContainer)
        }
        
    }
    
    @objc private func photoTapped() {
        delegate?.profileHeaderDidTapPhoto()
    }
    
    func setProfileImage(_ image: UIImage) {
        profileImageView.image = image
        profileImageView.contentMode = .scaleAspectFill
        profileImageContainer.clipsToBounds = true
    }
    
    func setProfileImage(url: String?) {
        guard let urlString = url, let url = URL(string: urlString) else { return }
        profileImageView.kf.setImage(with: url, placeholder: UIImage(systemName: "plus"))
        profileImageView.contentMode = .scaleAspectFill
        profileImageContainer.clipsToBounds = true
    }
}
