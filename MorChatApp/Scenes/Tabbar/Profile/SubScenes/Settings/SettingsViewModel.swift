//
//  SettingsViewModel.swift
//  MorChatApp
//
//  Created by bora ateş on 12.02.2026.
//

import Foundation
import UIKit

protocol SettingsViewModelInputprotocol: AnyObject {
    func fetchItems()
}

protocol SettingsViewOutputProtocol: AnyObject {
    func configureItems(_ items: [SettingItem])
}

class SettingsViewModel: SettingsViewModelInputprotocol {
    
    weak var output: SettingsViewOutputProtocol?
    
    
    func fetchItems() {
        let items = [
            SettingItem(
                icon: UIImage(systemName: "bell.fill"),
                title: "Bildirim İzinleri",
                subtitle: "Kapalı olursa özel canlı yayınları kaçırabilirsin.", docUrl: "",
                type: .toggle(isOn: true)
            ),
            SettingItem(
                icon: UIImage(systemName: "doc.text.magnifyingglass"),
                title: "Language",
                subtitle: "Change Language.", docUrl: "",
                type: .normal
            ),
            SettingItem(
                icon: UIImage(systemName: "lock.fill"),
                title: "Gizlilik Politikası",
                subtitle: "Verileriniz güvende, belgeye göz atın.", docUrl: "https://www.morchat.net/gizlilik-politikasi.html",
                type: .normal
            ),
            SettingItem(
                icon: UIImage(systemName: "doc.text.magnifyingglass"),
                title: "Kvkk Belgesi",
                subtitle: "Tüm işlemlerimiz KVKK uyumludur, belgeye göz atın.", docUrl: "https://www.morchat.net/kullanim-sartlari.html",
                type: .normal
            ),
            SettingItem(
                icon: UIImage(systemName: "lock.fill"),
                title: "Permissions",
                subtitle: "", docUrl: "",
                type: .normal
            )
        ]
        
        self.output?.configureItems(items)
        
    }
    
    
}
