//
//  LoginViewController.swift
//  MorChatApp
//
//  Created by bora ateş.
//

import UIKit
import SnapKit
import GoogleSignIn
import FirebaseAuth
import AuthenticationServices
import CryptoKit

final class LoginViewController: UIViewController {

    // MARK: UI Elements
    private let backgroundView = LoginBackgroundView()
    private let containerView = UIView()
    private var currentNonce: String?
    
    private let googleButton: UIButton = {
        let b = UIButton(type: .system)
        b.backgroundColor = .white
        b.setTitle("login_gmail".localized, for: .normal)
        b.setTitleColor(.black, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        b.layer.cornerRadius = 24
        
        // Simulating the Google Icon if asset is missing
        let iconView = UIImageView(image: UIImage(systemName: "envelope.fill"))
        iconView.tintColor = .systemRed // Fallback
        b.addSubview(iconView)
        iconView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.size.equalTo(20)
        }
        
        // Add subtle shadow similar to modern UI
        b.layer.shadowColor = UIColor.black.cgColor
        b.layer.shadowOpacity = 0.1
        b.layer.shadowOffset = CGSize(width: 0, height: 4)
        b.layer.shadowRadius = 10
        
        return b
    }()
    
    private let appleButton: UIButton = {
        let b = UIButton(type: .system)
        b.backgroundColor = .black
        b.setTitle("login_apple".localized, for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        b.layer.cornerRadius = 24
        let iconView = UIImageView(image: UIImage(systemName: "applelogo"))
        iconView.tintColor = .white
        b.addSubview(iconView)
        iconView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.size.equalTo(22)
        }
        return b
    }()
    
    private let contractsCheckbox = CheckboxView(text: "login_contracts".localized)
    private let gdprCheckbox = CheckboxView(text: "login_gdpr".localized)
    private let ageCheckbox = CheckboxView(text: "login_age".localized)
    
    private let guideLoginButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Guide Login >", for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        b.backgroundColor = .clear
        b.layer.borderColor = UIColor.white.cgColor
        b.layer.borderWidth = 1
        b.layer.cornerRadius = 16
        return b
    }()

    let viewModel = LoginViewModel()
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.output = self
        setupUI()
        setupConstraints()
    }
    
    private func setupUI() {
        view.addSubview(backgroundView)
        view.addSubview(containerView)
        
        containerView.addSubview(googleButton)
        containerView.addSubview(appleButton)
        containerView.addSubview(contractsCheckbox)
        containerView.addSubview(gdprCheckbox)
        containerView.addSubview(ageCheckbox)
        
        view.addSubview(guideLoginButton)

        googleButton.addTarget(self, action: #selector(googleTapped), for: .touchUpInside)
        appleButton.addTarget(self, action: #selector(appleTapped), for: .touchUpInside)
        guideLoginButton.addTarget(self, action: #selector(guideLoginTapped), for: .touchUpInside)
        
        contractsCheckbox.onLabelTap = { [weak self] in
            let vc = TermsWebViewController(urlString: "https://www.morchat.net/kullanim-sartlari.html", pageTitle: "login_contracts".localized)
            self?.navigationController?.pushViewController(vc, animated: true)
        }
        
        gdprCheckbox.onLabelTap = { [weak self] in
            let vc = TermsWebViewController(urlString: "https://www.morchat.net/gizlilik-politikasi.html", pageTitle: "login_gdpr".localized)
            self?.navigationController?.pushViewController(vc, animated: true)
        }
    }

    private func checkTerms() -> Bool {
        return contractsCheckbox.isChecked && gdprCheckbox.isChecked && ageCheckbox.isChecked
    }
    
    @objc private func googleTapped() {
        
        // self.goTabbar()
        
        if checkTerms() {
            GIDSignIn.sharedInstance.signIn(withPresenting: self) { [weak self] result, error in
                if let error = error {
                    self?.showAutoDismissAlert(title: "Error", message: error.localizedDescription, duration: 2.0)
                    return
                }
                
                guard let user = result?.user,
                      let idToken = user.idToken?.tokenString else {
                    return
                }
                
                let accessToken = user.accessToken.tokenString
                
                self?.viewModel.loginWithGoogle(idToken: idToken, accessToken: accessToken)
            }
        } else {
            showAutoDismissAlert(title: "login_error_title".localized, message: "login_error_terms".localized, duration: 2.0)
        }
        
    }
    
    @objc private func appleTapped() {
        if checkTerms() {
            let nonce = randomNonceString()
            currentNonce = nonce
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]
            request.nonce = sha256(nonce)
            
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.presentationContextProvider = self
            authorizationController.performRequests()
        } else {
            showAutoDismissAlert(title: "login_error_title".localized, message: "login_error_terms".localized, duration: 2.0)
        }
    }
    
    @objc private func guideLoginTapped() {
        let vc = GuideLoginViewController()
        if let nav = self.navigationController {
            nav.pushViewController(vc, animated: true)
        } else {
            self.present(vc, animated: true)
        }
    }

    private func setupConstraints() {
        backgroundView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        containerView.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(-20) // Slightly shifted up based on visual center
            make.leading.trailing.equalToSuperview().inset(32) // Nice padding on sides
        }
        
        googleButton.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(48)
        }
        
        appleButton.snp.makeConstraints { make in
            make.top.equalTo(googleButton.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(48)
        }
        
        contractsCheckbox.snp.makeConstraints { make in
            make.top.equalTo(appleButton.snp.bottom).offset(24) // Spacing from apple button
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        gdprCheckbox.snp.makeConstraints { make in
            make.top.equalTo(contractsCheckbox.snp.bottom).offset(12)
            make.leading.trailing.equalTo(contractsCheckbox)
        }
        
        ageCheckbox.snp.makeConstraints { make in
            make.top.equalTo(gdprCheckbox.snp.bottom).offset(12)
            make.leading.trailing.equalTo(contractsCheckbox)
            make.bottom.equalToSuperview()
        }
        
        guideLoginButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(24)
            make.trailing.equalToSuperview().inset(24)
            make.width.equalTo(110)
            make.height.equalTo(32)
        }
    }
    
    private func goTabbar() {
        let tabbar = TabBarViewController()
        tabbar.modalPresentationStyle = .overFullScreen
        self.present(tabbar, animated: true)
    }
    
}

extension LoginViewController: LoginViewModelOutputprotocol {
    func loginSuccess() {
        // Go straight to TabBar after Gmail / Apple Sign in
        DispatchQueue.main.async {
            self.goTabbar()
            
        }
    }
    
    func showAlert(message: String) {
        showAutoDismissAlert(title: "login_error_title".localized, message: message, duration: 2.0)
    }
}

extension LoginViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            
            let firstName = appleIDCredential.fullName?.givenName ?? ""
            let lastName = appleIDCredential.fullName?.familyName ?? ""
            let fullName = "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
            
            viewModel.loginWithApple(idToken: idTokenString, rawNonce: nonce, fullName: fullName.isEmpty ? nil : fullName)
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Sign in with Apple errored: \(error)")
    }
    
    
}

// MARK: - Helpers for Apple Sign In
extension LoginViewController {
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvxyz")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 { return }
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        return result
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap { String(format: "%02x", $0) }.joined()
        return hashString
    }
}
