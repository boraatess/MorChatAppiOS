//
//  SplashCoordinator.swift
//  MorChatApp
//
//  Created by bora ateş on 21.01.2026.
//

import Foundation
import UIKit


final class SplashCoordinator: Coordinator {
    
    let navigationController: UINavigationController
    private let diContainer: SplashDIContainer
    
    var onFinish: (() -> Void)?
    
    init(
        navigationController: UINavigationController,
        diContainer: SplashDIContainer
    ) {
        self.navigationController = navigationController
        self.diContainer = diContainer
    }
    
    func start() {
        let viewModel = diContainer.makeSplashViewModel()
        let vc = SplashViewController(viewModel: viewModel)
        
        vc.onFinish = { [weak self] in
            print("✅ coordinator finished")

            let isLogin = UserDefaults.standard.value(forKey: "isLogin") as? Bool ?? false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                // self?.goToMainTab()
                
                if isLogin {
                    self?.goToMainTab()
                    
                }else {
                    self?.goOnboarding()

                }
                
            })
            
        }
        
        navigationController.setViewControllers([vc], animated: false)
    }
    
    private func goOnboarding() {
        print("🚀 goOnboarding called")
        
        let onboarding = OnBoardingViewController()
        // navigationController.setViewControllers([onboarding], animated: true)
        onboarding.modalPresentationStyle = .overFullScreen
        navigationController.present(onboarding, animated: true)
        
    }
    
    private func goToMainTab() {
        print("🚀 goToMainTab called")
        print("NAV:", navigationController)
        
        let tabBarVC = TabBarViewController()
        navigationController.navigationBar.isHidden = true
        navigationController.setViewControllers([tabBarVC], animated: true)
    }
    
}

