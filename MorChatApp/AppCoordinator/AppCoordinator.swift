//
//  AppCoordinator.swift
//  MorChatApp
//
//  Created by bora ateş on 21.01.2026.
//

import Foundation
import UIKit

protocol Coordinator: AnyObject {
    var navigationController: UINavigationController { get }
    func start()
}


final class AppCoordinator: Coordinator {
    
    let navigationController: UINavigationController
    private let appDIContainer: AppDIContainer

    private var childCoordinators: [Coordinator] = []

    init(
        navigationController: UINavigationController,
        appDIContainer: AppDIContainer
    ) {
        self.navigationController = navigationController
        self.appDIContainer = appDIContainer
    }

    func start() {
        let splashCoordinator = SplashCoordinator(
            navigationController: navigationController,
            diContainer: appDIContainer.makeSplashDIContainer()
        )
        
        splashCoordinator.onFinish = { [weak self, weak splashCoordinator] in
            guard let self, let splashCoordinator else { return }
            self.removeChild(splashCoordinator)
        }
        
        childCoordinators.append(splashCoordinator)
        splashCoordinator.start()
    }

    func removeChild(_ coordinator: Coordinator) {
           childCoordinators.removeAll { $0 === coordinator }
    }
    
}

final class AppDIContainer {

    // MARK: - Global / Shared Services
    /*  lazy var apiClient: APIClient = APIClientImpl()
     lazy var authService: AuthService = AuthServiceImpl(apiClient: apiClient)
     lazy var analyticsService: AnalyticsService = AnalyticsServiceImpl()
     */
   
    lazy var userDefaults: UserDefaults = .standard

    // MARK: - Feature DI Containers

    func makeSplashDIContainer() -> SplashDIContainer {
        SplashDIContainer(appDIContainer: self)
    }
    
    /*
    func makeAuthDIContainer() -> AuthDIContainer {
        AuthDIContainer(appDIContainer: self)
    }

    func makeHomeDIContainer() -> HomeDIContainer {
        HomeDIContainer(appDIContainer: self)
    }

    func makeSettingsDIContainer() -> SettingsDIContainer {
        SettingsDIContainer(appDIContainer: self)
    }
    */
    
    
}
