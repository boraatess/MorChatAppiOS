//
//  TokenCardView.swift
//  MorChatApp
//
//  Created by bora ateş on 12.02.2026.
//

import Foundation
import UIKit
import SnapKit

final class TokenCardView: UIView {

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

        let title = UILabel()
        title.text = "Mevcut Jetonlar"
        title.font = .boldSystemFont(ofSize: 20)
        title.textColor = .white

        let desc = UILabel()
        desc.text = "Hiç jeton kalmadı. Hemen yükle ve sohbete kaldığın yerden devam et."
        desc.textColor = .lightGray
        desc.numberOfLines = 0

        let button = UIButton()
        button.setTitle("Jeton Satın Al", for: .normal)
        button.backgroundColor = .systemPink
        button.layer.cornerRadius = 14

        addSubview(title)
        addSubview(desc)
        addSubview(button)

        title.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(20)
        }

        desc.snp.makeConstraints { make in
            make.top.equalTo(title.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        button.snp.makeConstraints { make in
            make.top.equalTo(desc.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
            make.bottom.equalToSuperview().offset(-20)
        }
    }
}
