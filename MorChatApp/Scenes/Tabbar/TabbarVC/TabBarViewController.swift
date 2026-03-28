//
//  TabBarViewController.swift
//  MorChatApp
//
//  Created by bora ateş on 21.01.2026.
//

import Foundation
import UIKit


class TabBarViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Safe area beyaz arka plan
        view.backgroundColor = UIColor.black
        
        // Appearance setup
        setupAppearance()
        
        // Tab bar controller view controllers
        setupTabBar()
        
        // Icon ve title spacing fix (bireysel item üzerinden, SE dahil)
        setupTabBarItemsInsets()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Appearance
    private func setupAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.black
        
        appearance.backgroundEffect = nil // blur kapat
        appearance.shadowColor = .clear
        
        // Stil uygulama
        applyStyle(appearance.stackedLayoutAppearance)
        applyStyle(appearance.inlineLayoutAppearance)
        applyStyle(appearance.compactInlineLayoutAppearance)
        
        tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }
        
        tabBar.isTranslucent = false
        tabBar.backgroundColor = UIColor.black
    }
    
    private func applyStyle(_ itemAppearance: UITabBarItemAppearance) {
        itemAppearance.selected.iconColor = UIColor.App.tabbarSelectedColor
        itemAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.App.tabbarSelectedColor,
            .font: UIFont.systemFont(ofSize: 10, weight: .semibold)
        ]
        
        itemAppearance.normal.iconColor = UIColor.white
        itemAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 10)
        ]
    }
    
    // MARK: - Tab bar items spacing (SE ve küçük ekranlar için)
    private func setupTabBarItemsInsets() {
        guard let items = tabBar.items else { return }
        DispatchQueue.main.async {
            for item in items {
                item.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -2)
                item.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
            }
        }
    }
    
    // MARK: - Setup Tabs
    private func setupTabBar() {
        let homeVC = BaseNavigationController(rootViewController: HomeViewController())
        homeVC.navigationBar.isHidden = true
        homeVC.tabBarItem = UITabBarItem(
            title: "Home",
            image: UIImage(named: "morchat_logo")?.withRenderingMode(.alwaysTemplate),
            selectedImage: UIImage(named: "morchat_logo")?.withRenderingMode(.alwaysTemplate)
        )
        
        let notifiesController = BaseNavigationController(rootViewController: NotificationsVC())
        notifiesController.navigationBar.isHidden = true
        notifiesController.tabBarItem = UITabBarItem(
            title: "Notifications",
            image: UIImage(named: "notifications")?.withRenderingMode(.alwaysTemplate),
            selectedImage: UIImage(named: "notifications")?.withRenderingMode(.alwaysTemplate)
        )
        
        let favsController = BaseNavigationController(rootViewController: FavoritesViewController())
        favsController.navigationBar.isHidden = true
        favsController.tabBarItem = UITabBarItem(
            title: "Favorites",
            image: UIImage(named: "favorite")?.withRenderingMode(.alwaysTemplate),
            selectedImage: UIImage(named: "favorite")?.withRenderingMode(.alwaysTemplate)
        )
        
        let profileController = BaseNavigationController(rootViewController: ProfileViewController())
        profileController.navigationBar.isHidden = true
        profileController.tabBarItem = UITabBarItem(
            title: "Profile",
            image: UIImage(named: "account_circle")?.withRenderingMode(.alwaysTemplate),
            selectedImage: UIImage(named: "account_circle")?.withRenderingMode(.alwaysTemplate)
        )
        
        viewControllers = [
            homeVC,
            notifiesController,
            favsController,
            profileController
        ]
    }
}


/* | Sekme       | SF Symbol                |
 | ----------- | ------------------------ |
 | Canlı       | `flame` / `flame.fill`   |
 | Bildirimler | `bell` / `bell.fill`     |
 | Beğeniler   | `heart` / `heart.fill`   |
 | Hesabım     | `person` / `person.fill` |
*/

