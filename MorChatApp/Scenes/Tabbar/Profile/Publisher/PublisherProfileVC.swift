//
//  PublisherProfileVC.swift
//  MorChatApp
//

import UIKit
import SnapKit
import FirebaseAuth
import SwiftUI

final class PublisherProfileVC: BaseVC {

    private let viewModel = PublisherProfileViewModel()

    private enum Section: Int, CaseIterable {
        case stories, gallery, interests, about, nickname, age, phone, notifications, email, menuGroup
        
        var title: String? {
            switch self {
            case .stories: return "My Stories"
            case .gallery: return "Gallery"
            case .interests: return "Interests / Tags"
            case .about: return "About Me"
            case .nickname: return "Nickname"
            case .age: return "Age"
            case .phone: return "Phone Number"
            case .notifications: return "Notification Permissions"
            case .email: return "E-mail"
            case .menuGroup: return nil
            }
        }
        
        var subtitle: String? {
            switch self {
            case .stories: return "You can manage your published stories here."
            case .gallery: return "You can manage photos that will appear on your profile here."
            case .interests: return "Tags indicating the subject of your broadcasts."
            case .about: return "A short text introducing yourself."
            case .notifications: return "If off, you may miss broadcast requests."
            default: return nil
            }
        }
    }

    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        tv.showsVerticalScrollIndicator = false
        tv.delegate = self
        tv.dataSource = self
        tv.register(ProfileSectionCell.self, forCellReuseIdentifier: ProfileSectionCell.identifier)
        tv.register(ProfileMenuCell.self, forCellReuseIdentifier: ProfileMenuCell.identifier)
        return tv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.44, green: 0.20, blue: 0.55, alpha: 1.0)
        setupUI()
        viewModel.output = self
        viewModel.fetchProfile()
    }
    
    private func setupUI() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(8)
            make.leading.trailing.bottom.equalToSuperview()
        }
        let header = PublisherProfileHeaderView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 200))
        header.delegate = self
        tableView.tableHeaderView = header
        setupLogoutFooter()
    }
    
    private func setupLogoutFooter() {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 120))
        let logoutButton = UIButton(type: .system)
        var config = UIButton.Configuration.filled()
        config.title = "profile_logout".localized
        config.image = UIImage(systemName: "rectangle.portrait.and.arrow.right")
        config.imagePadding = 8
        config.baseBackgroundColor = UIColor(red: 0.18, green: 0.12, blue: 0.30, alpha: 1.0)
        config.baseForegroundColor = .orange
        config.cornerStyle = .medium
        logoutButton.configuration = config
        logoutButton.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
        footerView.addSubview(logoutButton)
        logoutButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(160)
            make.height.equalTo(44)
        }
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
        FirebaseAuthService.shared.signOut()
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController = BaseNavigationController(rootViewController: LoginViewController())
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
        }
    }
}

// MARK: - ViewModel Output
extension PublisherProfileVC: PublisherProfileOutputProtocol {
    func didUpdateProfile() {
        DispatchQueue.main.async {
            if let header = self.tableView.tableHeaderView as? PublisherProfileHeaderView {
                header.setProfileImage(url: self.viewModel.currentPublisher?.profilePic)
            }
            self.tableView.reloadData()
        }
    }
    
    func didUpdateLoading(isLoading: Bool) {
        DispatchQueue.main.async {
            isLoading ? self.showLoading() : self.hideLoading()
        }
    }
    
    func didFailWithError(message: String) {
        DispatchQueue.main.async {
            self.showAlert(title: "Hata", message: message)
        }
    }
}

// MARK: - TableView
extension PublisherProfileVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let s = Section(rawValue: section) else { return 0 }
        if s == .menuGroup { return 2 }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = Section(rawValue: indexPath.section) else { return UITableViewCell() }
        
        if section == .menuGroup {
            let cell = tableView.dequeueReusableCell(withIdentifier: ProfileMenuCell.identifier, for: indexPath) as! ProfileMenuCell
            let container = UIView()
            container.backgroundColor = UIColor(red: 0.18, green: 0.12, blue: 0.30, alpha: 1.0)
            cell.contentView.insertSubview(container, at: 0)
            container.snp.makeConstraints { make in
                make.leading.trailing.equalToSuperview().inset(16)
                make.top.bottom.equalToSuperview()
            }
            if indexPath.row == 0 {
                container.layer.cornerRadius = 10
                container.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
                cell.configure(title: "App Rules", icon: "eye.circle", showSeparator: true)
            } else {
                container.layer.cornerRadius = 10
                container.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
                cell.configure(title: "Settings", icon: "gearshape", showSeparator: false)
            }
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ProfileSectionCell.identifier, for: indexPath) as! ProfileSectionCell
        var content = ""
        var tags: [String]? = nil
        var btnTitle: String? = "Edit"
        var btnHidden = false
        
        let pub = viewModel.currentPublisher
        
        switch section {
        case .nickname: content = pub?.name ?? ""
        case .age: content = "\(pub?.age ?? 0)"
        case .email:
            content = pub?.email ?? ""
            btnHidden = true
        case .phone: content = pub?.phoneNumber ?? "Not added"
        case .about: content = pub?.about ?? ""
        case .interests:
            tags = viewModel.selectedInterests.map { $0.name }
        case .notifications: 
            content = "On"
            btnTitle = "Turn Off"
        default: break
        }
        
        cell.configure(title: section.title ?? "", subtitle: section.subtitle, content: content, tags: tags, buttonTitle: btnTitle, isButtonHidden: btnHidden)
        cell.onEditTapped = { [weak self] in self?.handleEdit(section) }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = Section(rawValue: indexPath.section) else { return }
        if section == .menuGroup {
            if indexPath.row == 0 {
                navigationController?.pushViewController(AppRulesViewController(), animated: true)
            } else {
                navigationController?.pushViewController(SettingsViewController(), animated: true)
            }
        }
    }
    
    private func handleEdit(_ section: Section) {
        let pub = viewModel.currentPublisher
        switch section {
        case .interests:
            let vc = InterestsSelectionViewController(currentInterests: viewModel.selectedInterests)
            vc.delegate = self
            present(vc, animated: true)
        case .nickname:
            presentEditSheet(for: .nickname, value: pub?.name ?? "")
        case .age:
            presentEditSheet(for: .age, value: "\(pub?.age ?? 0)")
        case .about:
            presentEditSheet(for: .about, value: pub?.about ?? "")
        case .phone:
            presentEditSheet(for: .phone, value: pub?.phoneNumber ?? "")
        default: break
        }
    }
    
    private func presentEditSheet(for type: PublisherEditType, value: String) {
        let vc = PublisherEditValueVC(type: type, currentValue: value)
        vc.delegate = self
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
        }
        present(vc, animated: true)
    }
}

// MARK: - Edit Delegate
extension PublisherProfileVC: PublisherEditValueDelegate {
    func didUpdateValue(type: PublisherEditType, value: String) {
        switch type {
        case .nickname: viewModel.saveProfile(name: value, about: nil, age: nil, phone: nil)
        case .about: viewModel.saveProfile(name: nil, about: value, age: nil, phone: nil)
        case .age: viewModel.saveProfile(name: nil, about: nil, age: Int(value), phone: nil)
        case .phone: viewModel.saveProfile(name: nil, about: nil, age: nil, phone: value)
        }
    }
}

// MARK: - Header & Picker Extensions
extension PublisherProfileVC: PublisherProfileHeaderViewDelegate {
    func publisherHeaderDidTapPhoto() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }
    func publisherHeaderDidTapAddStory() { print("Add Story tapped") }
}

extension PublisherProfileVC: InterestsSelectionDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func didUpdateInterests(_ tags: [InterestModel]) {
        viewModel.updateInterests(tags)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        if let img = info[.originalImage] as? UIImage {
            viewModel.uploadProfileImage(img)
        }
    }
}
