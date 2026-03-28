//
//  ProfileCardView.swift
//  MorChatApp
//
//  Created by bora ateş on 12.02.2026.
//

import Foundation
import UIKit
import SnapKit


final class ProfileCardView: UIView {

    private let nameLabel = UILabel()
    private let tagsStack = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {

        backgroundColor = UIColor.white.withAlphaComponent(0.08)
        layer.cornerRadius = 20
        layer.borderWidth = 1
        layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor

        nameLabel.text = "bora"
        nameLabel.font = .boldSystemFont(ofSize: 24)
        nameLabel.textColor = .white

        tagsStack.axis = .horizontal
        tagsStack.spacing = 8
        tagsStack.alignment = .leading
        tagsStack.distribution = .fillProportionally

        addSubview(nameLabel)
        addSubview(tagsStack)

        nameLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(20)
        }

        tagsStack.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-20)
        }

        addTag(title: "hayal", color: .systemPurple)
        addTag(title: "müzik", color: .systemBlue)
        addTag(title: "arabalar", color: .darkGray)
    }

    private func addTag(title: String, color: UIColor) {
        let label = PaddingLabel()
        label.text = "  \(title)  "
        label.backgroundColor = color
        label.textColor = .white
        label.layer.cornerRadius = 16
        label.clipsToBounds = true

        tagsStack.addArrangedSubview(label)
    }
}
