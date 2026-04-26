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
                title: "Bildirim İzinleri",
                subtitle: "Kapalı olursa özel canlı yayınları kaçırabilirsin.",
                docUrl: "",
                type: .toggle(isOn: isAuthorized) // Sistemden gelen izin durumunu buraya bağladık
            )
        ]
        
        let settingsitems = [
            SettingItem(
                icon: UIImage(systemName: "doc.text.magnifyingglass"),
                title: "Language",
                subtitle: "Change Language.",
                docUrl: "",
                type: .actionSheet
            ),
            SettingItem(
                icon: UIImage(systemName: "lock.fill"),
                title: "Gizlilik Politikası",
                subtitle: "Verileriniz güvende, belgeye göz atın.",
                docUrl: "https://www.morchat.net/gizlilik-politikasi.html",
                type: .normal
            ),
            SettingItem(
                icon: UIImage(systemName: "doc.text.magnifyingglass"),
                title: "Kvkk Belgesi",
                subtitle: "Tüm işlemlerimiz KVKK uyumludur, belgeye göz atın.",
                docUrl: "https://www.morchat.net/kullanim-sartlari.html",
                type: .normal
            ),
            SettingItem(
                icon: UIImage(systemName: "lock.fill"),
                title: "Permissions",
                subtitle: "",
                docUrl: "",
                type: .normal
            )
        ]
        
        let sectionSettings = [
            SectionSettings(title: "Bildirimler", items: notifyitems),
            SectionSettings(title: "Ayarlar", items: settingsitems)
        ]
        
        self.output?.configureSectionItems(sectionSettings)
    }
}
