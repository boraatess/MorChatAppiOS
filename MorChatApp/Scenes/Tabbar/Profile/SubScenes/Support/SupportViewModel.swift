//
//  SupportViewModel.swift
//  MorChatApp
//
//  Created by bora ateş on 14.02.2026.
//

import Foundation

protocol SupportViewModelInputprotocol: AnyObject {
    func fetchFAQitems()
}

protocol SupportViewModelOutputprotocol: AnyObject {
    func didFetchFAQitems(_ faqItems: [FAQItem])
    
}

class SupportViewModel: SupportViewModelInputprotocol {
    
    weak var output: SupportViewModelOutputprotocol?
    
    func fetchFAQitems() {
        let faqItems = [
            FAQItem(question: "Jeton nasıl satın alabilirim?",
                    answer: "Profil > Cüzdan kısmından jeton satın alabilirsiniz."),
            
            FAQItem(question: "Yayıncıyla nasıl sohbet edebilirim?",
                    answer: "Canlı yayına katılarak mesaj gönderebilirsiniz."),
            
            FAQItem(question: "Bir yayıncıyı nasıl engellerim?",
                    answer: "Profiline girip engelle butonuna basabilirsiniz."),
            
            FAQItem(question: "Jetonlarım ne zaman düşer?",
                    answer: "Ödeme sonrası anında hesabınıza yansır."),
            
            FAQItem(question: "Hesabımı nasıl silebilirim?",
                    answer: "Ayarlar > Hesap Sil bölümünden silebilirsiniz."),
            
            FAQItem(question: "Şikayette nasıl bulunabilirim?",
                    answer: "Profil sayfasındaki şikayet butonunu kullanabilirsiniz.")
        ]
        
        self.output?.didFetchFAQitems(faqItems)
        
        
        
    }
    
    
}
