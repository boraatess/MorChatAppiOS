//
//  IconTextfield.swift
//  MorChatApp
//
//  Created by bora ateş on 9.02.2026.
//

import Foundation
import UIKit
import SnapKit


final class IconTextField: UIView {

    private let iconView = UIImageView()
    let textField = UITextField()

    init(icon: String, placeholder: String) {
        super.init(frame: .zero)
        setup(icon: icon, placeholder: placeholder)
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setup(icon: String, placeholder: String) {
        backgroundColor = UIColor.white.withAlphaComponent(0.95)
        layer.cornerRadius = 28

        iconView.image = UIImage(systemName: icon)
        iconView.tintColor = .gray

        textField.placeholder = placeholder
        textField.font = .systemFont(ofSize: 16)

        addSubview(iconView)
        addSubview(textField)

        iconView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(22)
        }

        textField.snp.makeConstraints {
            $0.leading.equalTo(iconView.snp.trailing).offset(12)
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalToSuperview()
        }
    }
}
