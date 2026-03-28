//
//  SubHeaderView.swift
//  MorChatApp
//
//  Created by bora ateş.
//

import UIKit
import SnapKit

final class SubHeaderView: UIView {
    
    private let stackView = UIStackView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let bottomLine = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupUI() {
        backgroundColor = .clear
        
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.alignment = .leading
        
        titleLabel.font = .boldSystemFont(ofSize: 22)
        titleLabel.textColor = .white
        titleLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        
        subtitleLabel.font = .systemFont(ofSize: 14)
        subtitleLabel.textColor = .white
        subtitleLabel.numberOfLines = 1
        subtitleLabel.setContentHuggingPriority(.defaultLow, for: .vertical)
        subtitleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        
        bottomLine.backgroundColor = UIColor.white.withAlphaComponent(0.1) // İnce soluk çizgi
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitleLabel)
        
        addSubview(stackView)
        addSubview(bottomLine)
        
        stackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(bottomLine.snp.top).offset(-12)
        }
        
        bottomLine.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
    }
    
    func configure(title: String, subtitle: String) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
    }
    
    func updateSubtitle(_ text: String) {
        subtitleLabel.text = text
    }
}
