import Foundation

final class LocalizationManager {
    
    static let shared = LocalizationManager()
    
    private let languageKey = "selected_language"
    
    var currentLanguage: String {
        get {
            return UserDefaults.standard.string(forKey: languageKey) ?? "en"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: languageKey)
            updateBundle(language: newValue)
        }
    }
    
    private var bundle: Bundle = .main
    
    private init() {
        updateBundle(language: currentLanguage)
    }
    
    private func updateBundle(language: String) {
        guard let path = Bundle.main.path(forResource: language, ofType: "lproj"),
              let newBundle = Bundle(path: path) else {
            bundle = .main
            return
        }
        bundle = newBundle
    }
    
    func localizedString(for key: String) -> String {
        return bundle.localizedString(forKey: key, value: nil, table: nil)
    }
}
