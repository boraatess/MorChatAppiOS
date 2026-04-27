//
//  MenuContainerView.swift
//  MorChatApp
//
//  Created by bora ateş on 12.02.2026.
//

import Foundation
import UIKit
import SnapKit


final class MenuContainerView: UIView {

    private let stack = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {

        backgroundColor = UIColor.white.withAlphaComponent(0.08)
        layer.cornerRadius = 20

        stack.axis = .vertical
        stack.spacing = 0

        addSubview(stack)

        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        addRow(title: "menu_interests".localized)
        addRow(title: "menu_rules".localized)
        addRow(title: "menu_blocked".localized)
        addRow(title: "menu_settings".localized)
        addRow(title: "menu_help".localized)
    }

    private func addRow(title: String) {
        // let row = MenuRowView(title: title)
        // stack.addArrangedSubview(row)
        
    }
}
