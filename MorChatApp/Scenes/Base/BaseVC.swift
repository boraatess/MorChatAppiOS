//
//  BaseVC.swift
//  MorChatApp
//
//  Created by bora ateş on 12.02.2026.
//

import Foundation
import UIKit
import SnapKit

class BaseVC: UIViewController {
    
    let headerView: HeaderView = {
        let view = HeaderView()
        return view
    }()
    
    let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    let loadingContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        view.layer.cornerRadius = 12
        view.isHidden = true
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        headerView.output = self
        layout()
        setupLoadingUI()
        setupGradient()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    func showLoading() {
        DispatchQueue.main.async {
            self.loadingContainer.isHidden = false
            self.loadingIndicator.startAnimating()
            self.view.bringSubviewToFront(self.loadingContainer)
        }
    }
    
    func hideLoading() {
        DispatchQueue.main.async {
            self.loadingIndicator.stopAnimating()
            self.loadingContainer.isHidden = true
        }
    }
    
    func showAutoDismissAlert(title: String, message: String, duration: TimeInterval = 2.0) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            alert.dismiss(animated: true)
        }
    }
    
    func setupGradient() {
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor(red: 48/255, green: 20/255, blue: 90/255, alpha: 1).cgColor,
            UIColor(red: 95/255, green: 30/255, blue: 150/255, alpha: 1).cgColor
        ]
        gradient.frame = view.bounds
        view.layer.insertSublayer(gradient, at: 0)
    }
    
}

extension BaseVC {
    
    private func layout() {
        view.addSubview(headerView)
        headerView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(40)
        }
    }
    
    private func setupLoadingUI() {
        view.addSubview(loadingContainer)
        loadingContainer.addSubview(loadingIndicator)
        
        loadingContainer.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(80)
        }
        
        loadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
}

extension BaseVC: HeaderViewOutput {
    
    func didTapCoinButton() {
        let vc = BuyTokenViewController()
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
