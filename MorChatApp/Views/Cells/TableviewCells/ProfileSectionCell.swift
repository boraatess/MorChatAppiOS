import UIKit
import SnapKit

final class ProfileSectionCell: UITableViewCell {
    
    static let identifier = "ProfileSectionCell"
    
    // MARK: - UI Components
    
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
        l.numberOfLines = 0
        return l
    }()
    
    private let containerView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(red: 0.18, green: 0.12, blue: 0.30, alpha: 1.0)
        v.layer.cornerRadius = 10
        return v
    }()
    
    private let contentStack: UIStackView = {
        let s = UIStackView()
        s.axis = .horizontal
        s.spacing = 8
        s.alignment = .center
        return s
    }()
    
    private let contentLabel: UILabel = {
        let l = UILabel()
        l.textColor = .white
        l.font = .systemFont(ofSize: 14)
        l.numberOfLines = 0
        return l
    }()
    
    private let editButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Edit", for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 12, weight: .bold)
        b.backgroundColor = UIColor.systemPink
        b.layer.cornerRadius = 6
        return b
    }()
    
    private let tagsContainer = UIStackView()
    
    var onEditTapped: (() -> Void)?
    
    // MARK: - Init
    
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
        
        containerView.addSubview(contentStack)
        contentStack.addArrangedSubview(contentLabel)
        contentStack.addArrangedSubview(tagsContainer) // For interests
        containerView.addSubview(editButton)
        
        editButton.addTarget(self, action: #selector(editTapped), for: .touchUpInside)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.trailing.equalTo(titleLabel)
        }
        
        containerView.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(8)
            make.height.greaterThanOrEqualTo(50)
        }
        
        contentStack.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.trailing.equalTo(editButton.snp.leading).offset(-12)
        }
        
        editButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(12)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 75, height: 28))
        }
    }
    
    @objc private func editTapped() {
        onEditTapped?()
    }
    
    func configure(title: String, subtitle: String?, content: String?, tags: [String]? = nil, buttonTitle: String? = "Edit", isButtonHidden: Bool = false) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        contentLabel.text = content
        
        editButton.isHidden = isButtonHidden
        if let btnTitle = buttonTitle {
            editButton.setTitle(btnTitle, for: .normal)
        }
        
        // Handle tags if any
        tagsContainer.arrangedSubviews.forEach { $0.removeFromSuperview() }
        if let tags = tags, !tags.isEmpty {
            contentLabel.isHidden = true
            tagsContainer.isHidden = false
            tagsContainer.axis = .horizontal
            tagsContainer.spacing = 4
            for tag in tags.prefix(3) { // Show first 3
                let pill = createTagPill(tag)
                tagsContainer.addArrangedSubview(pill)
            }
        } else {
            contentLabel.isHidden = false
            tagsContainer.isHidden = true
        }
    }
    
    private func createTagPill(_ text: String) -> UIView {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        v.layer.cornerRadius = 6
        let l = UILabel()
        l.text = text
        l.textColor = .white
        l.font = .systemFont(ofSize: 10)
        v.addSubview(l)
        l.snp.makeConstraints { $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 2, left: 6, bottom: 2, right: 6)) }
        return v
    }
}
