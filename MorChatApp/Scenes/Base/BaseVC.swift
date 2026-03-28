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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        headerView.output = self
        layout()
        setupGradient()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
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
    
}

extension BaseVC: HeaderViewOutput {
    
    func didTapCoinButton() {
        let vc = BuyTokenViewController()
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
}
