import UIKit
import SnapKit

final class ProfileMenuCell: UITableViewCell {
    
    static let identifier = "ProfileMenuCell"
    
    private let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.backgroundColor = .clear
        return view
    }()
    
    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.textColor = .white
        l.font = .systemFont(ofSize: 16, weight: .medium)
        return l
    }()
    
    private let arrowImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "chevron.right"))
        iv.tintColor = UIColor.white.withAlphaComponent(0.5)
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private let separatorView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        return v
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    /*     contentView.addSubview(containerView)
     
     containerView.snp.makeConstraints { make in
         make.top.equalToSuperview().offset(4)
         make.leading.equalToSuperview().offset(4)
         make.trailing.equalToSuperview().inset(4)
         make.bottom.equalToSuperview().inset(4)
     }
     
     containerView.addSubview(iconImageView)
     containerView.addSubview(titleLabel)
     containerView.addSubview(arrowImageView)
     containerView.addSubview(separatorView)
     
     */
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(arrowImageView)
        contentView.addSubview(separatorView)
        
        iconImageView.snp.makeConstraints { make in
            make.leading.equalTo(contentView.safeAreaLayoutGuide).offset(20)
            make.centerY.equalToSuperview()
            make.size.equalTo(24)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconImageView.snp.trailing).offset(10)
            make.centerY.equalToSuperview()
        }
        
        arrowImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
            make.size.equalTo(14)
        }
        
        separatorView.snp.makeConstraints { make in
            make.leading.equalTo(contentView.safeAreaLayoutGuide)
            make.trailing.equalTo(contentView.safeAreaLayoutGuide)
            make.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
        
    }
    
    func configure(title: String, icon: String, showSeparator: Bool) {
        titleLabel.text = title
        iconImageView.image = UIImage(systemName: icon)
        separatorView.isHidden = !showSeparator
        
    }
}
