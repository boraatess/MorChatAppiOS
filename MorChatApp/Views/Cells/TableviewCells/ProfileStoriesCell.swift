
import UIKit
import SnapKit
import Kingfisher

final class ProfileStoriesCell: UITableViewCell {
    static let identifier = "ProfileStoriesCell"
    
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.textColor = .white
        l.font = .systemFont(ofSize: 15, weight: .bold)
        return l
    }()
    
    private let subtitleLabel: UILabel = {
        let l = UILabel()
        l.textColor = UIColor.white.withAlphaComponent(0.6)
        l.font = .systemFont(ofSize: 11)
        return l
    }()
    
    private let containerView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(red: 0.18, green: 0.12, blue: 0.30, alpha: 1.0)
        v.layer.cornerRadius = 10
        return v
    }()
    
    private lazy var collectionView: UICollectionView = {
        // ... (layout ayarları aynı)
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 70, height: 90)
        layout.minimumLineSpacing = 12
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.register(StoryItemCell.self, forCellWithReuseIdentifier: StoryItemCell.identifier)
        cv.delegate = self
        cv.dataSource = self
        return cv
    }()
    
    var onStorySelected: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(containerView)
        containerView.addSubview(collectionView)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.equalToSuperview().offset(16)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.equalTo(titleLabel)
        }
        
        containerView.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(8)
            make.height.equalTo(110)
        }
        
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12))
        }
    }
    
    private var storyUrls: [String] = []
    private var profilePicUrl: String?

    func configure(title: String, subtitle: String?, stories: [StoryModel]?, profilePic: String?) {
        self.titleLabel.text = title
        self.subtitleLabel.text = subtitle
        self.storyUrls = stories?.compactMap { $0.url } ?? []
        self.profilePicUrl = profilePic
        collectionView.reloadData()
    }
}

extension ProfileStoriesCell: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return storyUrls.isEmpty ? 0 : 1 
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StoryItemCell.identifier, for: indexPath) as! StoryItemCell
        cell.configure(name: "My Story", image: profilePicUrl)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onStorySelected?()
    }
}

// MARK: - Story Item Cell
class StoryItemCell: UICollectionViewCell {
    static let identifier = "StoryItemCell"
    private let imageView = UIImageView()
    private let nameLabel = UILabel()
    private let gradientLayer = CAGradientLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView.backgroundColor = .systemPink
        imageView.layer.cornerRadius = 30
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.systemPink.cgColor
        contentView.addSubview(imageView)
        
        nameLabel.textColor = .white
        nameLabel.font = .systemFont(ofSize: 10)
        nameLabel.textAlignment = .center
        contentView.addSubview(nameLabel)
        
        imageView.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.size.equalTo(60)
        }
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview()
        }
    }
    required init?(coder: NSCoder) { fatalError() }
    func configure(name: String, image: String?) {
        nameLabel.text = name
        if let urlStr = image, let url = URL(string: urlStr) {
            imageView.kf.setImage(with: url)
        } else {
            imageView.image = nil
            imageView.backgroundColor = .systemPink
        }
    }
}
