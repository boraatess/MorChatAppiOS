//
//  ProfileViewController.swift
//  MorChatApp
//
//  Created by bora ateş on 21.01.2026.
//

import UIKit
import SnapKit
import FirebaseAuth
import FirebaseCore
import SwiftUI

final class ProfileViewController: BaseVC {

    private let viewModel = ProfileViewModel()

    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .grouped)
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        tv.showsVerticalScrollIndicator = false
        tv.delegate = self
        tv.dataSource = self
        tv.separatorStyle = .singleLine
       // tv.separatorInset = UIEdgeInsets(top: 0, left: 60, bottom: 0, right: 16)
        tv.backgroundColor = .clear
        tv.contentInset = .zero
        tv.rowHeight = UITableView.automaticDimension
        tv.estimatedRowHeight = 100
        
        tv.register(ProfileCell.self, forCellReuseIdentifier: ProfileCell.identifier)
        tv.register(TokenCell.self, forCellReuseIdentifier: TokenCell.identifier)
        tv.register(FreeTokenCell.self, forCellReuseIdentifier: FreeTokenCell.identifier)
        tv.register(MenuCell.self, forCellReuseIdentifier: MenuCell.identifier)

        return tv
    }()
    
    private let subHeaderView = SubHeaderView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(red: 0.44, green: 0.20, blue: 0.55, alpha: 1.0)
        
        viewModel.output = self
        setupUI()
        setupFooter()

        let header = ProfileTableHeaderView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 120))
        header.delegate = self
        tableView.tableHeaderView = header
        
        viewModel.fetchData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        updateHeader()
    }
    
    
    
    private func updateHeader() {
        guard let header = tableView.tableHeaderView as? ProfileTableHeaderView,
              let user = viewModel.currentUser else { return }
        
        header.setProfileImage(url: user.photoURL)
        
        
        // header.configure(with: user.name ?? "User", tags: selectedInterests)
        
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    private func setupFooter() {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 100))
        
        var config = UIButton.Configuration.filled()
        config.title = "profile_logout".localized
        config.baseBackgroundColor = UIColor(red: 0.16, green: 0.08, blue: 0.28, alpha: 1.0)
        config.baseForegroundColor = .red
        config.cornerStyle = .medium
        
        config.image = UIImage(systemName: "rectangle.portrait.and.arrow.right")
        config.imagePlacement = .leading
        config.imagePadding = 8
        
        let logoutButton = UIButton(configuration: config)
        logoutButton.layer.borderWidth = 1
        logoutButton.layer.borderColor = UIColor.red.withAlphaComponent(0.5).cgColor

        
        footerView.addSubview(logoutButton)
        logoutButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(150)
            make.height.equalTo(45)
        }
        
        logoutButton.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
        
        tableView.tableFooterView = footerView
    }
    
    @objc private func logoutTapped() {
        let alert = UIAlertController(title: "profile_logout_alert_title".localized, message: "profile_logout_alert_message".localized, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "profile_logout_cancel".localized, style: .cancel)
        let logoutAction = UIAlertAction(title: "profile_logout".localized, style: .destructive) { [weak self] _ in
            self?.performLogout()
        }
        
        alert.addAction(cancelAction)
        alert.addAction(logoutAction)
        
        present(alert, animated: true)
    }
    
    private func performLogout() {
        viewModel.logout()
    }

    private func goToScene(_ vc: UIViewController) {
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func setupUI() {
        
        view.addSubview(subHeaderView)

        subHeaderView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            
        }
        
        subHeaderView.configure(title: "profile_title".localized, subtitle: "profile_subtitle".localized)
        
        view.addSubview(tableView)

        tableView.snp.makeConstraints { make in
            make.top.equalTo(subHeaderView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
}

extension ProfileViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return AccountSection.allCases.count
    }

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {

        guard let section = AccountSection(rawValue: section) else { return 0 }

        switch section {
        case .menu:
            return AccountMenuItem.allCases.count
        default:
            return 1
        }
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let section = AccountSection(rawValue: indexPath.section) else {
            return UITableViewCell()
        }

        switch section {

        case .profile:
            let cell =  tableView.dequeueReusableCell(withIdentifier: ProfileCell.identifier, for: indexPath) as! ProfileCell
            let name = viewModel.currentUser?.name ?? "profile_loading".localized
            cell.configure(with: name, tags: viewModel.selectedInterests)
            
            return cell

        case .tokens:
            let cell = tableView.dequeueReusableCell(withIdentifier: TokenCell.identifier, for: indexPath) as! TokenCell
            cell.output = self
            let coins = viewModel.currentUser?.creditCount ?? 0
            cell.configure(coins: coins)
            
            return cell
            
        case .freeToken:
            return tableView.dequeueReusableCell(withIdentifier: FreeTokenCell.identifier, for: indexPath) as! FreeTokenCell

        case .menu:
            let cell = tableView.dequeueReusableCell(withIdentifier: MenuCell.identifier, for: indexPath) as! MenuCell
            let item = AccountMenuItem.allCases[indexPath.row]
            
            // Note: AccountMenuItem.title should probably be updated too, 
            // but for now we apply it here or update the Model
            cell.configure(with: item)
            
            return cell
        }
    }
    
}

extension ProfileViewController: tokenCellOutputDelegate {
    
    func buyToken() {
        let vc = BuyTokenViewController()
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension ProfileViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: true)

        guard let section = AccountSection(rawValue: indexPath.section) else { return }

        if section == .freeToken {
            print("🎬 Rewarded Ad requested...")
            CoinManager.shared.showRewardedAd(from: self) { [weak self] success in
                if success {
                    print("💎 User earned tokens from ad!")
                    DispatchQueue.main.async {
                        self?.viewModel.fetchData() // Refresh coin balance
                        self?.showAlert(title: "Tebrikler! 💎", message: "Ödüllü reklamı izlediğiniz için hesabınıza jeton eklendi. Keyifli sohbetler dileriz!")
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.showAlert(title: "Hata", message: "Reklam şu an yüklenemedi veya yarıda kesildi. Lütfen daha sonra tekrar deneyin.")
                    }
                }
            }
            return
        }

        guard section == .menu else { return }

        let item = AccountMenuItem.allCases[indexPath.row]

        switch item {
        case .interests:
            let vc = InterestsSelectionViewController(currentInterests: viewModel.selectedInterests)
            vc.delegate = self
            if let sheet = vc.sheetPresentationController {
                sheet.detents = [.large()]
                sheet.prefersGrabberVisible = true
            }
            present(vc, animated: true)
        case .rules:
            print("Rules")
            let vc = AppRulesViewController()
            self.goToScene(vc)
            
        case .blocked:
            print("Blocked")
            let vc = BlockedUsersVC()
            self.goToScene(vc)
        case .settings:
            print("Settings")
            let vc = SettingsViewController()
            self.goToScene(vc)

        case .help:
            print("Help")
            let vc = SupportViewController()
            self.goToScene(vc)
            
            
        }
    }

    func tableView(_ tableView: UITableView,
                   heightForHeaderInSection section: Int) -> CGFloat {
        return 8
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
}

extension ProfileViewController: InterestsSelectionDelegate {
    func didUpdateInterests(_ tags: [InterestModel]) {
        viewModel.updateInterests(tags)
    }
}

extension ProfileViewController: ProfileTableHeaderViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func profileHeaderDidTapPhoto() {
        showImageSourceOptions()
    }
    
    private func showImageSourceOptions() {
        let alert = UIAlertController(title: "photo_select_title".localized, message: "photo_select_message".localized, preferredStyle: .actionSheet)
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: "photo_source_camera".localized, style: .default) { _ in
                self.openImagePicker(sourceType: .camera)
            })
        }
        alert.addAction(UIAlertAction(title: "photo_source_gallery".localized, style: .default) { _ in
            self.openImagePicker(sourceType: .photoLibrary)
        })
        alert.addAction(UIAlertAction(title: "photo_cancel".localized, style: .cancel))
        present(alert, animated: true)
    }

    private func openImagePicker(sourceType: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = sourceType
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true) 
        
        guard let editedImage = (info[.editedImage] as? UIImage) ?? (info[.originalImage] as? UIImage) else { return }
        
        viewModel.uploadPhoto(editedImage)
    }
}

// MARK: - ViewModel Output
extension ProfileViewController: ProfileViewModelOutput {
    func didFetchUser(_ user: UserModel) {
        tableView.reloadData()
        updateHeader()
    }
    
    func didUpdateInterests() {
        tableView.reloadData()
        // No alert needed, just UI update
    }
    
    func didUpdatePhoto(url: String) {
        if let header = self.tableView.tableHeaderView as? ProfileTableHeaderView {
            header.setProfileImage(url: url)
        }
        self.showAlert(title: "photo_success".localized, message: "photo_update_success".localized)
    }
    
    func didFail(with error: String) {
        self.showAlert(title: "photo_error".localized, message: error)
    }
    
    func setLoader(isVisible: Bool) {
        if isVisible {
            showLoading()
        } else {
            hideLoading()
        }
    }
    
    func didLogout() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            let loginVC = LoginViewController()
            let nav = BaseNavigationController(rootViewController: loginVC)
            window.rootViewController = nav
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
        }
    }
}

#Preview {
    ProfileViewController().asPreview()
    
}

