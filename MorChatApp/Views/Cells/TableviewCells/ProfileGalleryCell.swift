
import UIKit
import SnapKit
import Kingfisher

final class ProfileGalleryCell: UITableViewCell {
    static let identifier = "ProfileGalleryCell"
    
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let containerView = UIView()
    
    private var photos: [String] = []
    var onAddPhotoTapped: (() -> Void)?
    var onDeletePhotoTapped: ((Int) -> Void)?

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 80, height: 100)
        layout.minimumLineSpacing = 10
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.register(GalleryItemCell.self, forCellWithReuseIdentifier: GalleryItemCell.identifier)
        cv.register(GalleryAddCell.self, forCellWithReuseIdentifier: GalleryAddCell.identifier)
        cv.delegate = self
        cv.dataSource = self
        return cv
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        containerView.backgroundColor = UIColor(red: 0.18, green: 0.12, blue: 0.30, alpha: 1.0)
        containerView.layer.cornerRadius = 10
        
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 15, weight: .bold)
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.6)
        subtitleLabel.font = .systemFont(ofSize: 11)
        subtitleLabel.numberOfLines = 0
        
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
            make.trailing.equalToSuperview().inset(16)
        }
        containerView.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(8)
            make.height.equalTo(130)
        }
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(10)
        }
    }
    
    func configure(title: String, subtitle: String?, photos: [String]) {
        self.titleLabel.text = title
        self.subtitleLabel.text = subtitle
        self.photos = photos
        collectionView.reloadData()
    }
}

extension ProfileGalleryCell: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GalleryAddCell.identifier, for: indexPath) as! GalleryAddCell
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GalleryItemCell.identifier, for: indexPath) as! GalleryItemCell
            cell.configure(url: photos[indexPath.item - 1])
            cell.onDelete = { [weak self] in self?.onDeletePhotoTapped?(indexPath.item - 1) }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 0 { onAddPhotoTapped?() }
    }
}

// MARK: - Gallery Items
class GalleryAddCell: UICollectionViewCell {
    static let identifier = "GalleryAddCell"
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        contentView.layer.cornerRadius = 8
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 4
        let img = UIImageView(image: UIImage(systemName: "plus.circle.fill"))
        img.tintColor = .white
        let lbl = UILabel()
        lbl.text = "Galeri"
        lbl.textColor = .white
        lbl.font = .systemFont(ofSize: 10)
        stack.addArrangedSubview(img)
        stack.addArrangedSubview(lbl)
        contentView.addSubview(stack)
        stack.snp.makeConstraints { $0.center.equalToSuperview() }
    }
    required init?(coder: NSCoder) { fatalError() }
}

class GalleryItemCell: UICollectionViewCell {
    static let identifier = "GalleryItemCell"
    private let iv = UIImageView()
    private let deleteBtn = UIButton()
    var onDelete: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 8
        iv.backgroundColor = .darkGray
        contentView.addSubview(iv)
        iv.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        deleteBtn.backgroundColor = .systemRed
        deleteBtn.setImage(UIImage(systemName: "trash.fill"), for: .normal)
        deleteBtn.tintColor = .white
        deleteBtn.layer.cornerRadius = 4
        contentView.addSubview(deleteBtn)
        deleteBtn.snp.makeConstraints { make in
            make.bottom.trailing.equalToSuperview().inset(4)
            make.size.equalTo(24)
        }
        deleteBtn.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
    }
    @objc private func deleteTapped() { onDelete?() }
    required init?(coder: NSCoder) { fatalError() }
    func configure(url: String) { iv.kf.setImage(with: URL(string: url)) }
}
