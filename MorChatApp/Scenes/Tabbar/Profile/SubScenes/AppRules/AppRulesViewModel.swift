//
//  AppRulesViewModel.swift
//  MorChatApp
//
//  Created by bora ateş on 12.02.2026.
//

import Foundation
import UIKit


protocol AppRulesViewModelInputProtocol: AnyObject {
    func fetchRuleItems()
}

protocol AppRulesViewModelOutputprotocol: AnyObject {
    func configureRuleItems(_ items: [RuleItem])
    
}

class AppRulesViewModel: AppRulesViewModelInputProtocol {
    
    weak var output: AppRulesViewModelOutputprotocol?
    
    
    func fetchRuleItems() {
    
       let rules = [
            RuleItem(
                icon: UIImage(systemName: "checkmark"),
                iconBackgroundColor: UIColor.App.elevatedBackground,
                title: "Saygılı Olun",
                message: "Tüm kullanıcılara ve yayıncılara saygılı davranın. Hakaret ve küfür yasaktır.",
                containerColor: UIColor.App.statusOnlineBackground
            ),
            RuleItem(
                icon: UIImage(systemName: "checkmark"),
                iconBackgroundColor: UIColor.App.elevatedBackground,
                title: "Güvenliğinizi Koruyun",
                message: "Kişisel bilgilerinizi (telefon, adres, TC kimlik) paylaşmayın.",
                containerColor: UIColor.App.statusOnlineBackground
            ),
            RuleItem(
                icon: UIImage(systemName: "exclamationmark"),
                iconBackgroundColor: .systemPurple,
                title: "Taciz Yasak",
                message: "Cinsel içerikli, taciz edici veya tehdit içeren mesajlar kesinlikle yasaktır.",
                containerColor: UIColor.App.statusOfflineBackground
            ),
            RuleItem(
                icon: UIImage(systemName: "exclamationmark"),
                iconBackgroundColor: .systemPurple,
                title: "Spam Yapmayın",
                message: "Aynı mesajı tekrar tekrar göndermek veya reklam yapmak yasaktır.",
                containerColor: UIColor.App.statusOfflineBackground
            ),
            RuleItem(
                icon: UIImage(systemName: "exclamationmark"),
                iconBackgroundColor: .systemYellow,
                title: "Şikayet Hakkı",
                message: "Kurallara uymayan kullanıcıları şikayet edebilirsiniz. Şikayetler 24 saat içinde değerlendirilir.",
                containerColor: UIColor.App.secondaryElevatedBackground
            )
        ]
        
        self.output?.configureRuleItems(rules)
        
    }
    
}
