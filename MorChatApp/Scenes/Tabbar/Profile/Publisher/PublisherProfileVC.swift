
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
            case .stories: return "pub_prof_stories".localized
            case .gallery: return "pub_prof_gallery".localized
            case .interests: return "pub_prof_interests".localized
            case .about: return "pub_prof_about".localized
            case .nickname: return "pub_prof_nickname".localized
            case .age: return nil // Nickname ile birleştirildi
            case .phone: return "pub_prof_phone".localized
            case .notifications: return "pub_prof_notif".localized
            case .email: return "pub_prof_email".localized
            case .menuGroup: return nil
            }
        }
        
        var subtitle: String? {
            switch self {
            case .stories: return "pub_prof_stories_desc".localized
            case .gallery: return "pub_prof_gallery_desc".localized
            case .interests: return "pub_prof_interests_desc".localized
            case .about: return "pub_prof_about_desc".localized
            case .notifications: return "pub_prof_notif_desc".localized
            default: return nil
            }
        }
    }

    private enum PickerSource {
        case profile, gallery, story
    }
    private var pickerSource: PickerSource = .profile

    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        tv.showsVerticalScrollIndicator = false
        tv.delegate = self
        tv.dataSource = self
        tv.register(ProfileSectionCell.self, forCellReuseIdentifier: ProfileSectionCell.identifier)
        tv.register(ProfileMenuCell.self, forCellReuseIdentifier: ProfileMenuCell.identifier)
        tv.register(ProfileStoriesCell.self, forCellReuseIdentifier: ProfileStoriesCell.identifier)
        tv.register(ProfileGalleryCell.self, forCellReuseIdentifier: ProfileGalleryCell.identifier)
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
        let header = PublisherProfileHeaderView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 220))
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
        alert.addAction(UIAlertAction(title: "profile_logout_cancel".localized, style: .cancel))
        alert.addAction(UIAlertAction(title: "profile_logout".localized, style: .destructive) { [weak self] _ in
            self?.performLogout()
        })
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
    
    override func applyLocalization() {
        tableView.reloadData()
        setupLogoutFooter() // Footer metnini tazele
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
            self.showAlert(title: "pub_prof_error_title".localized, message: message)
        }
    }
}

// MARK: - TableView
extension PublisherProfileVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int { return Section.allCases.count }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let s = Section(rawValue: section) else { return 0 }
        if s == .age { return 0 } // Nickname ile birleşti
        if s == .menuGroup { return 2 }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = Section(rawValue: indexPath.section) else { return UITableViewCell() }
        
        switch section {
        case .stories:
            let cell = tableView.dequeueReusableCell(withIdentifier: ProfileStoriesCell.identifier, for: indexPath) as! ProfileStoriesCell
            let pub = viewModel.currentPublisher
            cell.configure(title: section.title ?? "", subtitle: section.subtitle, stories: pub?.stories, profilePic: pub?.profilePic)
            cell.onStorySelected = { [weak self] in
                guard let self = self, let pub = self.viewModel.currentPublisher, let stories = pub.stories, !stories.isEmpty else { return }
                let vc = StoryDetailViewController(
                    storyUrls: stories.compactMap { $0.url },
                    userName: pub.name,
                    userProfilePic: pub.profilePic
                )
                vc.onDeleteTapped = { [weak self] index in
                    self?.viewModel.deleteStory(at: index)
                }
                self.present(vc, animated: true)
            }
            return cell
            
        case .gallery:
            let cell = tableView.dequeueReusableCell(withIdentifier: ProfileGalleryCell.identifier, for: indexPath) as! ProfileGalleryCell
            cell.configure(title: section.title ?? "", subtitle: section.subtitle, photos: viewModel.currentPublisher?.photos ?? [])
            cell.onAddPhotoTapped = { [weak self] in
                self?.pickerSource = .gallery
                self?.showImageSourceOptions()
            }
            cell.onDeletePhotoTapped = { [weak self] index in
                let alert = UIAlertController(title: "gallery_delete_title".localized, message: "gallery_delete_message".localized, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "photo_cancel".localized, style: .cancel))
                alert.addAction(UIAlertAction(title: "photo_delete".localized, style: .destructive) { _ in
                    self?.viewModel.deleteGalleryImage(at: index)
                })
                self?.present(alert, animated: true)
            }
            return cell
            
        case .menuGroup:
            let cell = tableView.dequeueReusableCell(withIdentifier: ProfileMenuCell.identifier, for: indexPath) as! ProfileMenuCell
            let container = UIView()
            container.backgroundColor = UIColor(red: 0.18, green: 0.12, blue: 0.30, alpha: 1.0)
            cell.contentView.insertSubview(container, at: 0)
            container.snp.makeConstraints { $0.leading.trailing.equalToSuperview().inset(16); $0.top.bottom.equalToSuperview() }
            if indexPath.row == 0 {
                container.layer.cornerRadius = 10; container.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
                cell.configure(title: "menu_rules".localized, icon: "eye.circle", showSeparator: true)
            } else {
                container.layer.cornerRadius = 10; container.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
                cell.configure(title: "menu_settings".localized, icon: "gearshape", showSeparator: false)
            }
            return cell
            
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: ProfileSectionCell.identifier, for: indexPath) as! ProfileSectionCell
            var content = ""
            var tags: [String]? = nil
            var btnTitle: String? = "Edit"
            var btnHidden = false
            let pub = viewModel.currentPublisher
            
            switch section {
            case .nickname: content = "\(pub?.name ?? "")/\(pub?.age ?? 0)"
            case .email: content = pub?.email ?? ""; btnHidden = true
            case .phone: content = pub?.phoneNumber ?? ""
            case .about: content = pub?.about ?? ""
            case .interests: tags = viewModel.selectedInterests.map { $0.name }
            case .notifications: content = "pub_prof_notif_allowed".localized; btnTitle = "menu_settings".localized
            default: break
            }
            
            btnTitle = "pub_prof_edit".localized
            if section == .notifications { btnTitle = "menu_settings".localized }
            
            cell.configure(title: section.title ?? "", subtitle: section.subtitle, content: content, tags: tags, buttonTitle: btnTitle, isButtonHidden: btnHidden)
            cell.onEditTapped = { [weak self] in self?.handleEdit(section) }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = Section(rawValue: indexPath.section) else { return }
        if section == .menuGroup {
            if indexPath.row == 0 { navigationController?.pushViewController(AppRulesViewController(), animated: true) }
            else { navigationController?.pushViewController(SettingsViewController(), animated: true) }
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
        case .about:
            presentEditSheet(for: .about, value: pub?.about ?? "")
        case .phone:
            presentEditSheet(for: .phone, value: pub?.phoneNumber ?? "")
        case .notifications:
            if let url = URL(string: UIApplication.openNotificationSettingsURLString) {
                UIApplication.shared.open(url)
            }
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
        picker.sourceType = sourceType
        present(picker, animated: true)
    }
}

// MARK: - Edit Delegate
extension PublisherProfileVC: PublisherEditValueDelegate {
    func didUpdateValue(type: PublisherEditType, value: String) {
        switch type {
        case .nickname: viewModel.saveProfile(name: value, about: nil, age: nil, phone: nil)
        case .about: viewModel.saveProfile(name: nil, about: value, age: nil, phone: nil)
        case .phone: viewModel.saveProfile(name: nil, about: nil, age: nil, phone: value)
        default: break
        }
    }
}

// MARK: - Header & Picker
extension PublisherProfileVC: PublisherProfileHeaderViewDelegate {
    func publisherHeaderDidTapPhoto() {
        pickerSource = .profile
        showImageSourceOptions()
    }
    func publisherHeaderDidTapAddStory() {
        pickerSource = .story
        showImageSourceOptions()
    }
}

extension PublisherProfileVC: InterestsSelectionDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func didUpdateInterests(_ tags: [InterestModel]) { viewModel.updateInterests(tags) }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        if let img = info[.originalImage] as? UIImage {
            switch pickerSource {
            case .profile: viewModel.uploadProfileImage(img)
            case .gallery: viewModel.uploadGalleryImage(img)
            case .story: viewModel.uploadStoryImage(img)
            }
        }
    }
}
