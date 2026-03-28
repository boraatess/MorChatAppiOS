//
//  OnboardingViewModel.swift
//  MorChatApp
//
//  Created by bora ateş on 9.02.2026.
//

import Foundation

protocol OnboardingViewModelInputProtocol: AnyObject {
    func fetchItems()
}

protocol OnboardingViewModelOutputProtocol: AnyObject {
    func configureItems(with items: [OnboardingItem])
}

    
class OnboardingViewModel: OnboardingViewModelInputProtocol {
    
    weak var output: OnboardingViewModelOutputProtocol?
    
    func fetchItems() {
        
        let onboardingItems: [OnboardingItem] = [
            .init(iconName: "video", 
                  title: "onboarding_title_1".localized,
                  description: "onboarding_desc_1".localized),
            .init(iconName: "flame", 
                  title: "onboarding_title_2".localized,
                  description: "onboarding_desc_2".localized),
            .init(iconName: "heart", 
                  title: "onboarding_title_3".localized,
                  description: "onboarding_desc_3".localized),
            .init(iconName: "star", 
                  title: "onboarding_title_4".localized,
                  description: "onboarding_desc_4".localized),
            .init(iconName: "shield", 
                  title: "onboarding_title_5".localized,
                  description: "onboarding_desc_5".localized)
        ]

        self.output?.configureItems(with: onboardingItems)
        
        
    }
    
    
}
