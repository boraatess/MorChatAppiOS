//
//  ProfileCell.swift
//  MorChatApp
//
//  Created by bora ateş on 12.02.2026.
//

import Foundation
import UIKit
import SnapKit

final class ProfileCell: UITableViewCell {

    static let identifier = "ProfileCell"
    
    private let containerView = UIView()
    private let nameLabel = UILabel()
    
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

    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear

        containerView.backgroundColor = UIColor(red: 0.16, green: 0.08, blue: 0.28, alpha: 1.0)
        containerView.layer.cornerRadius = 12
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor(red: 0.35, green: 0.2, blue: 0.5, alpha: 1.0).cgColor

        contentView.addSubview(containerView)
        containerView.addSubview(nameLabel)
        containerView.addSubview(interestsScrollView)
        interestsScrollView.addSubview(interestsStack)

        containerView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(4)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        nameLabel.font = .boldSystemFont(ofSize: 20)
        nameLabel.textColor = .white
        nameLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }

        interestsScrollView.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(32)
            make.bottom.equalToSuperview().offset(-16)
        }
        
        interestsStack.snp.makeConstraints { make in
            make.edges.equalTo(interestsScrollView.contentLayoutGuide)
            make.height.equalTo(interestsScrollView.frameLayoutGuide)
        }
    }

    func configure(with name: String, tags: [InterestModel]) {
        nameLabel.text = name
        interestsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for tag in tags {
            let tagView = createTagPill(title: tag.name, icon: tag.icon, color: tag.color)
            interestsStack.addArrangedSubview(tagView)
        }
    }

    private func createTagPill(title: String, icon: String, color: UIColor) -> UIView {
        let v = UIView()
        v.backgroundColor = color
        v.layer.cornerRadius = 14
        
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 6
        stack.alignment = .center
        
        let iv = UIImageView(image: UIImage(systemName: icon))
        iv.tintColor = .white // Changed to white for better visibility on colored background
        iv.snp.makeConstraints { $0.size.equalTo(12) }
        
        let l = UILabel()
        l.text = title
        l.textColor = .white
        l.font = .systemFont(ofSize: 12, weight: .semibold)
        
        stack.addArrangedSubview(iv)
        stack.addArrangedSubview(l)
        v.addSubview(stack)
        stack.snp.makeConstraints { $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 4, left: 12, bottom: 4, right: 12)) }
        
        return v
    }
}
    
