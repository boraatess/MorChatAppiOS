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
    let productId: String
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
            TokenPackage(title: "100 Token", price: "TRY 100.00", discountText: "", productId: "com.morchat.coins.100"),
            TokenPackage(title: "500 Token", price: "TRY 500.00", discountText: "", productId: "com.morchat.coins.500"),
            TokenPackage(title: "1000 Token", price: "TRY 900.00", discountText: "%10", productId: "com.morchat.coins.1000"),
            TokenPackage(title: "500 Token", price: "TRY 1600.00", discountText: "%20", productId: "com.morchat.coins.500"),
            TokenPackage(title: "1000 Token", price: "TRY 8500.00", discountText: "%15", productId: "com.morchat.coins.1000")
        ]
        
        self.output?.didFetchTokenPackages(packages)
        
    }
}
