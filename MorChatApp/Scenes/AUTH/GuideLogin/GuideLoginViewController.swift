import UIKit
import SnapKit

final class GuideLoginViewController: BaseVC {

    private let gradientLayer = CAGradientLayer()
    
    // Back Button
    private let backButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        b.tintColor = .white
        return b
    }()
    
    // Circular Icon
    private let iconBackground: UIView = {
        let v = UIView()
        // Create matching gradient for icon using radial or just custom color
        v.backgroundColor = UIColor(red: 0.8, green: 0.4, blue: 0.8, alpha: 0.6)
        v.layer.cornerRadius = 40
        v.clipsToBounds = true
        return v
    }()
    
    private let iconImage: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "dot.radiowaves.up.forward"))
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "login_guide".localized
        l.font = .systemFont(ofSize: 28, weight: .bold)
        l.textColor = .white
        l.textAlignment = .center
        return l
    }()
    
    private let subtitleLabel: UILabel = {
        let l = UILabel()
        l.text = "login_guide_subtitle".localized
        l.font = .systemFont(ofSize: 14, weight: .regular)
        l.textColor = .white
        l.textAlignment = .center
        return l
    }()
    
    // TextFields
    private let emailField = GuideTextField(icon: "envelope.fill", placeholder: "login_guide_email".localized)
    private let passwordField = GuideTextField(icon: "lock.fill", placeholder: "login_guide_password".localized, isSecure: true)
    
    // Checkboxes
    private let contractsCheckbox = CheckboxView(text: "login_contracts".localized)
    private let gdprCheckbox = CheckboxView(text: "login_gdpr".localized)
    
    // Log In Button
    private let loginButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("login_guide_login_button".localized, for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        b.backgroundColor = UIColor(red: 0.65, green: 0.25, blue: 0.65, alpha: 1.0)
        b.layer.borderWidth = 1
        b.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
        b.layer.cornerRadius = 14
        
        let arrow = UIImageView(image: UIImage(systemName: "chevron.right"))
        arrow.tintColor = UIColor.white.withAlphaComponent(0.6)
        b.addSubview(arrow)
        arrow.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(16)
            make.size.equalTo(16)
        }
        
        return b
    }()
    
    // Age Checkbox
    private let ageCheckbox = CheckboxView(text: "login_age".localized)
    
    // Become a guide text
    private let becomeGuideLabel: UILabel = {
        let l = UILabel()
        l.text = "login_guide_become".localized
        l.font = .systemFont(ofSize: 14, weight: .bold)
        l.textColor = .white
        l.textAlignment = .center
        l.isUserInteractionEnabled = true
        return l
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        headerView.isHidden = true
        setupUI()
        setupConstraints()
        setupActions()
    }
    
    override func setupGradient() {
        // Core Gradient
        gradientLayer.colors = [
            UIColor(red: 0.55, green: 0.1, blue: 0.8, alpha: 1.0).cgColor,
            UIColor(red: 0.35, green: 0.1, blue: 0.65, alpha: 1.0).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    private func setupUI() {
        view.addSubview(backButton)
        view.addSubview(iconBackground)
        iconBackground.addSubview(iconImage)
        
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        
        view.addSubview(emailField)
        view.addSubview(passwordField)
        
        view.addSubview(contractsCheckbox)
        view.addSubview(gdprCheckbox)
        
        view.addSubview(loginButton)
        view.addSubview(ageCheckbox)
        view.addSubview(becomeGuideLabel)
    }
    
    private func setupConstraints() {
        backButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.leading.equalToSuperview().offset(16)
            make.size.equalTo(44)
        }
        
        iconBackground.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(40)
            make.centerX.equalToSuperview()
            make.size.equalTo(80)
        }
        
        iconImage.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(38)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(iconBackground.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }
        
        emailField.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(32)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(52)
        }
        
        passwordField.snp.makeConstraints { make in
            make.top.equalTo(emailField.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(52)
        }
        
        // Checkboxes side by side
        contractsCheckbox.snp.makeConstraints { make in
            make.top.equalTo(passwordField.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(24)
        }
        
        gdprCheckbox.snp.makeConstraints { make in
            make.centerY.equalTo(contractsCheckbox)
            make.leading.equalTo(contractsCheckbox.snp.trailing).offset(36)
        }
        
        loginButton.snp.makeConstraints { make in
            make.top.equalTo(contractsCheckbox.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(52)
        }
        
        ageCheckbox.snp.makeConstraints { make in
            make.top.equalTo(loginButton.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
        }
        
        becomeGuideLabel.snp.makeConstraints { make in
            make.top.equalTo(ageCheckbox.snp.bottom).offset(32)
            make.centerX.equalToSuperview()
        }
    }
    
    private func setupActions() {
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(becomeGuideTapped))
        becomeGuideLabel.addGestureRecognizer(tap)
        
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
    
    @objc private func backTapped() {
        if let nav = navigationController {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
    
    @objc private func loginTapped() {
        guard let email = emailField.textField.text, !email.isEmpty else {
            showAlert(message: "login_error_email".localized)
            return
        }
        
        guard let password = passwordField.textField.text, !password.isEmpty else {
            showAlert(message: "login_error_password".localized)
            return
        }
        
        if checkTerms() {
            showLoading()
            FirebaseAuthService.shared.signInWithEmail(email: email, password: password) { [weak self] result in
                self?.hideLoading()
                switch result {
                case .success:
                    UserDefaults.standard.set("guide", forKey: "userType")
                    DispatchQueue.main.async {
                        let tabBarVC = TabBarViewController()
                        tabBarVC.modalPresentationStyle = .fullScreen
                        self?.present(tabBarVC, animated: true)
                    }
                case .failure(let error):
                    self?.showAlert(message: error.localizedDescription)
                }
            }
        } else {
            showAlert(message: "login_error_terms".localized)
        }
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "login_error_title".localized, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "common_ok".localized, style: .default))
        present(alert, animated: true)
    }
    
    @objc private func becomeGuideTapped() {
        let vc = BecomeGuideViewController()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
}

fileprivate final class GuideTextField: UIView {
    
    let textField = UITextField()
    private let iconView = UIImageView()
    private let rightButton = UIButton(type: .custom)
    
    private var isSecure: Bool = false
    
    init(icon: String, placeholder: String, isSecure: Bool = false) {
        self.isSecure = isSecure
        super.init(frame: .zero)
        
        backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        layer.cornerRadius = 8
        
        iconView.image = UIImage(systemName: icon)
        iconView.tintColor = UIColor.lightGray.withAlphaComponent(0.8)
        iconView.contentMode = .scaleAspectFit
        
        // Style placeholder
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray.withAlphaComponent(0.8)]
        )
        
        textField.textColor = .black
        textField.font = .systemFont(ofSize: 14)
        textField.isSecureTextEntry = isSecure
        
        addSubview(iconView)
        addSubview(textField)
        
        iconView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.size.equalTo(18)
        }
        
        if isSecure {
            rightButton.setImage(UIImage(systemName: "eye.slash.fill"), for: .normal)
            rightButton.setImage(UIImage(systemName: "eye.fill"), for: .selected)
            rightButton.tintColor = UIColor.lightGray.withAlphaComponent(0.8)
            rightButton.addTarget(self, action: #selector(toggleSecure), for: .touchUpInside)
            
            addSubview(rightButton)
            rightButton.snp.makeConstraints { make in
                make.trailing.equalToSuperview().inset(16)
                make.centerY.equalToSuperview()
                make.size.equalTo(20)
            }
            
            textField.snp.makeConstraints { make in
                make.leading.equalTo(iconView.snp.trailing).offset(12)
                make.trailing.equalTo(rightButton.snp.leading).offset(-12)
                make.top.bottom.equalToSuperview()
            }
        } else {
            textField.snp.makeConstraints { make in
                make.leading.equalTo(iconView.snp.trailing).offset(12)
                make.trailing.equalToSuperview().inset(16)
                make.top.bottom.equalToSuperview()
            }
        }
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    @objc private func toggleSecure() {
        rightButton.isSelected.toggle()
        textField.isSecureTextEntry = !rightButton.isSelected
    }
}
