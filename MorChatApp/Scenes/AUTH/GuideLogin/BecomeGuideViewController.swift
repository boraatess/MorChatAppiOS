import UIKit
import SnapKit

final class BecomeGuideViewController: BaseVC {

    // MARK: - UI Elements
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = true
        sv.alwaysBounceVertical = true
        return sv
    }()
    
    private let contentView = UIView()

    private let closeButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "xmark"), for: .normal)
        b.tintColor = UIColor(red: 0.6, green: 0.4, blue: 0.8, alpha: 1.0)
        b.backgroundColor = .white
        b.layer.cornerRadius = 16
        b.layer.borderWidth = 1
        b.layer.borderColor = UIColor(white: 0.9, alpha: 1.0).cgColor
        return b
    }()
    
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "become_guide_title".localized
        l.font = .systemFont(ofSize: 22, weight: .bold)
        l.textColor = UIColor(red: 0.55, green: 0.35, blue: 0.85, alpha: 1.0)
        l.textAlignment = .center
        return l
    }()
    
    private let subtitleLabel: UILabel = {
        let l = UILabel()
        l.text = "become_guide_subtitle".localized
        l.font = .systemFont(ofSize: 13, weight: .regular)
        l.textColor = .gray
        l.textAlignment = .center
        l.numberOfLines = 0
        return l
    }()
    
    private let selectTopicsLabel: UILabel = {
        let l = UILabel()
        l.text = "become_guide_select_topics".localized
        l.font = .systemFont(ofSize: 14, weight: .semibold)
        l.textColor = UIColor(red: 0.6, green: 0.4, blue: 0.9, alpha: 1.0)
        l.textAlignment = .center
        return l
    }()
    
    // Tag Cloud
    private let tagsCloudView = SharedTagsCloudView()
    
    // Input Fields
    private let nameField = ApplyTextField(placeholder: "become_guide_name_placeholder".localized, icon: nil)
    private let phoneField = ApplyTextField(placeholder: "become_guide_phone_placeholder".localized, icon: nil, isPhone: true)
    private let instaField = ApplyTextField(placeholder: "become_guide_insta_placeholder".localized, icon: "camera.fill")
    
    private let countryPickerView = CustomCountryPickerView()
    
    // Apply Button
    private let applyButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("become_guide_apply".localized, for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        b.backgroundColor = UIColor(red: 0.6, green: 0.4, blue: 0.8, alpha: 1.0)
        b.layer.cornerRadius = 14
        b.isEnabled = true 
        return b
    }()

    private var selectedTopicsCount = 0

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        headerView.isHidden = true
        setupUI()
        setupConstraints()
        setupActions()
        tagsCloudView.selectionLimit = 5
        
        nameField.textField.delegate = self
        phoneField.textField.delegate = self
    }
    
    override func setupGradient() {
        // Keep it plain for this form
        view.backgroundColor = UIColor(white: 0.98, alpha: 1.0)
    }

    // MARK: - Setup UI
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(closeButton)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(selectTopicsLabel)
        
        tagsCloudView.delegate = self
        contentView.addSubview(tagsCloudView)
        
        contentView.addSubview(nameField)
        contentView.addSubview(phoneField)
        contentView.addSubview(instaField)
        
        contentView.addSubview(applyButton)
        
        view.addSubview(countryPickerView)
        countryPickerView.isHidden = true
    }
    
    private func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
        }

        closeButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview().offset(16)
            make.size.equalTo(32)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(closeButton.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(24)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(32)
        }
        
        selectTopicsLabel.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(24)
            make.centerX.equalToSuperview()
        }
        
        tagsCloudView.snp.makeConstraints { make in
            make.top.equalTo(selectTopicsLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        nameField.snp.makeConstraints { make in
            make.top.equalTo(tagsCloudView.snp.bottom).offset(32)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(48)
        }
        
        phoneField.snp.makeConstraints { make in
            make.top.equalTo(nameField.snp.bottom).offset(16)
            make.leading.trailing.equalTo(nameField)
            make.height.equalTo(48)
        }
        
        instaField.snp.makeConstraints { make in
            make.top.equalTo(phoneField.snp.bottom).offset(16)
            make.leading.trailing.equalTo(nameField)
            make.height.equalTo(48)
        }
        
        applyButton.snp.makeConstraints { make in
            make.top.equalTo(instaField.snp.bottom).offset(40)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(52)
            make.bottom.equalToSuperview().offset(-32)
        }
        
        countryPickerView.snp.makeConstraints { make in
            make.top.equalTo(phoneField.snp.bottom).offset(2)
            make.leading.equalTo(phoneField).offset(16)
            make.width.equalTo(180)
        }
    }
    
    private func setupActions() {
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        applyButton.addTarget(self, action: #selector(applyTapped), for: .touchUpInside)
        
        phoneField.onPrefixTap = { [weak self] in
            self?.showCountryPicker()
        }
    }
    
    private func showCountryPicker() {
        // Convert phoneField's prefix box position to main transition view coordinates
        let prefixFrame = phoneField.getPrefixFrame()
        let globalFrame = phoneField.convert(prefixFrame, to: self.view)
        
        countryPickerView.snp.remakeConstraints { make in
            make.top.equalTo(globalFrame.maxY + 4)
            make.leading.equalTo(globalFrame.minX)
            make.width.equalTo(200)
        }
        
        countryPickerView.onSelection = { [weak self] flag, code in
            self?.phoneField.updatePrefix(flag: flag, code: code)
            self?.countryPickerView.isHidden = true
        }
        
        countryPickerView.isHidden.toggle()
        view.bringSubviewToFront(countryPickerView)
    }
    
    // MARK: - Handlers


    @objc private func closeTapped() {
        dismiss(animated: true)
    }
    
    @objc private func applyTapped() {
        if selectedTopicsCount == 0 {
            showAlert(message: "apply_error_topic".localized)
            return
        }
        
        guard let name = nameField.textField.text, !name.isEmpty else {
            showAlert(message: "apply_error_name".localized)
            return
        }
        
        guard let phone = phoneField.textField.text, !phone.isEmpty else {
            showAlert(message: "apply_error_phone".localized)
            return
        }
        
        guard let insta = instaField.textField.text, !insta.isEmpty else {
            showAlert(message: "apply_error_insta".localized)
            return
        }
        
        let topics = tagsCloudView.getSelectedTags().joined(separator: ", ")
        let fullPhone = phoneField.getPrefix() + phone
        
        let data: [String: Any] = [
            "uuid": UUID().uuidString,
            "ad_soyad": name,
            "başvuru_kanalı": "mobil uygulama",
            "created_at": Date(), // Firestore saves Date as Timestamp
            "ilgi_alanlari": topics,
            "instagram": insta,
            "telefon_no": fullPhone
        ]
        
        // Show loading
        showLoading()
        
        FirestoreService.shared.submitBecomeGuideForm(data: data) { [weak self] error in
            guard let self = self else { return }
            self.hideLoading()
            
            if let error = error {
                let errorMsg = String(format: "apply_error_submit".localized, error.localizedDescription)
                self.showAlert(message: errorMsg)
                return
            }
            
            let successAlert = UIAlertController(title: "apply_success_title".localized, message: "apply_success_message".localized, preferredStyle: .alert)
            successAlert.addAction(UIAlertAction(title: "common_ok".localized, style: .default, handler: { _ in
                self.dismiss(animated: true)
            }))
            self.present(successAlert, animated: true)
        }
    }

    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "apply_missing_title".localized, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "common_ok".localized, style: .default))
        present(alert, animated: true)
    }

    private func checkFormValidation() {
        // We keep it enabled for the alert logic as requested
    }
}

extension BecomeGuideViewController: SharedTagsCloudViewDelegate {
    
    func selectedTag(_ id: Int, tagName: String, icon: String, color: UIColor) {
        
    }
    
    func didUpdateSelectedCount(_ count: Int) {
        selectedTopicsCount = count
        checkFormValidation()
    }
}

// MARK: - Custom Views
// SharedTagsCloudView is used from Common components.


fileprivate final class ApplyTextField: UIView {
    let textField = UITextField()
    private let flagLabel = UILabel()
    private let prefixLabel = UILabel()
    
    var onPrefixTap: (() -> Void)?
    
    init(placeholder: String, icon: String?, isPhone: Bool = false) {
        super.init(frame: .zero)
        
        backgroundColor = .white
        layer.cornerRadius = 10
        layer.borderWidth = 1
        layer.borderColor = UIColor(white: 0.9, alpha: 1.0).cgColor
        
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray]
        )

        textField.textColor = .black
        textField.font = .systemFont(ofSize: 15)
        
        let container = UIStackView()
        container.axis = .horizontal
        container.spacing = 10
        container.alignment = .center
        
        if let ico = icon {
            let iv = UIImageView(image: UIImage(systemName: ico))
            iv.tintColor = .lightGray
            iv.snp.makeConstraints { $0.size.equalTo(20) }
            container.addArrangedSubview(iv)
        }
        
        if isPhone {
            let prefixButton = UIButton(type: .custom)
            prefixButton.addTarget(self, action: #selector(handlePrefixTap), for: .touchUpInside)
            
            flagLabel.text = "🇹🇷"
            flagLabel.font = .systemFont(ofSize: 16)
            flagLabel.isUserInteractionEnabled = false
            
            let sep = UIView()
            sep.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
            sep.isUserInteractionEnabled = false
            sep.snp.makeConstraints { make in
                make.width.equalTo(1)
                make.height.equalTo(20)
            }
            
            prefixLabel.text = "+90"
            prefixLabel.font = .systemFont(ofSize: 14, weight: .medium)
            prefixLabel.textColor = .black
            prefixLabel.isUserInteractionEnabled = false
            
            let chevron = UIImageView(image: UIImage(systemName: "chevron.down"))
            chevron.tintColor = .lightGray
            chevron.isUserInteractionEnabled = false
            chevron.snp.makeConstraints { $0.size.equalTo(10) }
            
            let hStack = UIStackView(arrangedSubviews: [flagLabel, prefixLabel, chevron])
            hStack.spacing = 4
            hStack.alignment = .center
            hStack.isUserInteractionEnabled = false
            
            prefixButton.addSubview(hStack)
            hStack.snp.makeConstraints { make in
                make.leading.equalToSuperview()
                make.trailing.equalToSuperview().offset(-8)
                make.centerY.equalToSuperview()
            }
            
            container.addArrangedSubview(prefixButton)
            container.addArrangedSubview(sep)
            
            textField.keyboardType = .phonePad
        }
        
        container.addArrangedSubview(textField)
        addSubview(container)
        
        container.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.bottom.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    @objc private func handlePrefixTap() {
        onPrefixTap?()
    }
    
    func updatePrefix(flag: String, code: String) {
        flagLabel.text = flag
        prefixLabel.text = code
    }
    
    func getPrefix() -> String {
        return prefixLabel.text ?? "+90"
    }

    
    func getPrefixFrame() -> CGRect {
        // Find the prefix button among subviews if needed, or return a consistent frame
        // Since it's in a stack view, we can find it
        return subviews.first?.subviews.first?.frame ?? .zero
    }
}

fileprivate final class CustomCountryPickerView: UIView {
    
    var onSelection: ((String, String) -> Void)?
    
    private let countries = [
        ("\("country_tr".localized) (+90)", "+90", "🇹🇷"),
        ("\("country_de".localized) (+49)", "+49", "🇩🇪"),
        ("\("country_uk".localized) (+44)", "+44", "🇬🇧"),
        ("\("country_fr".localized) (+33)", "+33", "🇫🇷"),
        ("\("country_al".localized) (+355)", "+355", "🇦🇱")
    ]
    
    private let stackView: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.spacing = 0
        return s
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupUI() {
        backgroundColor = UIColor(red: 0.07, green: 0.05, blue: 0.15, alpha: 1.0)
        layer.cornerRadius = 8
        layer.borderWidth = 1
        layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor
        clipsToBounds = true
        
        // Shadow
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 10
        
        addSubview(stackView)
        stackView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        for country in countries {
            let btn = UIButton(type: .system)
            btn.backgroundColor = .clear
            btn.contentHorizontalAlignment = .leading
            
            let label = UILabel()
            label.text = "\(country.2)  \(country.0)"
            label.textColor = .white
            label.font = .systemFont(ofSize: 13, weight: .medium)
            
            btn.addSubview(label)
            label.snp.makeConstraints { make in
                make.leading.trailing.equalToSuperview().inset(12)
                make.centerY.equalToSuperview()
            }
            
            btn.snp.makeConstraints { $0.height.equalTo(44) }
            btn.addAction(UIAction(handler: { [weak self] _ in
                self?.onSelection?(country.2, country.1)
            }), for: .touchUpInside)
            
            // Add separator except for last
            stackView.addArrangedSubview(btn)
            
            if country != countries.last! {
                let sep = UIView()
                sep.backgroundColor = UIColor.white.withAlphaComponent(0.05)
                sep.snp.makeConstraints { $0.height.equalTo(1) }
                stackView.addArrangedSubview(sep)
            }
        }
    }
}
extension BecomeGuideViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == phoneField.textField {
            // Only numbers allowed
            let allowedCharacters = CharacterSet.decimalDigits
            let characterSet = CharacterSet(charactersIn: string)
            if !string.isEmpty && !allowedCharacters.isSuperset(of: characterSet) {
                return false
            }
            
            // Get current raw digits
            let currentText = textField.text ?? ""
            let currentDigits = currentText.replacingOccurrences(of: " ", with: "")
            
            let nsString = currentDigits as NSString
            // Calculate the range in digits (not formatted text)
            let digitsBefore = currentText.prefix(range.location).replacingOccurrences(of: " ", with: "").count
            let digitsInRange = currentText[currentText.index(currentText.startIndex, offsetBy: range.location)..<currentText.index(currentText.startIndex, offsetBy: range.location + range.length)].replacingOccurrences(of: " ", with: "").count
            
            let newDigits = nsString.replacingCharacters(in: NSRange(location: digitsBefore, length: digitsInRange), with: string)
            
            // Limit to 10 digits
            if newDigits.count > 10 { return false }
            
            // Format: 5XX XXX XX XX
            textField.text = formatPhoneNumber(newDigits)
            
            // Send editing changed action
            textField.sendActions(for: .editingChanged)
            return false
        }
        return true
    }
    
    private func formatPhoneNumber(_ digits: String) -> String {
        var result = ""
        for (i, char) in digits.enumerated() {
            if i == 3 || i == 6 || i == 8 {
                result.append(" ")
            }
            result.append(char)
        }
        return result
    }
}

