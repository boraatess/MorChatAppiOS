import Foundation
import FirebaseAuth

protocol LoginViewModelInputprotocol: AnyObject {
    func loginWithGoogle(idToken: String, accessToken: String)
    func loginWithApple(idToken: String, rawNonce: String, fullName: String?)
}

protocol LoginViewModelOutputprotocol: AnyObject {
    func loginSuccess()
    func showAlert(message: String)
    func setLoader(isVisible: Bool)
}

class LoginViewModel: LoginViewModelInputprotocol {
    weak var output: LoginViewModelOutputprotocol?
    private let authService: FirebaseAuthServiceProtocol
    
    init(authService: FirebaseAuthServiceProtocol = FirebaseAuthService.shared) {
        self.authService = authService
    }
    
    func testGoogleSignin() {
        self.output?.loginSuccess()
        
    }
    
    func loginWithGoogle(idToken: String, accessToken: String) {
        output?.setLoader(isVisible: true)
        authService.signInWithGoogle(idToken: idToken, accessToken: accessToken) { [weak self] result in
            self?.output?.setLoader(isVisible: false)
            switch result {
            case .success:
                UserDefaults.standard.set("user", forKey: "userType")
                self?.output?.loginSuccess()
            case .failure(let error):
                self?.output?.showAlert(message: error.localizedDescription)
            }
        }
    }
    
    func loginWithApple(idToken: String, rawNonce: String, fullName: String?) {
        output?.setLoader(isVisible: true)
        authService.signInWithApple(idToken: idToken, rawNonce: rawNonce, fullName: fullName) { [weak self] result in
            self?.output?.setLoader(isVisible: false)
            switch result {
            case .success:
                UserDefaults.standard.set("user", forKey: "userType")
                self?.output?.loginSuccess()
            case .failure(let error):
                self?.output?.showAlert(message: error.localizedDescription)
            }
        }
    }
}
