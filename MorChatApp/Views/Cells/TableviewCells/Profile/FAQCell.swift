//
//  FAQCell.swift
//  MorChatApp
//
//  Created by bora ateş on 12.02.2026.
//

import Foundation
import UIKit
import SnapKit


final class FAQTableViewCell: UITableViewCell {
    
    static let identifier = "FAQTableViewCell"
    
    private let containerView = UIView()
    private let questionLabel = UILabel()
    private let arrowImageView = UIImageView()
    private let answerLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        
        contentView.addSubview(containerView)
        containerView.addSubview(questionLabel)
        containerView.addSubview(arrowImageView)
        containerView.addSubview(answerLabel)
        
        containerView.layer.cornerRadius = 16
        containerView.backgroundColor = .systemBackground
        
        questionLabel.font = .systemFont(ofSize: 18, weight: .bold)
        questionLabel.numberOfLines = 0
        
        arrowImageView.image = UIImage(systemName: "chevron.down")
        arrowImageView.tintColor = .black
        arrowImageView.contentMode = .scaleAspectFit
        
        answerLabel.font = .systemFont(ofSize: 16)
        answerLabel.textColor = .gray
        answerLabel.numberOfLines = 0
        answerLabel.isHidden = true
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(12)
        }
        
        arrowImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.right.equalToSuperview().offset(-16)
            $0.width.height.equalTo(20)
        }
        
        questionLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.left.equalToSuperview().offset(16)
            $0.right.equalTo(arrowImageView.snp.left).offset(-8)
        }
        
        answerLabel.snp.makeConstraints {
            $0.top.equalTo(questionLabel.snp.bottom).offset(12)
            $0.left.right.equalTo(questionLabel)
            $0.bottom.equalToSuperview().offset(-16)
        }
    }
    
    func configure(with item: FAQItem) {
        questionLabel.text = item.question
        answerLabel.text = item.answer
        answerLabel.isHidden = !item.isExpanded
        
        UIView.animate(withDuration: 0.25) {
            self.arrowImageView.transform = item.isExpanded ?
                CGAffineTransform(rotationAngle: .pi) :
                .identity
        }
    }
}
