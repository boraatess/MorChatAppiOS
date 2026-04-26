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
                item.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -2)
                item.imageInsets = UIEdgeInsets(top: 6, left: 8, bottom: -6, right: -8)
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
            title: "Home",
            image: UIImage(named: "morchat_logo")?.withRenderingMode(.alwaysTemplate),
            selectedImage: UIImage(named: "morchat_logo")?.withRenderingMode(.alwaysTemplate)
        )
        
        // NOTIFICATIONS
        let notifiesController = BaseNavigationController(rootViewController: NotificationsVC())
        notifiesController.navigationBar.isHidden = true
        notifiesController.tabBarItem = UITabBarItem(
            title: "Notifications",
            image: UIImage(named: "notifications")?.withRenderingMode(.alwaysTemplate),
            selectedImage: UIImage(named: "notifications")?.withRenderingMode(.alwaysTemplate)
        )
        
        // HISTORY (guide)
        let publicationHistory = BaseNavigationController(rootViewController: PublicationHistoryVC())
        publicationHistory.navigationBar.isHidden = true
        publicationHistory.tabBarItem = UITabBarItem(
            title: "History",
            image: UIImage(named: "favorite")?.withRenderingMode(.alwaysTemplate),
            selectedImage: UIImage(named: "favorite")?.withRenderingMode(.alwaysTemplate)
        )
        
        // USER PROFILE
        let userProfileController = BaseNavigationController(rootViewController: ProfileViewController())
        userProfileController.navigationBar.isHidden = true
        userProfileController.tabBarItem = UITabBarItem(
            title: "Profile",
            image: UIImage(named: "account_circle")?.withRenderingMode(.alwaysTemplate),
            selectedImage: UIImage(named: "account_circle")?.withRenderingMode(.alwaysTemplate)
        )
        
        // GUIDE PROFILE
        let publisherProfile = BaseNavigationController(rootViewController: PublisherProfileVC())
        publisherProfile.navigationBar.isHidden = true
        publisherProfile.tabBarItem = UITabBarItem(
            title: "My Account",
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
                title: "Favorites",
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

