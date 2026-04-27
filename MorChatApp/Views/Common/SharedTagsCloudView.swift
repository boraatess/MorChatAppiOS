
import SnapKit
import UIKit


protocol SharedTagsCloudViewDelegate: AnyObject {
    func didToggleTag(_ tag: String, isSelected: Bool)
    func selectedTag(_ id: Int, tagName: String, icon: String, color: UIColor)
    func didUpdateSelectedCount(_ count: Int)
}

extension SharedTagsCloudViewDelegate {
    func didToggleTag(_ tag: String, isSelected: Bool) {}
    func didUpdateSelectedCount(_ count: Int) {}
}

final class SharedTagsCloudView: UIView {
    
    struct TagInfo {
        let id: Int
        let name: String
        let color: UIColor
        let icon: String?
    }
    
    weak var delegate: SharedTagsCloudViewDelegate?
    
    // Static shared categories updated from Firestore
    static var categories: [TagInfo] = []
    
    static var defaultCategories: [TagInfo] {
        return [
            .init(id: 0, name: "tag_spiritual".localized, color: .systemTeal, icon: "moon.stars.fill"),
            .init(id: 1, name: "tag_dream".localized, color: .systemPurple, icon: "cloud.fill"),
            .init(id: 2, name: "tag_mystery".localized, color: .darkGray, icon: "questionmark.circle.fill"),
            .init(id: 3, name: "tag_books".localized, color: .systemOrange, icon: "book.fill"),
            .init(id: 4, name: "tag_poetry".localized, color: .systemPink, icon: "pencil"),
            .init(id: 5, name: "tag_astrology".localized, color: .systemIndigo, icon: "stars"),
            .init(id: 6, name: "tag_psychology".localized, color: .systemYellow, icon: "brain.head.profile"),
            .init(id: 7, name: "tag_love".localized, color: .systemRed, icon: "heart.fill"),
            .init(id: 8, name: "tag_travel".localized, color: .orange, icon: "airplane"),
            .init(id: 9, name: "tag_romance".localized, color: .systemPink, icon: "heart.text.square.fill"),
            .init(id: 10, name: "tag_martial_arts".localized, color: .red, icon: "bolt.fill"),
            .init(id: 11, name: "tag_real_estate".localized, color: .brown, icon: "house.fill"),
            .init(id: 12, name: "tag_health".localized, color: .systemGreen, icon: "heart.circle.fill"),
            .init(id: 13, name: "tag_economy".localized, color: .cyan, icon: "chart.bar.fill"),
            .init(id: 14, name: "tag_technology".localized, color: .systemBlue, icon: "cpu"),
            .init(id: 15, name: "tag_plumber".localized, color: .systemBlue, icon: "wrench.fill"),
            .init(id: 16, name: "tag_electrician".localized, color: .systemOrange, icon: "bolt.fill"),
            .init(id: 17, name: "tag_beauty".localized, color: .systemPink, icon: "sparkles"),
            .init(id: 18, name: "tag_child".localized, color: .orange, icon: "face.smiling.fill"),
            .init(id: 19, name: "tag_music".localized, color: .systemBlue, icon: "music.note"),
            .init(id: 20, name: "tag_cars".localized, color: .gray, icon: "car.fill"),
            .init(id: 21, name: "tag_food".localized, color: .systemGreen, icon: "fork.knife"),
            .init(id: 22, name: "tag_fashion".localized, color: .systemPink, icon: "bag.fill"),
            .init(id: 23, name: "tag_football".localized, color: .systemGreen, icon: "figure.soccer")
        ]
    }
    
    private var selectedTags = Set<String>()
    private var buttons = [UIButton]()
    
    var selectionLimit: Int? // Optional limit (e.g., max 5)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTags()
    }
    
    func configure(with categories: [TagInfo]) {
        
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func setSelected(_ tags: [String]) {
        self.selectedTags = Set(tags)
        updateButtonSelection()
    }
    
    func getSelectedTags() -> [String] {
        return Array(selectedTags)
    }
    
    func refreshTags() {
        setupTags()
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
        subviews.forEach { $0.removeFromSuperview() }
        buttons.removeAll()
        
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        let spacingX: CGFloat = 6
        let spacingY: CGFloat = 8
        let tagHeight: CGFloat = 34
        
        let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
        let screenWidth = scene?.screen.bounds.width ?? 375
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
        
        self.snp.remakeConstraints { make in
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
        
        if let tagInfo = SharedTagsCloudView.categories.first(where: { $0.name == title }) {
            delegate?.selectedTag(tagInfo.id, tagName: title, icon: tagInfo.icon ?? "", color: tagInfo.color)
        }
    }
}
