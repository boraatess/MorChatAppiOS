//
//  AppRulesViewController.swift
//  MorChatApp
//
//  Created by bora ateş on 12.02.2026.
//

import Foundation
import UIKit
import SnapKit

struct RuleItem {
    let icon: UIImage?
    let iconBackgroundColor: UIColor
    let title: String
    let message: String
    let containerColor: UIColor
}

final class AppRulesViewController: UIViewController {
    
    private let tableView = UITableView(frame: .zero, style: .plain)
    
    private var rules: [RuleItem] = []
    
    let viewModel = AppRulesViewModel()
    
    private let profileHeader = ProfileHeaderView()
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileHeader.delegate = self
        viewModel.output = self
        viewModel.fetchRuleItems()
        setupUI()
    }
    
    private func setupUI() {
        
        title = "menu_rules".localized
        view.backgroundColor = UIColor.systemGroupedBackground
        
        view.addSubview(profileHeader)

        profileHeader.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(30)
            
        }
        
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(profileHeader.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
            
        }

        profileHeader.configure(with: "menu_rules".localized, image: "")

        tableView.register(AppRulesCell.self,
                           forCellReuseIdentifier: AppRulesCell.identifier)
        
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
    }
    
}

extension AppRulesViewController: ProfileHeaderViewDelegate {
    func didTapBack() {
        self.navigationController?.popViewController(animated: true)
        
    }
    
}

extension AppRulesViewController: AppRulesViewModelOutputprotocol {
    
    func configureRuleItems(_ items: [RuleItem]) {
        self.rules = items
        DispatchQueue.main.async {
            self.tableView.reloadData()
            
        }
        
    }
    
}

extension AppRulesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        rules.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: AppRulesCell.identifier,
            for: indexPath
        ) as! AppRulesCell
        
        cell.configure(with: rules[indexPath.row])
        return cell
    }
}
