//
//  SplashViewModel.swift
//  MorChatApp
//
//  Created by bora ateş on 21.01.2026.
//

import Foundation

protocol SplashViewModelInputprotocol: AnyObject {
    
}

protocol SplashViewModeloutputprotocol: AnyObject {
    func goTabbar()
    func didFinish()
    
}


class SplashViewModel {
    
    weak var output: SplashViewModeloutputprotocol?
    
    var onFinish: (() -> Void)?

    func start() {
        // Örn: auth check, token kontrolü, delay vs.
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            print("✅ viewmodel finished")
            self.onFinish?()
            
        }
    }
    
    
}
