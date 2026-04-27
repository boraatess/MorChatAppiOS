//
//  SettingsViewController.swift
//  MorChatApp
//
//  Created by bora ateş on 12.02.2026.
//

import Foundation
import UIKit
import SnapKit
import SwiftUI

final class SettingsViewController: UIViewController {
    
    private let tableView = UITableView(frame: .zero, style: .grouped)
    private var items: [SettingItem] = []
    private var sectionSettings: [SectionSettings] = []
    let viewModel = SettingsViewModel()
    private let profileHeader = ProfileHeaderView()
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        viewModel.fetchItems()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileHeader.delegate = self
        viewModel.output = self
        viewModel.fetchItems()
        setupUI()
        
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(languageChanged), name: .languageChanged, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func languageChanged() {
        setupUI()
        viewModel.fetchItems()
    }
    
    @objc private func appWillEnterForeground() {
        viewModel.fetchItems()
    }
    
    private func setupUI() {
        title = "menu_settings".localized
        view.backgroundColor = .white
        
        view.addSubview(profileHeader)
        profileHeader.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(50)
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
    
    func configureSectionItems(_ items: [SectionSettings]) {
        self.sectionSettings = items
        DispatchQueue.main.async {
            self.tableView.reloadData()
            
        }
    }
    
    func configureItems(_ items: [SettingItem]) {
        self.items = items
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
}

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionSettings.count
    }
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return sectionSettings[section].items.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: SettingTableViewCell.identifier,
            for: indexPath
        ) as! SettingTableViewCell
        
        let item = sectionSettings[indexPath.section].items[indexPath.row]
        
        cell.configure(with: item)
                
        cell.toggleChanged = { isOn in
            if indexPath.section == 0 && indexPath.row == 0 {
                // iOS 16.6 olduğu için doğrudan bildirim ayarlarını açabiliriz
                if let url = URL(string: UIApplication.openNotificationSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 40))
        headerView.backgroundColor = .clear
        
        let label = UILabel(frame: CGRect(x: 16, y: 16, width: headerView.frame.width, height: 20))
        label.textColor = .black
        label.numberOfLines = 0
        
        let section = sectionSettings[section]
        label.text = section.title
        label.font = .boldSystemFont(ofSize: 20)
        headerView.addSubview(label)
    
        return headerView
    }
 
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let section = sectionSettings[indexPath.section]
        let item = section.items[indexPath.row]
        
        switch item.type {
        case .normal:
            let docUrl = item.docUrl
            let screenTitle = item.title
            if docUrl != "" {
                let vc = TermsWebViewController(urlString: docUrl, pageTitle: screenTitle)
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
        case .actionSheet:
            showLanguageSelection()
            
        case .toggle:
            break
        }
    }
    
    private func showLanguageSelection() {
        let alert = UIAlertController(title: "Language", message: nil, preferredStyle: .actionSheet)
        
        // Derleyici hatasını önlemek için tipi açıkça belirtiyoruz
        let languages: [(name: String, code: String)] = [
            ("Türkçe", "tr"),
            ("English", "en"),
            ("Français", "fr"),
            ("Deutsch", "de"),
            ("Italiano", "it")
        ]
        
        for (name, code) in languages {
            alert.addAction(UIAlertAction(title: name, style: .default, handler: { _ in
                LocalizationManager.shared.currentLanguage = code
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
}

#Preview {
    let vc = SettingsViewController()
    return UINavigationController(rootViewController: vc).asPreview()
}
