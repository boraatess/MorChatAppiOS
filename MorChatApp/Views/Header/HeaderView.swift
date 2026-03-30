//
//  HeaderView.swift
//  MorChatApp
//
//  Created by bora ateş on 12.02.2026.
//

import Foundation
import UIKit
import SnapKit

protocol HeaderViewOutput: AnyObject {
    func didTapCoinButton()
}

final class HeaderView: UIView {

    weak var output: HeaderViewOutput?

    // MARK: - UI
    private let logoLabel: UILabel = {
        let label = UILabel()
        label.text = "MORCHAT"
        label.font = UIFont(name: "AvenirNext-Bold", size: 24) ?? .boldSystemFont(ofSize: 24)
        label.textColor = UIColor(red: 0.9, green: 0.3, blue: 0.5, alpha: 1)
        // Add letter spacing
        let attributedString = NSMutableAttributedString(string: "MORCHAT")
        attributedString.addAttribute(NSAttributedString.Key.kern, value: 1.5, range: NSRange(location: 0, length: attributedString.length))
        label.attributedText = attributedString
        return label
    }()

    private var coinButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "0 Tokens"
        config.baseBackgroundColor = UIColor(red: 0.35, green: 0.2, blue: 0.5, alpha: 1)
        config.baseForegroundColor = .white
        config.cornerStyle = .capsule
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 14, weight: .bold)
        config.image = UIImage(systemName: "arrow.triangle.2.circlepath.circle.fill", withConfiguration: symbolConfig)
        config.imagePlacement = .leading
        config.imagePadding = 6
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
        let button = UIButton(configuration: config)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
        return button
    }()

    private let plusIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "plus.circle.fill"))
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    // MARK: - Setup
    private func setupUI() {
        let userType = UserDefaults.standard.string(forKey: "userType") ?? "user"

        addSubview(logoLabel)
        addSubview(coinButton)
        coinButton.addSubview(plusIcon)
        coinButton.addTarget(self, action: #selector(coinTapped), for: .touchUpInside)
        
        if userType == "guide" {
            coinButton.isHidden = true
            plusIcon.isHidden = true
        }
        else {
            coinButton.isHidden = false
            plusIcon.isHidden = false
            
        }
    }

    private func setupConstraints() {
        logoLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(5)
            make.leading.equalToSuperview().offset(20)
        }
        coinButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(5)
            make.trailing.equalToSuperview().inset(20)
            make.height.equalTo(36)
        }
        plusIcon.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(5)
            make.trailing.equalToSuperview().inset(8)
            make.size.equalTo(20)
            make.leading.equalTo(coinButton.titleLabel!.snp.trailing).offset(12)
        }
        
    }

    // MARK: - Actions
    @objc private func coinTapped() {
        output?.didTapCoinButton()
    }

    // MARK: - Public Update
    func updateCoinAmount(_ amount: Int) {
        coinButton.configuration?.title = "\(amount) Tokens"
    }

    
}
