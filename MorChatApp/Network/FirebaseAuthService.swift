import Foundation
import FirebaseAuth
import GoogleSignIn

protocol FirebaseAuthServiceProtocol {
    func verifyPhoneNumber(_ phoneNumber: String, completion: @escaping (Result<String, Error>) -> Void)
    func signIn(with verificationCode: String, completion: @escaping (Result<AuthDataResult, Error>) -> Void)
    func signInWithGoogle(idToken: String, accessToken: String, completion: @escaping (Result<AuthDataResult, Error>) -> Void)
    func signInWithApple(idToken: String, rawNonce: String, fullName: String?, completion: @escaping (Result<AuthDataResult, Error>) -> Void)
    func signInWithEmail(email: String, password: String, completion: @escaping (Result<AuthDataResult, Error>) -> Void)
    func signOut()
}

class FirebaseAuthService: FirebaseAuthServiceProtocol {
    
    static let shared = FirebaseAuthService()
    
    // Geçici olarak verification ID'yi burada veya UserDefaults'ta saklayacağız
    private var verificationId: String? {
        get { return UserDefaults.standard.string(forKey: "authVerificationID") }
        set { UserDefaults.standard.set(newValue, forKey: "authVerificationID") }
    }
    
    // 1. SMS Kodunu İsteme
    func verifyPhoneNumber(_ phoneNumber: String, completion: @escaping (Result<String, Error>) -> Void) {
        // Telefon numarasının E.164 formatında olduğundan emin olunmalı, örneğin: "+905551234567"
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { [weak self] verificationID, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let verID = verificationID else {
                let err = NSError(domain: "Auth", code: 0, userInfo: [NSLocalizedDescriptionKey: "Verification ID is nil"])
                completion(.failure(err))
                return
            }
            self?.verificationId = verID
            completion(.success(verID))
        }
    }
    
    // 2. Gelen SMS Kodu ile Giriş Yapma
    func signIn(with verificationCode: String, completion: @escaping (Result<AuthDataResult, Error>) -> Void) {
        guard let verificationID = self.verificationId else {
            let err = NSError(domain: "Auth", code: 0, userInfo: [NSLocalizedDescriptionKey: "Verification ID not found"])
            completion(.failure(err))
            return
        }
        
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID,
            verificationCode: verificationCode
        )
        
        Auth.auth().signIn(with: credential) { authResult, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            if let authResult = authResult {
                UserDefaults.standard.set(true, forKey: "isLogin")
                completion(.success(authResult))
            }
        }
    }
    
    // 3. Google ile Giriş Yapma
    func signInWithGoogle(idToken: String, accessToken: String, completion: @escaping (Result<AuthDataResult, Error>) -> Void) {
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        
        Auth.auth().signIn(with: credential) { authResult, error in
            if let error = error {
                print("❌ Google Sign-In Error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            if let authResult = authResult {
                let user = UserModel( uid: authResult.user.uid,
                                      name: authResult.user.displayName,
                                      email: authResult.user.email,
                                      photoURL: authResult.user.photoURL?.absoluteString,
                                      createdAt: Date(),
                                      interests: [],
                                      tagList: [],
                                      age: 0,
                                      status: "unknown",
                                      blockedPublisherList: nil)
                
                FirestoreService.shared.saveUserProfile(user: user) { _ in
                    UserDefaults.standard.set(true, forKey: "isLogin")
                    completion(.success(authResult))
                }
            }
        }
    }
    
    // 4. Apple ile Giriş Yapma
    func signInWithApple(idToken: String, rawNonce: String, fullName: String?, completion: @escaping (Result<AuthDataResult, Error>) -> Void) {
        let credential = OAuthProvider.appleCredential(withIDToken: idToken,
                                                        rawNonce: rawNonce,
                                                        fullName: nil)
        
        Auth.auth().signIn(with: credential) { authResult, error in
            if let error = error {
                print("❌ Apple Sign-In Error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            if let authResult = authResult {
                // Apple sadece İLK girişte isim döndürür. Sonraki girişlerde nil gelir.
                // Bu yüzden eğer elimizde yeni bir isim varsa (fullName) onu kullanıyoruz.
                let nameToSave = fullName ?? authResult.user.displayName
                
                let userModel =  UserModel( uid: authResult.user.uid,
                                            name: authResult.user.displayName,
                                            email: authResult.user.email,
                                            photoURL: authResult.user.photoURL?.absoluteString,
                                            createdAt: Date(),
                                            interests: [],
                                            tagList: [],
                                            age: 0,
                                            status: "unknown",
                                            blockedPublisherList: nil)
                
                FirestoreService.shared.saveUserProfile(user: userModel) { _ in
                    UserDefaults.standard.set(true, forKey: "isLogin")
                    completion(.success(authResult))
                }
            }
        }
    }
    
    // 5. Kullanıcı Çıkış İşlemi
    func signOut() {
        do {
            // Firebase Auth çıkışı
            try Auth.auth().signOut()
            
            // Google SDK çıkışı (Önemli: Gmail session'ını da temizler)
            GIDSignIn.sharedInstance.signOut()
            
            UserDefaults.standard.set(false, forKey: "isLogin")
            UserDefaults.standard.removeObject(forKey: "userType") // Clear user type on sign out
            print("✅ Başarıyla çıkış yapıldı.")
        } catch {
            print("❌ Sign out error: \(error)")
        }
    }

    // 6. Email ve Şifre ile Giriş Yapma
    func signInWithEmail(email: String, password: String, completion: @escaping (Result<AuthDataResult, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            if let authResult = authResult {
                UserDefaults.standard.set(true, forKey: "isLogin")
                completion(.success(authResult))
            }
        }
    }
}
