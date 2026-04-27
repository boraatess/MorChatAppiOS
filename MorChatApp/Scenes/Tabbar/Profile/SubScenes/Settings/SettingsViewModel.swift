import Foundation
import UIKit
import UserNotifications

protocol SettingsViewModelInputprotocol: AnyObject {
    func fetchItems()
}

protocol SettingsViewOutputProtocol: AnyObject {
    func configureItems(_ items: [SettingItem])
    func configureSectionItems(_ items: [SectionSettings])
}

class SettingsViewModel: SettingsViewModelInputprotocol {
    
    weak var output: SettingsViewOutputProtocol?
    
    func fetchItems() {
        // Preview modunda asenkron sistem çağrıları bazen kilitlenmeye sebep olur
        #if DEBUG
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            self.actuallyFetchItems(isAuthorized: true)
            return
        }
        #endif
        
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            let isAuthorized = settings.authorizationStatus == .authorized
            DispatchQueue.main.async {
                self?.actuallyFetchItems(isAuthorized: isAuthorized)
            }
        }
    }
    
    private func actuallyFetchItems(isAuthorized: Bool) {
        let notifyitems = [
            SettingItem(
                icon: UIImage(systemName: "bell.fill"),
                title: "settings_notif_allow_title".localized,
                subtitle: "settings_notif_allow_desc".localized,
                docUrl: "",
                type: .toggle(isOn: isAuthorized)
            )
        ]
        
        let settingsitems = [
            SettingItem(
                icon: UIImage(systemName: "doc.text.magnifyingglass"),
                title: "settings_language_title".localized,
                subtitle: "settings_language_desc".localized,
                docUrl: "",
                type: .actionSheet
            ),
            SettingItem(
                icon: UIImage(systemName: "lock.fill"),
                title: "settings_privacy_title".localized,
                subtitle: "settings_privacy_desc".localized,
                docUrl: "https://www.morchat.net/gizlilik-politikasi.html",
                type: .normal
            ),
            SettingItem(
                icon: UIImage(systemName: "doc.text.magnifyingglass"),
                title: "settings_kvkk_title".localized,
                subtitle: "settings_kvkk_desc".localized,
                docUrl: "https://www.morchat.net/kullanim-sartlari.html",
                type: .normal
            ),
            SettingItem(
                icon: UIImage(systemName: "lock.fill"),
                title: "settings_permissions_title".localized,
                subtitle: "settings_permissions_desc".localized,
                docUrl: "",
                type: .normal
            )
        ]
        
        let sectionSettings = [
            SectionSettings(title: "settings_section_notif".localized, items: notifyitems),
            SectionSettings(title: "settings_section_general".localized, items: settingsitems)
        ]
        
        self.output?.configureSectionItems(sectionSettings)
    }
}
