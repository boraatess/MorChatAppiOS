//
//  SceneDelegate.swift
//  MorChatApp
//
//  Created by bora ateş on 21.01.2026.
//

import Foundation
import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private var appCoordinator: AppCoordinator?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        
        guard let windowScene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: windowScene)
        let navigationController = BaseNavigationController()

        let appDIContainer = AppDIContainer()
        let coordinator = AppCoordinator(
            navigationController: navigationController,
            appDIContainer: appDIContainer
        )

        self.appCoordinator = coordinator

        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        self.window = window
        
        coordinator.start()

        print("ROOT NAV:", navigationController)
        
        // Start Call Manager to listen for incoming calls
        CallManager.shared.start()
    }

 
    
    func appStart() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        
        let window = UIWindow(windowScene: windowScene)

        let navigationController = BaseNavigationController()

        let appDIContainer = AppDIContainer()
        let coordinator = AppCoordinator(
            navigationController: navigationController,
            appDIContainer: appDIContainer
        )

        self.appCoordinator = coordinator
        coordinator.start()
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        self.window = window
    }
    
    
}
