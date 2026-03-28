//
//  OtpViewController.swift
//  MorChatApp
//
//  Created by bora ateş on 9.02.2026.
//

import Foundation
import UIKit
import SnapKit

final class OtpViewController: UIViewController {

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let backButton = UIButton(type: .system)

    private let iconView = UIView()
    private let phoneIcon = UIImageView(image: UIImage(systemName: "phone.fill"))

    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()

    private var otpFields: [UITextField] = []

    private let resendLabel = UILabel()

    private let continueButton = UIButton(type: .system)

    private var keyboardOffset: CGFloat = 0

    var userPhoneNumber: String? {
        didSet {
            if let phoneNumber = userPhoneNumber {
                subtitleLabel.text = String(format: "otp_subtitle".localized, phoneNumber)
            }
        }
    }
    
    private let viewModel: OtpViewModel
    
    init(viewModel: OtpViewModel = OtpViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        backButton.isHidden = true
        setupUI()
        setupConstraints()
        setupGradient()
        setupKeyboardHandling()
        setupTapToDismiss()
        
        viewModel.output = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        backButton.isHidden = true
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        otpFields.first?.becomeFirstResponder()
    }

    private func getOtpCode() -> String {
        otpFields.compactMap { $0.text }.joined()
    }

    @objc private func continueTapped() {
        let otp = getOtpCode()
        guard otp.count == 6 else { return }
        print("OTP:", otp)
        
        if !otp.isEmpty {
            // ViewModel üzerinden doğrulama başlat
            self.viewModel.verifyOtp(code: otp)
        }
    }

    private func setupUI() {
        view.backgroundColor = .clear

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(backButton)
        contentView.addSubview(iconView)
        iconView.addSubview(phoneIcon)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)

        setupOtpFields()

        contentView.addSubview(resendLabel)
        contentView.addSubview(continueButton)

        backButton.setImage(UIImage(systemName: "arrow.left"), for: .normal)
        backButton.tintColor = .white
        backButton.layer.cornerRadius = 18
        backButton.layer.borderWidth = 1
        backButton.layer.borderColor = UIColor.white.withAlphaComponent(0.4).cgColor

        phoneIcon.tintColor = .white
        phoneIcon.contentMode = .scaleAspectFit

        titleLabel.text = "otp_title".localized
        titleLabel.font = .systemFont(ofSize: 26, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center

        guard let phoneNo = self.userPhoneNumber else { return }
        
        subtitleLabel.text = String(format: "otp_subtitle".localized, phoneNo)
        subtitleLabel.font = .systemFont(ofSize: 15)
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.9)
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0

        resendLabel.text = String(format: "otp_resend_text".localized, 115)
        resendLabel.textColor = .white
        resendLabel.textAlignment = .center

        continueButton.setTitle("otp_continue_button".localized, for: .normal)
        continueButton.setTitleColor(.white, for: .normal)
        continueButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        continueButton.layer.cornerRadius = 28
        continueButton.clipsToBounds = true
        continueButton.addTarget(self, action: #selector(continueTapped), for: .touchUpInside)
        
    }

    private func setupOtpFields() {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12
        stack.distribution = .fillEqually

        contentView.addSubview(stack)

        stack.snp.makeConstraints {
            $0.top.equalTo(subtitleLabel.snp.bottom).offset(32)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(320)
            $0.height.equalTo(56)
        }

        
        for i in 0..<6 {
            let tf = UITextField()
            tf.keyboardType = .numberPad
            tf.textAlignment = .center
            tf.font = .systemFont(ofSize: 22, weight: .semibold)
            tf.textColor = .white
            tf.backgroundColor = UIColor.white.withAlphaComponent(0.15)
            tf.layer.cornerRadius = 16
            tf.layer.borderWidth = 1
            tf.layer.borderColor = UIColor.white.withAlphaComponent(0.4).cgColor
            tf.delegate = self
            tf.tag = i
            tf.addTarget(self, action: #selector(otpChanged(_:)), for: .editingChanged)
            tf.layer.masksToBounds = true
            tf.returnKeyType = .next

            otpFields.append(tf)
            stack.addArrangedSubview(tf)
        }
    }

    private func setupConstraints() {

        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }

        backButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview().offset(16)
            $0.size.equalTo(36)
        }

        iconView.snp.makeConstraints {
            $0.top.equalTo(backButton.snp.bottom).offset(40)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(90)
        }

        phoneIcon.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(36)
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(iconView.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(24)
        }

        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(24)
        }

        resendLabel.snp.makeConstraints {
            $0.top.equalTo(otpFields.first!.superview!.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview()
        }

        continueButton.snp.makeConstraints {
            $0.top.equalTo(resendLabel.snp.bottom).offset(40)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(56)
            $0.bottom.equalToSuperview().offset(-40)
        }
    }

    @objc private func otpChanged(_ textField: UITextField) {
        guard let text = textField.text else { return }

        if text.count == 1 {
            let nextTag = textField.tag + 1
            otpFields.first { $0.tag == nextTag }?.becomeFirstResponder()
        }
    }

    private func setupKeyboardHandling() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }

        keyboardOffset = frame.height - view.safeAreaInsets.bottom
        scrollView.contentInset.bottom = keyboardOffset + 20
        scrollView.verticalScrollIndicatorInsets.bottom = keyboardOffset
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        scrollView.contentInset.bottom = 0
        scrollView.verticalScrollIndicatorInsets.bottom = 0
    }

    private func setupTapToDismiss() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    private func setupGradient() {
        let bg = CAGradientLayer()
        bg.colors = [
            UIColor(red: 0.63, green: 0.23, blue: 0.73, alpha: 1).cgColor,
            UIColor(red: 0.36, green: 0.14, blue: 0.56, alpha: 1).cgColor
        ]
        bg.startPoint = CGPoint(x: 0, y: 0)
        bg.endPoint = CGPoint(x: 1, y: 1)
        bg.frame = view.bounds
        view.layer.insertSublayer(bg, at: 0)

        let btn = CAGradientLayer()
        btn.colors = [UIColor.systemPink.cgColor, UIColor.systemPurple.cgColor]
        btn.frame = CGRect(x: 0, y: 0, width: view.bounds.width - 48, height: 56)
        continueButton.layer.insertSublayer(btn, at: 0)


        iconView.layer.cornerRadius = 45
        iconView.backgroundColor = UIColor.white.withAlphaComponent(0.15)
    }

    
}

extension OtpViewController: UITextFieldDelegate {
    

    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {

        // Sadece rakam
        if !string.isEmpty && string.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) != nil {
            return false
        }

        // Backspace
        if string.isEmpty {
            textField.text = ""
            let prevTag = textField.tag - 1
            if prevTag >= 0 {
                otpFields.first { $0.tag == prevTag }?.becomeFirstResponder()
            }
            return false
        }

        // Paste (örn: 123456)
        if string.count > 1 {
            fillOtpFromPaste(string)
            return false
        }

        // Normal tek karakter girişi
        textField.text = string
        let nextTag = textField.tag + 1
        if nextTag < otpFields.count {
            otpFields[nextTag].becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }

        return false
    }

    private func fillOtpFromPaste(_ code: String) {
        let chars = Array(code.prefix(otpFields.count))
        for (i, c) in chars.enumerated() {
            otpFields[i].text = String(c)
        }
        otpFields.last?.resignFirstResponder()
    }

    
}

extension OtpViewController: OtpViewModelOutputprotocol {
    func otpVerificationSuccess() {
        showAutoDismissAlert(title: "otp_success_title".localized, message: "otp_success_message".localized, duration: 2.0)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let tabbar = TabBarViewController()
            tabbar.modalPresentationStyle = .overFullScreen
            self.present(tabbar, animated: true)
        }
    }
    
    func otpVerificationFailed(with error: String) {
        showAutoDismissAlert(title: "otp_error_title".localized, message: error, duration: 2.0)
    }
}
