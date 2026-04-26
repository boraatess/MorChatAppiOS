import UIKit
import SnapKit

protocol FAQHeaderViewDelegate: AnyObject {
    func headerTapped(section: Int)
}

final class FAQHeaderView: UITableViewHeaderFooterView {
    static let identifier = "FAQHeaderView"
    
    weak var delegate: FAQHeaderViewDelegate?
    private var section: Int = 0
    
    private let titleLabel = UILabel()
    private let arrowImageView = UIImageView()
    private let containerView = UIView()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setupUI() {
        contentView.backgroundColor = .clear
        backgroundView = UIView()
        backgroundView?.backgroundColor = .clear
        
        contentView.addSubview(containerView)
        containerView.backgroundColor = .systemBackground
        containerView.layer.cornerRadius = 16
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(arrowImageView)
        
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel.numberOfLines = 0
        
        arrowImageView.image = UIImage(systemName: "chevron.down")
        arrowImageView.tintColor = .black
        arrowImageView.contentMode = .scaleAspectFit
        
        containerView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(6)
            make.bottom.equalToSuperview() // No inset at bottom so it attaches to cell
            make.leading.trailing.equalToSuperview().inset(12)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(16)
            make.leading.equalToSuperview().inset(16)
            make.trailing.equalTo(arrowImageView.snp.leading).offset(-8)
        }
        
        arrowImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(16)
            make.width.height.equalTo(20)
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        containerView.addGestureRecognizer(tap)
    }
    
    @objc private func handleTap() {
        delegate?.headerTapped(section: section)
    }
    
    func configure(title: String, section: Int, isExpanded: Bool) {
        self.titleLabel.text = title
        self.section = section
        
        UIView.animate(withDuration: 0.25) {
            self.arrowImageView.transform = isExpanded ? CGAffineTransform(rotationAngle: .pi) : .identity
        }
        
        if isExpanded {
            containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else {
            containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
    }
}
