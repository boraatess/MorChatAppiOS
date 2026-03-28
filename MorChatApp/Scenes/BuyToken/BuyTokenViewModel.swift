//
//  BuyTokenViewModel.swift
//  MorChatApp
//
//  Created by bora ateş on 21.02.2026.
//

import Foundation

struct TokenPackage {
    let title: String
    let price: String
    let discountText: String? // nil ise badge yok
}


protocol BuytokenviewModelInputProtocol: AnyObject {
    func fetchTokenPackages()
}

protocol BuytokenviewModelOutputProtocol: AnyObject {
    func didFetchTokenPackages(_ packages: [TokenPackage])
    
}


class BuyTokenViewModel: BuytokenviewModelInputProtocol {
    
    weak var output: BuytokenviewModelOutputProtocol?
    
    
    func fetchTokenPackages() {
        let packages = [
            TokenPackage(title: "1 Token", price: "TRY 100.00", discountText: ""),
            TokenPackage(title: "5 Token", price: "TRY 500.00", discountText: "" ),
            TokenPackage(title: "10 Token", price: "TRY 900.00", discountText: "%10"),
            TokenPackage(title: "20 Token", price: "TRY 1,600.00", discountText: "%20"),
            TokenPackage(title: "50 Token", price: "TRY 3,900.00", discountText: "%25"),
            TokenPackage(title: "100 Token", price: "TRY 8,500.00", discountText: "%30")
        ]
        
        self.output?.didFetchTokenPackages(packages)
        
        
    }
    
    
}
