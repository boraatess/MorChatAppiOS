import UIKit
import SnapKit

final class CheckboxView: UIView {
    var isChecked: Bool = false {
        didSet { updateUI() }
    }
    
    var onToggle: ((Bool) -> Void)?
    var onLabelTap: (() -> Void)?
    
    private let checkButton = UIButton(type: .system)
    private let textLabel = UILabel()
    
    init(text: String) {
        super.init(frame: .zero)
        setupUI(text: text)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupUI(text: String) {
        checkButton.tintColor = .white
        checkButton.addTarget(self, action: #selector(toggle), for: .touchUpInside)
        
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: text.count))
        
        textLabel.attributedText = attributedString
        textLabel.textColor = .white
        textLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        textLabel.numberOfLines = 0
        textLabel.isUserInteractionEnabled = true
        
        // Custom label tap gesture
        let labelTap = UITapGestureRecognizer(target: self, action: #selector(labelTapped))
        textLabel.addGestureRecognizer(labelTap)
        
        addSubview(checkButton)
        addSubview(textLabel)
        
        checkButton.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
            make.size.equalTo(20)
        }
        
        textLabel.snp.makeConstraints { make in
            make.leading.equalTo(checkButton.snp.trailing).offset(12)
            make.trailing.equalToSuperview()
            make.top.bottom.equalToSuperview().inset(4)
        }
        
        updateUI()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(toggle))
        addGestureRecognizer(tap)
    }
    
    @objc private func toggle() {
        isChecked.toggle()
        onToggle?(isChecked)
    }
    
    @objc private func labelTapped() {
        if let tapAction = onLabelTap {
            tapAction()
        } else {
            // If no label tap provided, just toggle works
            toggle()
        }
    }
    
    private func updateUI() {
        let iconName = isChecked ? "checkmark.square" : "square"
        checkButton.setImage(UIImage(systemName: iconName), for: .normal)
    }
}
