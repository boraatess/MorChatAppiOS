//
//  PublicationHistoryVC.swift
//  MorChatApp
//
//  Created by bora ateş on 29.03.2026.
//

import Foundation
import UIKit

import Foundation
import UIKit
import SnapKit
import SwiftUI

class PublicationHistoryVC: BaseVC {
    
    // UI Elements
    private let logoLabel: UILabel = {
        let label = UILabel()
        label.text = "MORCHAT"
        // Screenshot shows a bright pink text
        label.textColor = UIColor(red: 1.0, green: 0.35, blue: 0.55, alpha: 1.0)
        label.font = UIFont(name: "AvenirNext-Heavy", size: 24) ?? .systemFont(ofSize: 24, weight: .heavy)
        return label
    }()
    
    // Main Container
    private let mainContainer: UIView = {
        let view = UIView()
        // Dark purple/indigo base from the screenshot
        view.backgroundColor = UIColor(red: 0.14, green: 0.08, blue: 0.22, alpha: 0.95)
        view.layer.cornerRadius = 20
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor
        return view
    }()
    
    // "Total X broadcast days" Label
    private let totalDaysLabel: UILabel = {
        let label = UILabel()
        label.text = "Total 0 broadcast days"
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 14, weight: .medium)
        return label
    }()
    
    // Time Card
    private let timeCard = HistoryStatsCardView(iconName: "clock", title: "Total Time", value: "0 min 0 sec")
    
    // Audience Card
    private let audienceCard = HistoryStatsCardView(iconName: "person.2.fill", title: "Total Audience", value: "0")
    
    // "Broadcast List" header
    private let listHeaderView = UIView()
    private let listIconImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "clock.arrow.circlepath"))
        iv.tintColor = .lightGray
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    private let listTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Broadcast List"
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    // TableView for broadcasts
    private let tableView: UITableView = {
        let tv = UITableView()
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        return tv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Ensure gradient is correctly framed after layout
        if let gradient = view.layer.sublayers?.first as? CAGradientLayer {
            gradient.frame = view.bounds
        }
    }
    
    private func setupUI() {
        // Gradient background to match design
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(red: 0.39, green: 0.17, blue: 0.58, alpha: 1.0).cgColor,
            UIColor(red: 0.65, green: 0.25, blue: 0.70, alpha: 1.0).cgColor
        ]
        gradientLayer.frame = view.bounds
        view.layer.insertSublayer(gradientLayer, at: 0)
        
        // Hide standard base header view to give space
        headerView.isHidden = true
        
        view.addSubview(logoLabel)
        view.addSubview(mainContainer)
        
        logoLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.leading.equalToSuperview().offset(20)
        }
        
        mainContainer.snp.makeConstraints { make in
            make.top.equalTo(logoLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        mainContainer.addSubview(totalDaysLabel)
        
        let stackView = UIStackView(arrangedSubviews: [timeCard, audienceCard])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 16
        
        mainContainer.addSubview(stackView)
        mainContainer.addSubview(listHeaderView)
        
        listHeaderView.addSubview(listIconImageView)
        listHeaderView.addSubview(listTitleLabel)
        
        mainContainer.addSubview(tableView)
        
        totalDaysLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        // Horizontal cards
        stackView.snp.makeConstraints { make in
            make.top.equalTo(totalDaysLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(80)
        }
        
        // Broadcast List Header
        listHeaderView.snp.makeConstraints { make in
            make.top.equalTo(stackView.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(24)
        }
        
        listIconImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.height.equalTo(18)
        }
        
        listTitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(listIconImageView.snp.trailing).offset(10)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        
        // List rendering area
        tableView.snp.makeConstraints { make in
            make.top.equalTo(listHeaderView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

// Custom reusable card view specifically for the history screen
private class HistoryStatsCardView: UIView {
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let valueLabel = UILabel()
    
    init(iconName: String, title: String, value: String) {
        super.init(frame: .zero)
        
        // Slightly transparent white for glass effect
        backgroundColor = UIColor.white.withAlphaComponent(0.08)
        layer.cornerRadius = 12
        layer.borderWidth = 1
        layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor
        
        iconImageView.image = UIImage(systemName: iconName)
        iconImageView.tintColor = .lightGray
        iconImageView.contentMode = .scaleAspectFit
        
        titleLabel.text = title
        titleLabel.textColor = .lightGray
        titleLabel.font = .systemFont(ofSize: 12, weight: .medium)
        
        valueLabel.text = value
        valueLabel.textColor = .white
        valueLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        
        let headerStack = UIStackView(arrangedSubviews: [iconImageView, titleLabel])
        headerStack.axis = .horizontal
        headerStack.spacing = 6
        headerStack.alignment = .center
        
        addSubview(headerStack)
        addSubview(valueLabel)
        
        iconImageView.snp.makeConstraints { make in
            make.width.height.equalTo(14)
        }
        
        headerStack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.leading.equalToSuperview().offset(16)
            make.trailing.lessThanOrEqualToSuperview().inset(16)
        }
        
        valueLabel.snp.makeConstraints { make in
            make.top.equalTo(headerStack.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().inset(16)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Use this to dynamically update the stats text
    func updateValue(_ value: String) {
        valueLabel.text = value
    }
}



// MARK: - Preview
#Preview {
    PublicationHistoryVC().asPreview()
}

