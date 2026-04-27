//
//  TabBarViewController.swift
//  MorChatApp
//
//  Created by bora ateş on 21.01.2026.
//

import Foundation
import UIKit
import SwiftUI


class TabBarViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        setupAppearance()
        setupTabBar()
        setupTabBarItemsInsets()
        
        NotificationCenter.default.addObserver(self, selector: #selector(languageChanged), name: .languageChanged, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func languageChanged() {
        updateTabBarTitles()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Appearance
    private func setupAppearance() {
        
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        
        // 🔥 ARKA PLAN SİYAH
        appearance.backgroundColor = .black
        appearance.shadowColor = .clear
        appearance.backgroundEffect = nil
        
        // Stil uygula
        applyStyle(appearance.stackedLayoutAppearance)
        applyStyle(appearance.inlineLayoutAppearance)
        applyStyle(appearance.compactInlineLayoutAppearance)
        
        tabBar.standardAppearance = appearance
        
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }
        
        tabBar.isTranslucent = false
        
        // ❌ ÇAKIŞMA YAPANLAR KALDIRILDI
        // tabBar.tintColor
        // tabBar.unselectedItemTintColor
        // tabBar.barTintColor
        
    }
    
    private func applyStyle(_ itemAppearance: UITabBarItemAppearance) {
        
        let selectedColor = UIColor.App.tabbarSelectedColor
        
        // ✅ Seçili item
        itemAppearance.selected.iconColor = selectedColor
        itemAppearance.selected.titleTextAttributes = [
            .foregroundColor: selectedColor,
            .font: UIFont.systemFont(ofSize: 12, weight: .bold)
        ]
        
        // ✅ Seçili olmayan item
        itemAppearance.normal.iconColor = .white
        itemAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 12, weight: .regular)
        ]
    }
    
    // MARK: - Tab bar items spacing
    private func setupTabBarItemsInsets() {
        DispatchQueue.main.async {
            guard let items = self.tabBar.items else { return }
            for item in items {
                item.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 0)
                item.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            }
        }
    }
    
    // MARK: - Setup Tabs
    private func setupTabBar() {
        
        let userType = UserDefaults.standard.string(forKey: "userType") ?? "user"
        
        // HOME
        let homeRoot: UIViewController = (userType == "guide") ? GuideHomeViewController() : HomeViewController()
        let homeVC = BaseNavigationController(rootViewController: homeRoot)
        homeVC.navigationBar.isHidden = true
        homeVC.tabBarItem = UITabBarItem(
            title: "tab_home".localized,
            image: UIImage(named: "morchat_logo")?.withRenderingMode(.alwaysTemplate),
            selectedImage: UIImage(named: "morchat_logo")?.withRenderingMode(.alwaysTemplate)
        )
        
        // NOTIFICATIONS
        let notifiesController = BaseNavigationController(rootViewController: NotificationsVC())
        notifiesController.navigationBar.isHidden = true
        notifiesController.tabBarItem = UITabBarItem(
            title: "tab_notifications".localized,
            image: UIImage(named: "notifications")?.withRenderingMode(.alwaysTemplate),
            selectedImage: UIImage(named: "notifications")?.withRenderingMode(.alwaysTemplate)
        )
        
        // HISTORY (guide)
        let publicationHistory = BaseNavigationController(rootViewController: PublicationHistoryVC())
        publicationHistory.navigationBar.isHidden = true
        publicationHistory.tabBarItem = UITabBarItem(
            title: "tab_history".localized,
            image: UIImage(named: "favorite")?.withRenderingMode(.alwaysTemplate),
            selectedImage: UIImage(named: "favorite")?.withRenderingMode(.alwaysTemplate)
        )
        
        // USER PROFILE
        let userProfileController = BaseNavigationController(rootViewController: ProfileViewController())
        userProfileController.navigationBar.isHidden = true
        userProfileController.tabBarItem = UITabBarItem(
            title: "tab_profile".localized,
            image: UIImage(named: "account_circle")?.withRenderingMode(.alwaysTemplate),
            selectedImage: UIImage(named: "account_circle")?.withRenderingMode(.alwaysTemplate)
        )
        
        // GUIDE PROFILE
        let publisherProfile = BaseNavigationController(rootViewController: PublisherProfileVC())
        publisherProfile.navigationBar.isHidden = true
        publisherProfile.tabBarItem = UITabBarItem(
            title: "tab_profile".localized,
            image: UIImage(named: "account_circle")?.withRenderingMode(.alwaysTemplate),
            selectedImage: UIImage(named: "account_circle")?.withRenderingMode(.alwaysTemplate)
        )
        
        if userType == "guide" {
            viewControllers = [
                homeVC,
                notifiesController,
                publicationHistory,
                publisherProfile
            ]
        } else {
            // FAVORITES
            let favsController = BaseNavigationController(rootViewController: FavoritesViewController())
            favsController.navigationBar.isHidden = true
            favsController.tabBarItem = UITabBarItem(
                title: "tab_favorites".localized,
                image: UIImage(named: "favorite")?.withRenderingMode(.alwaysTemplate),
                selectedImage: UIImage(named: "favorite")?.withRenderingMode(.alwaysTemplate)
            )
            
            viewControllers = [
                homeVC,
                notifiesController,
                favsController,
                userProfileController
            ]
        }
    }
    
    private func updateTabBarTitles() {
        guard let viewControllers = viewControllers else { return }
        let userType = UserDefaults.standard.string(forKey: "userType") ?? "user"
        
        if userType == "guide" {
            viewControllers[0].tabBarItem.title = "tab_home".localized
            viewControllers[1].tabBarItem.title = "tab_notifications".localized
            viewControllers[2].tabBarItem.title = "tab_history".localized
            viewControllers[3].tabBarItem.title = "tab_profile".localized
        } else {
            viewControllers[0].tabBarItem.title = "tab_home".localized
            viewControllers[1].tabBarItem.title = "tab_notifications".localized
            viewControllers[2].tabBarItem.title = "tab_favorites".localized
            viewControllers[3].tabBarItem.title = "tab_profile".localized
        }
    }
}

#Preview {
    // Navigasyon yapısı içinde göstermek daha stabildir
    let tabBar = TabBarViewController()
    return tabBar.asPreview()
        .ignoresSafeArea()
}



/* | Sekme       | SF Symbol                |
 | ----------- | ------------------------ |
 | Canlı       | `flame` / `flame.fill`   |
 | Bildirimler | `bell` / `bell.fill`     |
 | Beğeniler   | `heart` / `heart.fill`   |
 | Hesabım     | `person` / `person.fill` |
*/

