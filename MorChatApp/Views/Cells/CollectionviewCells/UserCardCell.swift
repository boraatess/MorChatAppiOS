//
//  UserCardCell.swift
//  MorChatApp
//
//  Created by bora ateş on 12.02.2026.
//

import Foundation
import Kingfisher
import UIKit
import SnapKit


final class UserCardCell: UICollectionViewCell {
    
    // MARK: - UI
    static let identifier = "UserCardCell"

    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    private let gradientView = UIView()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 14, weight: .bold)
        return label
    }()
    
    private let statusPill: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(red: 1.0, green: 0.2, blue: 0.2, alpha: 0.6)
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

    private let tagsScrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsHorizontalScrollIndicator = false
        return sv
    }()
    
    private let tagsStack: UIStackView = {
        let s = UIStackView()
        s.axis = .horizontal
        s.spacing = 4
        return s
    }()
    
    private let gradientLayer = CAGradientLayer()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
        setupConstraints()
        setupGradient()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func configure(with model: UserCardModel) {
        if let age = model.age {
            nameLabel.text = "\(model.name) , \(age)"
        } else {
            nameLabel.text = model.name
        }
        
        let status = model.status ?? "Away"
        statusLabel.text = status
        if status == "Online" {
            statusPill.backgroundColor = UIColor(red: 0.1, green: 0.6, blue: 0.1, alpha: 0.6)
        } else {
            statusPill.backgroundColor = UIColor(red: 1.0, green: 0.2, blue: 0.2, alpha: 0.6)
        }
        
        // Clear old tags
        tagsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Add new tags
        for tagStr in model.tags {
            let container = UIView()
            container.backgroundColor = UIColor(white: 1.0, alpha: 0.3)
            container.layer.cornerRadius = 8
            
            let lbl = UILabel()
            lbl.text = tagStr
            lbl.textColor = UIColor(red: 1.0, green: 0.8, blue: 0.85, alpha: 1.0)
            lbl.font = .systemFont(ofSize: 9, weight: .semibold)
            
            container.addSubview(lbl)
            lbl.snp.makeConstraints { $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 2, left: 6, bottom: 2, right: 6)) }
            
            tagsStack.addArrangedSubview(container)
        }
        
        if let urlString = model.imageURL, let url = URL(string: urlString) {
            imageView.kf.setImage(with: url, placeholder: UIImage(systemName: "person.circle.fill"))
        } else {
            imageView.image = UIImage(systemName: "person.circle.fill")
        }
    }

    
    // MARK: - Setup
    private func setupUI() {
        contentView.layer.cornerRadius = 6
        contentView.clipsToBounds = true
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.25
        layer.shadowRadius = 8
        layer.shadowOffset = CGSize(width: 0, height: 4)
        
        contentView.addSubview(imageView)
        contentView.addSubview(gradientView)
        contentView.addSubview(nameLabel)
        
        statusPill.addSubview(statusLabel)
        contentView.addSubview(statusPill)
        
        tagsScrollView.addSubview(tagsStack)
        contentView.addSubview(tagsScrollView)
    }
    
    private func setupConstraints() {
        
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        gradientView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(80)
        }
        
        nameLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(12)
            $0.bottom.equalToSuperview().inset(34)
        }
        
        tagsScrollView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(12)
            $0.bottom.equalToSuperview().inset(10)
            $0.height.equalTo(20)
        }
        
        tagsStack.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        statusPill.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.trailing.equalToSuperview().inset(10)
            $0.height.equalTo(20)
            $0.width.greaterThanOrEqualTo(50)
        }
        
        statusLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(8)
        }
    }
    
    private func setupGradient() {
        gradientLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.75).cgColor
        ]
        gradientLayer.locations = [0.0, 1.0]
        gradientView.layer.addSublayer(gradientLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = gradientView.bounds
        layer.shadowPath = UIBezierPath(
            roundedRect: bounds,
            cornerRadius: 8
        ).cgPath
    }
}

