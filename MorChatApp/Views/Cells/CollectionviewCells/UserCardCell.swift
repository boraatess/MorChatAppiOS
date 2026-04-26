
import Foundation
import Kingfisher
import UIKit
import SnapKit


protocol UserCardCellDelegate: AnyObject {
    func didTapCallNow(on cell: UserCardCell)
    func didTapVoiceCall(on cell: UserCardCell)
}

final class UserCardCell: UICollectionViewCell {
    
    // MARK: - UI
    static let identifier = "UserCardCell"
    weak var delegate: UserCardCellDelegate?

    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    private let coinView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        v.layer.cornerRadius = 12
        return v
    }()
    
    private let coinIcon: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "dollarsign.circle.fill")
        iv.tintColor = .systemYellow
        return iv
    }()
    
    private let coinLabel: UILabel = {
        let l = UILabel()
        l.text = "5"
        l.textColor = .white
        l.font = .systemFont(ofSize: 12, weight: .bold)
        return l
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
    
    private let blockButton: UIButton = {
        let b = UIButton(type: .system)
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "nosign")
        config.title = "Block"
        config.imagePlacement = .top
        config.imagePadding = 2
        config.baseForegroundColor = .red
        
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = .systemFont(ofSize: 8, weight: .bold)
            return outgoing
        }
        
        b.configuration = config
        return b
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
    
    private let btnStack: UIStackView = {
        let s = UIStackView()
        s.axis = .horizontal
        s.spacing = 8
        s.distribution = .fillEqually
        return s
    }()
    
    private let callNowBtn: UIButton = {
        let b = UIButton(type: .system)
        b.backgroundColor = .systemPurple
        b.setTitle("Call Now", for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 11, weight: .bold)
        b.setImage(UIImage(systemName: "video.fill"), for: .normal)
        b.tintColor = .white
        b.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
        b.layer.cornerRadius = 8
        return b
    }()
    
    private let voiceCallBtn: UIButton = {
        let b = UIButton(type: .system)
        b.backgroundColor = .systemPurple
        b.setTitle("Voice Call", for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 11, weight: .bold)
        b.setImage(UIImage(systemName: "phone.fill"), for: .normal)
        b.tintColor = .white
        b.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
        b.layer.cornerRadius = 8
        return b
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
        setupConstraints()
        setupGradient()
        setupActions()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupActions() {
        callNowBtn.addTarget(self, action: #selector(didTapCallNow), for: .touchUpInside)
        voiceCallBtn.addTarget(self, action: #selector(didTapVoiceCall), for: .touchUpInside)
    }
    
    @objc private func didTapCallNow() {
        delegate?.didTapCallNow(on: self)
    }
    
    @objc private func didTapVoiceCall() {
        delegate?.didTapVoiceCall(on: self)
    }
    
    func configure(with model: UserCardModel) {
        nameLabel.text = model.name
        statusLabel.text = model.status ?? "Away"
        
        // 🔥 ONLINE DURUMUNA GÖRE RENK DEĞİŞİMİ
        let isOnline = (model.status == "Online" || model.status == "Çevrimiçi")
        statusPill.backgroundColor = isOnline ? UIColor.systemGreen.withAlphaComponent(0.9) : UIColor.systemPink.withAlphaComponent(0.8)
        
        
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
        
        var displayedTags = model.mappedTags
        for interest in model.mappedInterests {
            if !displayedTags.contains(interest) {
                displayedTags.append(interest)
            }
        }
        
        for tagStr in displayedTags {
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
        
        coinView.addSubview(coinIcon)
        coinView.addSubview(coinLabel)
        contentView.addSubview(coinView)
        
        statusPill.addSubview(statusLabel)
        contentView.addSubview(statusPill)
        contentView.addSubview(blockButton)
        
        contentView.addSubview(nameLabel)
        contentView.addSubview(tagsStack)
        
        btnStack.addArrangedSubview(callNowBtn)
        btnStack.addArrangedSubview(voiceCallBtn)
        contentView.addSubview(btnStack)
    }
    
    private func setupConstraints() {
        imageView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        gradientView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalToSuperview().multipliedBy(0.5)
        }
        
        coinView.snp.makeConstraints {
            $0.top.leading.equalToSuperview().offset(12)
            $0.height.equalTo(24)
            $0.width.greaterThanOrEqualTo(45)
        }
        
        coinIcon.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(6)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(14)
        }
        
        coinLabel.snp.makeConstraints {
            $0.leading.equalTo(coinIcon.snp.trailing).offset(4)
            $0.trailing.equalToSuperview().inset(6)
            $0.centerY.equalToSuperview()
        }
        
        statusPill.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.trailing.equalToSuperview().inset(12)
            $0.height.equalTo(20)
            $0.width.greaterThanOrEqualTo(50)
        }
        
        statusLabel.snp.makeConstraints { $0.center.equalToSuperview() }
        
        blockButton.snp.makeConstraints {
            $0.top.equalTo(statusPill.snp.bottom).offset(4)
            $0.trailing.equalTo(statusPill)
            $0.width.equalTo(40)
        }
        
        btnStack.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview().inset(8)
            $0.height.equalTo(28)
        }
        
        tagsStack.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(8)
            $0.bottom.equalTo(btnStack.snp.top).offset(-8)
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
        applyButtonGradient(callNowBtn)
        applyButtonGradient(voiceCallBtn)
    }
    
    private func applyButtonGradient(_ button: UIButton) {
        let name = "btn_grad"
        button.layer.sublayers?.filter { $0.name == name }.forEach { $0.removeFromSuperlayer() }
        let grad = CAGradientLayer()
        grad.name = name
        grad.colors = [
            UIColor(red: 0.6, green: 0.3, blue: 0.8, alpha: 1.0).cgColor,
            UIColor(red: 0.4, green: 0.1, blue: 0.6, alpha: 1.0).cgColor
        ]
        grad.startPoint = CGPoint(x: 0, y: 0.5)
        grad.endPoint = CGPoint(x: 1, y: 0.5)
        grad.frame = button.bounds
        grad.cornerRadius = button.layer.cornerRadius
        button.layer.insertSublayer(grad, at: 0)
    }
}
