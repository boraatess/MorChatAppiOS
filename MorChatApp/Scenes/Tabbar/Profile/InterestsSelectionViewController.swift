import UIKit
import SnapKit

struct InterestModel {
    let id: Int
    let name: String
    let icon: String
    let color: UIColor
    
}

protocol InterestsSelectionDelegate: AnyObject {
    func didUpdateInterests(_ tags: [InterestModel])
}

final class InterestsSelectionViewController: UIViewController {

    weak var delegate: InterestsSelectionDelegate?
    private var selectedInterests: [InterestModel] = []
    
    // MARK: - UI Elements
    private let dragIndicator: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(white: 1.0, alpha: 0.3)
        v.layer.cornerRadius = 2
        return v
    }()
    
    private let titleLabel: UILabel = {
        let l = UILabel()
        let text = "From All Ages, From All Subjects"
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(.foregroundColor, value: UIColor.white, range: (text as NSString).range(of: "From All Ages,"))
        attributedString.addAttribute(.foregroundColor, value: UIColor.systemPink, range: (text as NSString).range(of: "From All Subjects"))
        l.attributedText = attributedString
        l.font = .systemFont(ofSize: 22, weight: .bold)
        l.textAlignment = .center
        l.numberOfLines = 0
        return l
    }()
    
    private let subtitleLabel: UILabel = {
        let l = UILabel()
        l.text = "Find guides according to your interests,\nvideo chat on any topic you wish.\nYou will not see different guides outside your choices, you can update your choices later from the profile screen."
        l.font = .systemFont(ofSize: 12, weight: .regular)
        l.textColor = UIColor(white: 0.8, alpha: 1.0)
        l.textAlignment = .center
        l.numberOfLines = 0
        return l
    }()
    
    private let tagsCloudView = SharedTagsCloudView()
    
    private let saveButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Save", for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        b.backgroundColor = UIColor(red: 0.1, green: 0.05, blue: 0.2, alpha: 1.0)
        b.layer.cornerRadius = 14
        return b
    }()

    // MARK: - Lifecycle
    init(currentInterests: [InterestModel]) {
        super.init(nibName: nil, bundle: nil)
        self.selectedInterests = currentInterests
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupConstraints()
        setupActions()
        fetchTags()
        
    }
    
    private func fetchTags() {
        FirestoreService.shared.fetchPublisherTags { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let tags):
                    let tagInfos = tags.map { tag -> SharedTagsCloudView.TagInfo in
                        // Map Firestore tags to UI-specific TagInfo
                        // We can assign default colors/icons because Firestore doesn't provide them yet
                        let defaultIcon = SharedTagsCloudView.defaultCategories.first(where: { $0.name == tag.name })?.icon ?? "number"
                        let defaultColor = SharedTagsCloudView.defaultCategories.first(where: { $0.name == tag.name })?.color ?? .systemIndigo
                        return .init(id: tag.id, name: tag.name, color: defaultColor, icon: defaultIcon)
                    }
                    self.tagsCloudView.configure(with: tagInfos)
                    let names = self.selectedInterests.map { $0.name }
                    self.tagsCloudView.setSelected(names)
                case .failure(let error):
                    print("Error fetching tags: \(error)")
                }
            }
        }
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.2, green: 0.1, blue: 0.4, alpha: 1.0)
        view.layer.cornerRadius = 24
        view.clipsToBounds = true
        
        view.addSubview(dragIndicator)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        
        tagsCloudView.delegate = self
        view.addSubview(tagsCloudView)
        
        view.addSubview(saveButton)
    }
    
    private func setupConstraints() {
        dragIndicator.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.centerX.equalToSuperview()
            make.width.equalTo(40)
            make.height.equalTo(4)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(dragIndicator.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(32)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(32)
        }
        
        tagsCloudView.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(12)
        }
        
        saveButton.snp.makeConstraints { make in
            make.top.equalTo(tagsCloudView.snp.bottom).offset(32)
            make.leading.trailing.equalToSuperview().inset(32)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(24)
            make.height.equalTo(52)
        }
    }
    
    private func setupActions() {
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
    }
    
    @objc private func saveTapped() {
        delegate?.didUpdateInterests(selectedInterests)
        dismiss(animated: true)
    }
}

extension InterestsSelectionViewController: SharedTagsCloudViewDelegate {
    
    func selectedTag(_ id: Int, tagName: String, icon: String, color: UIColor) {
        
        if let index = selectedInterests.firstIndex(where: { $0.name == tagName }) {
            selectedInterests.remove(at: index)
        } else {
            if selectedInterests.count >= 5 {
                showLimitAlert()
                // Refresh cloud check state because the tag was visually toggled before delegate call usually
                tagsCloudView.setSelected(selectedInterests.map { $0.name })
                return
            }
            
            selectedInterests.append(InterestModel(id: id, name: tagName, icon: icon, color: color))
            
        }
        
    }
    
    func selectedTag(_ tagName: String, icon: String, color: UIColor) {
       
    }
    
    private func showLimitAlert() {
        let alert = UIAlertController(title: "Selection Limit", message: "You can select up to 5 interests.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - Helper Views
// SharedTagsCloudView is used from Common components.

