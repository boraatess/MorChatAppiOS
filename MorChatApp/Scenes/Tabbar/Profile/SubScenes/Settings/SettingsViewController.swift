//
//  SettingsViewController.swift
//  MorChatApp
//
//  Created by bora ateş on 12.02.2026.
//

import Foundation
import UIKit
import SnapKit


final class SettingsViewController: UIViewController {
    
    private let tableView = UITableView(frame: .zero, style: .grouped)
    private var items: [SettingItem] = []
    let viewModel = SettingsViewModel()
    private let profileHeader = ProfileHeaderView()
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileHeader.delegate = self
        viewModel.output = self
        viewModel.fetchItems()
        setupUI()
    }
    
    private func setupUI() {
        title = "menu_settings".localized
        view.backgroundColor = .white
        
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
        
        profileHeader.configure(with: "menu_settings".localized, image: "")
        
        tableView.register(SettingTableViewCell.self,
                           forCellReuseIdentifier: SettingTableViewCell.identifier)
        
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
    }    
    
}

extension SettingsViewController: ProfileHeaderViewDelegate {
    func didTapBack() {
        self.navigationController?.popViewController(animated: true)
        
    }
}

extension SettingsViewController: SettingsViewOutputProtocol {
    func configureItems(_ items: [SettingItem]) {
        self.items = items
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
}

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        items.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: SettingTableViewCell.identifier,
            for: indexPath
        ) as! SettingTableViewCell
        
        cell.configure(with: items[indexPath.row])
        
        cell.toggleChanged = { isOn in
            print("Switch changed:", isOn)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        
        let item = items[indexPath.row]
        
        switch item.type {
        case .normal:
            print("Navigate to document")
            
            let docUrl = item.docUrl
            let screenTitle = item.title
            if docUrl != "" {
                let vc = TermsWebViewController(urlString: docUrl, pageTitle: screenTitle)
                self.navigationController?.pushViewController(vc, animated: true)
                
            }
            
        case .toggle:
            break
        }
    }
}
