//
//  OtpViewModel.swift
//  MorChatApp
//
//  Created by bora ateş on 9.02.2026.
//

import Foundation

protocol OtpViewModelInputprotocol: AnyObject {
    func verifyOtp(code: String)
}

protocol OtpViewModelOutputprotocol: AnyObject {
    func otpVerificationSuccess()
    func otpVerificationFailed(with error: String)
}


class OtpViewModel: OtpViewModelInputprotocol {
    weak var output: OtpViewModelOutputprotocol?
    private let authService: FirebaseAuthServiceProtocol
    
    init(authService: FirebaseAuthServiceProtocol = FirebaseAuthService.shared) {
        self.authService = authService
    }
    
    func verifyOtp(code: String) {
        // Firebase Auth ile giriş yap
        self.authService.signIn(with: code) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    UserDefaults.standard.set(true, forKey: "isLogin")
                    self?.output?.otpVerificationSuccess()
                case .failure(let error):
                    self?.output?.otpVerificationFailed(with: error.localizedDescription)
                }
            }
        }
    }
}
