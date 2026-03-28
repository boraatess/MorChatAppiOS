import UIKit
import SnapKit

protocol SharedTagsCloudViewDelegate: AnyObject {
    func didToggleTag(_ tag: String, isSelected: Bool)
    func selectedTag(_ tagName: String, icon: String, color: UIColor)
    func didUpdateSelectedCount(_ count: Int)
}

extension SharedTagsCloudViewDelegate {
    func didToggleTag(_ tag: String, isSelected: Bool) {}
    func didUpdateSelectedCount(_ count: Int) {}
}

final class SharedTagsCloudView: UIView {
    
    struct TagInfo {
        let name: String
        let color: UIColor
        let icon: String?
    }
    
    weak var delegate: SharedTagsCloudViewDelegate?
    
    // Default categories used everywhere
    static let categories: [TagInfo] = [
        .init(name: "Spiritual Talks", color: .systemTeal, icon: "moon.stars.fill"),
        .init(name: "Dream", color: .systemPurple, icon: "cloud.fill"),
        .init(name: "Mystery", color: .darkGray, icon: "questionmark.circle.fill"),
        .init(name: "Books", color: .systemOrange, icon: "book.fill"),
        .init(name: "Poetry", color: .systemPink, icon: "pencil"),
        .init(name: "Astrology", color: .systemIndigo, icon: "stars"),
        .init(name: "Psychology", color: .systemYellow, icon: "brain.head.profile"),
        .init(name: "Love", color: .systemRed, icon: "heart.fill"),
        .init(name: "Travel", color: .orange, icon: "airplane"),
        .init(name: "Romance", color: .systemPink, icon: "heart.text.square.fill"),
        .init(name: "Martial Arts", color: .red, icon: "bolt.fill"),
        .init(name: "Real Estate", color: .brown, icon: "house.fill"),
        .init(name: "Health", color: .systemGreen, icon: "heart.circle.fill"),
        .init(name: "Economy", color: .cyan, icon: "chart.bar.fill"),
        .init(name: "Technology", color: .systemBlue, icon: "cpu"),
        .init(name: "Plumber", color: .systemBlue, icon: "wrench.fill"),
        .init(name: "Electrician", color: .systemOrange, icon: "bolt.fill"),
        .init(name: "Beauty / Cosmetics", color: .systemPink, icon: "sparkles"),
        .init(name: "Child Development", color: .orange, icon: "face.smiling.fill"),
        .init(name: "Music", color: .systemBlue, icon: "music.note"),
        .init(name: "Cars", color: .gray, icon: "car.fill"),
        .init(name: "Food", color: .systemGreen, icon: "fork.knife"),
        .init(name: "Fashion", color: .systemPink, icon: "bag.fill"),
        .init(name: "Football", color: .systemGreen, icon: "figure.soccer")
    ]
    
    private var selectedTags = Set<String>()
    private var buttons = [UIButton]()
    
    var selectionLimit: Int? // Optional limit (e.g., max 5)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTags()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func setSelected(_ tags: [String]) {
        self.selectedTags = Set(tags)
        updateButtonSelection()
    }
    
    func getSelectedTags() -> [String] {
        return Array(selectedTags)
    }
    
    private func updateButtonSelection() {
        for btn in buttons {
            let title = btn.accessibilityLabel ?? ""
            let isSel = selectedTags.contains(title)
            btn.alpha = isSel ? 1.0 : 0.4
            btn.layer.borderWidth = isSel ? 2 : 0
            btn.layer.borderColor = UIColor.white.cgColor
        }
    }
    
    private func setupTags() {
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        let spacingX: CGFloat = 6
        let spacingY: CGFloat = 8
        let tagHeight: CGFloat = 34
        
        // Fix for UIScreen.main warning
        let screenWidth = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.screen.bounds.width ?? 375
        let maxWidth = screenWidth - 32
        
        var rows = [[UIView]]()
        var rowViews = [UIView]()
        var rowWidths = [CGFloat]()
        var currentRowWidth: CGFloat = 0
        
        for tag in SharedTagsCloudView.categories {
            let btn = createTagButton(info: tag)
            buttons.append(btn)
            
            let bWidth = calculateWidth(for: tag.name) + 40
            btn.frame.size = CGSize(width: bWidth, height: tagHeight)
            
            if currentX + bWidth > maxWidth {
                rows.append(rowViews)
                rowWidths.append(currentRowWidth - spacingX)
                rowViews = []
                currentRowWidth = 0
                currentX = 0
                currentY += tagHeight + spacingY
            }
            
            btn.frame.origin = CGPoint(x: currentX, y: currentY)
            rowViews.append(btn)
            currentX += bWidth + spacingX
            currentRowWidth += bWidth + spacingX
        }
        
        if !rowViews.isEmpty {
            rows.append(rowViews)
            rowWidths.append(currentRowWidth - spacingX)
        }
        
        currentY = 0
        for (i, rViews) in rows.enumerated() {
            let rWidth = rowWidths[i]
            var xOffset = (maxWidth - rWidth) / 2
            for v in rViews {
                v.frame.origin = CGPoint(x: xOffset, y: currentY)
                addSubview(v)
                xOffset += v.frame.width + spacingX
            }
            currentY += tagHeight + spacingY
        }
        
        self.snp.makeConstraints { make in
            make.height.equalTo(currentY)
        }
    }
    
    private func calculateWidth(for text: String) -> CGFloat {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.sizeToFit()
        return label.frame.width
    }
    
    private func createTagButton(info: TagInfo) -> UIButton {
        let b = UIButton(type: .custom)
        b.backgroundColor = info.color
        b.layer.cornerRadius = 17
        b.accessibilityLabel = info.name
        
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 6
        stack.isUserInteractionEnabled = false
        
        if let icon = info.icon {
            let iv = UIImageView(image: UIImage(systemName: icon))
            iv.tintColor = .white
            iv.contentMode = .scaleAspectFit
            iv.snp.makeConstraints { $0.size.equalTo(14) }
            stack.addArrangedSubview(iv)
        }
        
        let l = UILabel()
        l.text = info.name
        l.textColor = .white
        l.font = .systemFont(ofSize: 12, weight: .bold)
        stack.addArrangedSubview(l)
        
        b.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        b.addTarget(self, action: #selector(tagTapped(_:)), for: .touchUpInside)
        return b
    }
    
    @objc private func tagTapped(_ sender: UIButton) {
        let title = sender.accessibilityLabel ?? ""
        
        let isSelected = selectedTags.contains(title)
        
        if !isSelected {
            if let limit = selectionLimit, selectedTags.count >= limit { return }
            selectedTags.insert(title)
        } else {
            selectedTags.remove(title)
        }
        
        updateButtonSelection()
        delegate?.didToggleTag(title, isSelected: !isSelected)
        delegate?.didUpdateSelectedCount(selectedTags.count)
        
        // Find info for the selected tag
        let tagInfo = SharedTagsCloudView.categories.first(where: { $0.name == title })
        let iconName = tagInfo?.icon ?? ""
        let color = tagInfo?.color ?? .gray
        delegate?.selectedTag(title, icon: iconName, color: color)
    }
    
}
