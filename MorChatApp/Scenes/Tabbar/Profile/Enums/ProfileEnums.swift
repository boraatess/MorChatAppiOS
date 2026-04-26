//
//  ProfileEnums.swift
//  MorChatApp
//
//  Created by bora ateş on 12.02.2026.
//

import Foundation
import UIKit

enum AccountSection: Int, CaseIterable {
    case profile
    case tokens
    case freeToken
    case menu
}


enum AccountMenuItem: CaseIterable {
    case interests
    case rules
    case blocked
    case settings
    case help

    var title: String {
        switch self {
        case .interests: return "menu_interests".localized
        case .rules: return "menu_rules".localized
        case .blocked: return "menu_blocked".localized
        case .settings: return "menu_settings".localized
        case .help: return "menu_help".localized
        }
    }

    var icon: String {
        switch self {
        case .interests: return "flame"
        case .rules: return "target"
        case .blocked: return "nosign"
        case .settings: return "gearshape"
        case .help: return "questionmark.circle"
        }
    }
}

enum SettingItemType {
    case toggle(isOn: Bool)
    case normal
    case actionSheet
}

struct SettingItem {
    let icon: UIImage?
    let title: String
    let subtitle: String
    let docUrl: String
    let type: SettingItemType
}

struct SectionSettings {
    let title: String
    let items: [SettingItem]
}
