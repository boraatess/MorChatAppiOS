//
//  SplashDIContainer.swift
//  MorChatApp
//
//  Created by bora ateş on 21.01.2026.
//

import Foundation


final class SplashDIContainer {

    private let appDIContainer: AppDIContainer

    init(appDIContainer: AppDIContainer) {
        self.appDIContainer = appDIContainer
    }

    func makeSplashViewController(
        onFinish: @escaping () -> Void
    ) -> SplashViewController {
        SplashViewController(viewModel: makeSplashViewModel())
        
    }

    // Eğer ViewModel kullanacaksan
    func makeSplashViewModel() -> SplashViewModel {
        SplashViewModel()
        
    }
}
