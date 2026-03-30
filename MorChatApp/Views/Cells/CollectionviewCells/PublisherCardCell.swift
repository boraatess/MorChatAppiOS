
import Foundation
import Kingfisher
import UIKit
import SnapKit

final class PublisherCardCell: UICollectionViewCell {
    
    // MARK: - UI
    static let identifier = "PublisherCardCell"

    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    private let statusPill: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.systemPink.withAlphaComponent(0.8)
        v.layer.cornerRadius = 10
        return v
    }()
    
    private let statusLabel: UILabel = {
        let l = UILabel()
        l.text = "Away"
        l.textColor = .white
        l.font = .systemFont(ofSize: 10, weight: .bold)
        return l
    }()
    
    private let gradientView = UIView()
    private let gradientLayer = CAGradientLayer()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 15, weight: .bold)
        return label
    }()

    private let tagsStack: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.spacing = 4
        s.alignment = .leading
        return s
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
        setupGradient()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func configure(with model: UserCardModel) {
        nameLabel.text = model.name
        statusLabel.text = model.status ?? "Away"
        
        // Clear previous tags
        tagsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Dynamic wrapping with StackViews + MAX ROW LIMIT
        let maxWidth = bounds.width - 16
        let maxRows = 3
        var rowCount = 1
        
        var currentRowStack = createRowStack()
        tagsStack.addArrangedSubview(currentRowStack)
        
        var currentLineWidth: CGFloat = 0
        let tagSpacing: CGFloat = 4
        
        for tagStr in model.tags {
            let tagView = createTagView(tagStr)
            let tagWidth = calculateTagWidth(for: tagStr) + 16
            
            if currentLineWidth + tagWidth > maxWidth && currentLineWidth > 0 {
                if rowCount >= maxRows { break } // STOP adding rows if limit reached
                
                currentRowStack = createRowStack()
                tagsStack.addArrangedSubview(currentRowStack)
                currentLineWidth = 0
                rowCount += 1
            }
            
            currentRowStack.addArrangedSubview(tagView)
            currentLineWidth += tagWidth + tagSpacing
        }
        
        if let urlString = model.imageURL, let url = URL(string: urlString) {
            imageView.kf.setImage(with: url, placeholder: UIImage(systemName: "person.circle.fill"))
        } else {
            imageView.image = UIImage(systemName: "person.circle.fill")
        }
    }
    
    private func createRowStack() -> UIStackView {
        let s = UIStackView()
        s.axis = .horizontal
        s.spacing = 4
        s.alignment = .leading
        return s
    }
    
    private func calculateTagWidth(for text: String) -> CGFloat {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 10, weight: .medium)
        label.sizeToFit()
        return label.frame.width
    }
    
    private func createTagView(_ text: String) -> UIView {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        v.layer.cornerRadius = 4
        v.layer.borderWidth = 0.5
        v.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        
        let l = UILabel()
        l.text = text
        l.textColor = .white
        l.font = .systemFont(ofSize: 10, weight: .medium)
        
        v.addSubview(l)
        l.snp.makeConstraints { $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 2, left: 8, bottom: 2, right: 8)) }
        return v
    }

    private func setupUI() {
        contentView.layer.cornerRadius = 12
        contentView.clipsToBounds = true
        
        contentView.addSubview(imageView)
        contentView.addSubview(gradientView)
        
        statusPill.addSubview(statusLabel)
        contentView.addSubview(statusPill)
        
        contentView.addSubview(nameLabel)
        contentView.addSubview(tagsStack)
    }
    
    private func setupConstraints() {
        imageView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        gradientView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalToSuperview().multipliedBy(0.5)
        }
        
        statusPill.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.trailing.equalToSuperview().inset(12)
            $0.height.equalTo(20)
            $0.width.greaterThanOrEqualTo(50)
        }
        
        statusLabel.snp.makeConstraints { $0.center.equalToSuperview() }
        
        tagsStack.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(8)
            $0.bottom.equalToSuperview().inset(12) // Anchored to bottom instead of btnStack
        }
        
        nameLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(8)
            $0.bottom.equalTo(tagsStack.snp.top).offset(-6)
        }
    }
    
    private func setupGradient() {
        gradientLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.8).cgColor
        ]
        gradientLayer.locations = [0.0, 1.0]
        gradientView.layer.addSublayer(gradientLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = gradientView.bounds
    }
}
