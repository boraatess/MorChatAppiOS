//
//  PublisherProfileVC.swift
//  MorChatApp
//
//  Created by bora ateş on 29.03.2026.
//

import Foundation
import UIKit

import UIKit
import SnapKit
import FirebaseAuth

final class PublisherProfileVC: BaseVC {

    private var selectedInterests: [InterestModel] = []
    private var currentUser: UserModel?

    private enum Section: Int, CaseIterable {
        case stories, gallery, interests, about, nickname, phone, notifications, email, menuGroup
        
        var title: String? {
            switch self {
            case .stories: return "My Stories"
            case .gallery: return "Gallery"
            case .interests: return "Interests / Tags"
            case .about: return "About Me"
            case .nickname: return "Nickname / Age"
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
    
    // Header Logo "MORCHAT"
    private let logoLabel: UILabel = {
        let l = UILabel()
        l.text = "MORCHAT"
        l.textColor = .systemPink
        l.font = .systemFont(ofSize: 22, weight: .black)
        return l
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.44, green: 0.20, blue: 0.55, alpha: 1.0)
        setupUI()
        fetchProfile()
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
        config.title = "Log Out"
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
    
    private func fetchProfile() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        // Try to fetch as a regular watcher first
        FirestoreService.shared.fetchUserProfile(uid: uid) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let user):
                self.handleFetchedUser(user)
            case .failure(let error as NSError) where error.code == 404:
                // If not found in Watchers, try Publishers
                self.fetchAsPublisher(uidValue: uid)
            case .failure(let error):
                print("Error fetching profile: \(error)")
            }
        }
    }
    
    private func fetchAsPublisher(uidValue: String) {
        FirestoreService.shared.fetchPublisherProfile(publisherId: uidValue) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let pub):
                // Map PublisherProfile to UserModel for consistent UI handling
                let mappedUser = UserModel(
                    uid: pub.id ?? uidValue,
                    name: pub.name,
                    email: pub.email,
                    photoURL: pub.profilePic,
                    createdAt: pub.last_seen ?? Date(),
                    interests: [], // We'll compute tags next
                    tagList: pub.tagList ?? [],
                    age: pub.age ?? 0,
                    status: pub.status ?? "Offline"
                )
                self.handleFetchedUser(mappedUser)
            case .failure(let error):
                print("Error fetching as publisher: \(error)")
            }
        }
    }
    
    private func handleFetchedUser(_ user: UserModel) {
        self.currentUser = user
        
        // Fetch all tags first to ensure correct mapping
        FirestoreService.shared.fetchPublisherTags { [weak self] tagResult in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch tagResult {
                case .success(let allTags):
                    // Map user interests
                    if let remoteInterests = user.interests, !remoteInterests.isEmpty {
                        // Match by name
                        self.selectedInterests = remoteInterests.compactMap { name in
                            if let tag = allTags.first(where: { $0.name == name }) {
                                let ui = SharedTagsCloudView.defaultCategories.first(where: { $0.name == name })
                                return InterestModel(id: tag.id, name: tag.name, icon: ui?.icon ?? "number", color: ui?.color ?? .systemIndigo)
                            }
                            return nil
                        }
                    } else if let tagList = user.tagList {
                        // Match by ID
                        self.selectedInterests = tagList.compactMap { id in
                            if let tag = allTags.first(where: { $0.id == id }) {
                                let ui = SharedTagsCloudView.defaultCategories.first(where: { $0.name == tag.name })
                                return InterestModel(id: tag.id, name: tag.name, icon: ui?.icon ?? "number", color: ui?.color ?? .systemIndigo)
                            }
                            return nil
                        }
                    }
                    
                    self.tableView.reloadData()
                    
                case .failure(let error):
                    print("Error mapping tags: \(error)")
                    // Fallback to local default mapping if remote fails
                    self.tableView.reloadData()
                }
            }
        }
        
        if let header = self.tableView.tableHeaderView as? PublisherProfileHeaderView {
            header.setProfileImage(url: user.photoURL)
        }
        self.tableView.reloadData()
    }
}

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
            // Add rounding only to top and bottom of the group
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
        
        switch section {
        case .nickname: content = "\(currentUser?.name ?? "") / \(currentUser?.age ?? 0)"
        case .email: 
            content = currentUser?.email ?? ""
            btnHidden = true
        case .phone: content = "Not added"
        case .about: content = "Just chatting"
        case .interests:
            tags = selectedInterests.map { $0.name }
        case .notifications: 
            content = "On"
            btnTitle = "Turn Off"
        default: break
        }
        
        cell.configure(title: section.title ?? "", subtitle: section.subtitle, content: content, tags: tags, buttonTitle: btnTitle, isButtonHidden: btnHidden)
        
        cell.onEditTapped = { [weak self] in
            self?.handleEdit(section)
        }
        
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
        switch section {
        case .interests:
            let vc = InterestsSelectionViewController(currentInterests: selectedInterests)
            vc.delegate = self
            present(vc, animated: true)
            
        case .about, .nickname, .phone:
            showEditAlert(for: section)
            
        default:
            break
        }
    }
    
    private func showEditAlert(for section: Section) {
        let title = "Edit \(section.title ?? "")"
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        
        alert.addTextField { [weak self] tf in
            switch section {
            case .nickname: tf.text = self?.currentUser?.name
            case .about: tf.text = self?.currentUser?.status // Reusing status for 'About Me' in this context
            default: break
            }
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { [weak self] _ in
            guard let self = self, let text = alert.textFields?.first?.text, !text.isEmpty else { return }
            
            if var user = self.currentUser {
                switch section {
                case .nickname: user.name = text
                case .about: user.status = text
                default: break
                }
                
                self.currentUser = user
                self.tableView.reloadData()
                self.performSave(user: user)
            }
        }))
        
        present(alert, animated: true)
    }
    
    
    private func performSave(user: UserModel) {
        // 1. Save to UserWatcher (for filtering)
        FirestoreService.shared.saveUserProfile(user: user) { _ in }
        
        // 2. Save to PublisherProfile (for specific publisher data)
        let pub = PublisherProfile(
            id: user.uid,
            about: user.status, // Using status as about for now
            age: user.age,
            email: user.email,
            language: "tr", // Default
            last_seen: Date(),
            msgToken: nil,
            name: user.name,
            phoneNumber: nil,
            point: 0,
            profilePic: user.photoURL,
            status: user.status,
            interests: user.interests,
            tagList: user.tagList
        )
        FirestoreService.shared.savePublisherProfile(profile: pub) { _ in }
    }
}

extension PublisherProfileVC: PublisherProfileHeaderViewDelegate {
    
    func publisherHeaderDidTapPhoto() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }
    
    func publisherHeaderDidTapAddStory() {
        print("Add Story tapped")
    }
    
}

extension PublisherProfileVC: InterestsSelectionDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func didUpdateInterests(_ tags: [InterestModel]) {
        
        print("selected tags : \(tags)")
        
        self.selectedInterests = tags
        tableView.reloadData()
        
        if var user = currentUser {
            user.interests = tags.map { $0.name }
            user.tagList = tags.compactMap { t in SharedTagsCloudView.defaultCategories.firstIndex(where: { $0.name == t.name }) }
            self.currentUser = user
            self.performSave(user: user)
            
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let img = info[.originalImage] as? UIImage {
            if let header = self.tableView.tableHeaderView as? PublisherProfileHeaderView {
                header.setProfileImage(img)
            }
        }
        picker.dismiss(animated: true)
    }
}
