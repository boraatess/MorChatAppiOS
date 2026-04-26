import UIKit
import SnapKit

protocol PublisherEditValueDelegate: AnyObject {
    func didUpdateValue(type: PublisherEditType, value: String)
}

enum PublisherEditType {
    case nickname, about, phone, age
    
    var title: String {
        switch self {
        case .nickname: return "Takma Ad"
        case .about: return "Hakkımda"
        case .phone: return "Telefon Numarası"
        case .age: return "Yaş"
        }
    }
}

class PublisherEditValueVC: UIViewController {
    
    weak var delegate: PublisherEditValueDelegate?
    private let type: PublisherEditType
    private let currentValue: String
    
    private let containerView = UIView()
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = .boldSystemFont(ofSize: 18)
        l.textColor = .black
        return l
    }()
    
    private let textField: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .roundedRect
        tf.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        return tf
    }()
    
    private let textView: UITextView = {
        let tv = UITextView()
        tv.layer.cornerRadius = 8
        tv.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        tv.font = .systemFont(ofSize: 16)
        tv.isHidden = true
        return tv
    }()
    
    private let saveButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Güncelle"
        config.baseBackgroundColor = UIColor(red: 0.44, green: 0.20, blue: 0.55, alpha: 1.0)
        config.cornerStyle = .medium
        return UIButton(configuration: config)
    }()
    
    init(type: PublisherEditType, currentValue: String) {
        self.type = type
        self.currentValue = currentValue
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configure()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(titleLabel)
        view.addSubview(textField)
        view.addSubview(textView)
        view.addSubview(saveButton)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.leading.equalToSuperview().offset(16)
        }
        
        textField.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(50)
        }
        
        textView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(120)
        }
        
        saveButton.snp.makeConstraints { make in
            make.top.equalTo(textView.isHidden ? textField.snp.bottom : textView.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(50)
        }
        
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
    }
    
    private func configure() {
        titleLabel.text = type.title + " Düzenle"
        
        if type == .about {
            textView.isHidden = false
            textField.isHidden = true
            textView.text = currentValue
        } else {
            textView.isHidden = true
            textField.isHidden = false
            textField.text = currentValue
            if type == .age || type == .phone {
                textField.keyboardType = .numberPad
            }
        }
    }
    
    @objc private func saveTapped() {
        let value = type == .about ? textView.text : textField.text
        guard let finalValue = value, !finalValue.isEmpty else { return }
        
        delegate?.didUpdateValue(type: type, value: finalValue)
        dismiss(animated: true)
    }
}
