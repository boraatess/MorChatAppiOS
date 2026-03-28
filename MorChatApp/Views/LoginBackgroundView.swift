import UIKit
import SnapKit

final class LoginBackgroundView: UIView {
    
    private let tags = [
        "Psychology", "Child Development", "Politics", "Spiritual Talks", "Astrology", "Dream",
        "Economy", "Real Estate", "Health", "Technology", "Plumber", "Electrician", "Cars", "Beauty / Cosmetics"
    ]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        // Match the deep purple background of the mockup
        self.backgroundColor = UIColor(red: 0.43, green: 0.11, blue: 0.66, alpha: 1.0)
        setupBackgroundTags()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupBackgroundTags() {
        self.clipsToBounds = true
        let rows = 14 // Reduced density
        for row in 0..<rows {
            let stack = UIStackView()
            stack.axis = .horizontal
            stack.spacing = 16 // Increased spacing
            
            let shuffled = tags.shuffled()
            let amount = 8 
            
            for i in 0..<amount {
                let text = shuffled[i]
                let container = createTag(text: text)
                stack.addArrangedSubview(container)
            }
            
            addSubview(stack)
            
            let offsetX = row % 2 == 0 ? -60 : -140
            stack.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(row * 52 - 40) // Increased vertical spacing
                make.leading.equalToSuperview().offset(offsetX)
                make.height.equalTo(34)
            }
        }
        
        let darkOverlay = UIView()
        darkOverlay.backgroundColor = UIColor(white: 0, alpha: 0.15)
        addSubview(darkOverlay)
        darkOverlay.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
    
    private let tagColors: [UIColor] = [
        UIColor(red: 0.2, green: 0.45, blue: 0.85, alpha: 0.8),  // Blue
        UIColor(red: 0.9, green: 0.5, blue: 0.2, alpha: 0.8),   // Orange/Yellow
        UIColor(red: 0.85, green: 0.2, blue: 0.5, alpha: 0.8),  // Pink/Magenta
        UIColor(red: 0.4, green: 0.2, blue: 0.6, alpha: 0.8),   // Dark Purple
        UIColor(red: 0.1, green: 0.6, blue: 0.5, alpha: 0.8),   // Teal
        UIColor(red: 0.7, green: 0.3, blue: 0.8, alpha: 0.8)    // Bright Purple
    ]
    
    private func createTag(text: String) -> UIView {
        let container = UIView()
        container.backgroundColor = tagColors.randomElement()!
        container.layer.cornerRadius = 17
        
        // Match icons
        let icons = ["questionmark.circle.fill", "face.smiling.fill", "shield.fill", "key.fill", "moon.stars.fill", "cloud.fill", "chart.line.uptrend.xyaxis", "house.fill", "flame.fill", "cpu", "wrench.fill", "bolt.fill", "car.fill", "diamond.fill"]
        
        let img = UIImageView(image: UIImage(systemName: icons.randomElement()!))
        img.tintColor = UIColor.white.withAlphaComponent(0.7)
        img.contentMode = .scaleAspectFit
        
        let lbl = UILabel()
        lbl.text = text
        lbl.textColor = UIColor.white.withAlphaComponent(0.7)
        lbl.font = .systemFont(ofSize: 11, weight: .semibold)
        
        container.addSubview(img)
        container.addSubview(lbl)
        
        img.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.size.equalTo(14)
        }
        
        lbl.snp.makeConstraints { make in
            make.leading.equalTo(img.snp.trailing).offset(6)
            make.trailing.equalToSuperview().inset(12)
            make.centerY.equalToSuperview()
        }
        
        return container
    }
}
