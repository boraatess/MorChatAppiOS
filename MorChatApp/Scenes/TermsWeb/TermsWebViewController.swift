import UIKit
import WebKit
import SnapKit

final class TermsWebViewController: UIViewController {
    
    private let webView = WKWebView()
    private let navBarView = UIView()
    private let titleLabel = UILabel()
    private let backButton = UIButton(type: .system)
    
    private let urlString: String
    private let pageTitle: String
    
    init(urlString: String, pageTitle: String) {
        self.urlString = urlString
        self.pageTitle = pageTitle
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadURL()
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
        view.backgroundColor = .clear
        
        // Setup Navigation Bar
        navBarView.backgroundColor = UIColor(red: 0.45, green: 0.05, blue: 0.65, alpha: 1.0)
        view.addSubview(navBarView)
        
        navBarView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(view.safeAreaInsets.top > 0 ? 90 : 70) // Handle safe area
        }
        
        backButton.setImage(UIImage(systemName: "arrow.left"), for: .normal)
        backButton.tintColor = .white
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        navBarView.addSubview(backButton)
        
        backButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().offset(-12)
            make.size.equalTo(24)
        }
        
        titleLabel.text = pageTitle
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        navBarView.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(backButton)
        }
        
        // Setup WebView
        view.addSubview(webView)
        webView.snp.makeConstraints { make in
            make.top.equalTo(navBarView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        let topInset = view.safeAreaInsets.top
        navBarView.snp.updateConstraints { make in
            make.height.equalTo(topInset + 44)
        }
    }
    
    private func loadURL() {
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
    
    @objc private func backTapped() {
        if let nav = navigationController {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
}
