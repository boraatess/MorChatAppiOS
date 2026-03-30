//
//  SplashViewModel.swift
//  MorChatApp
//
//  Created by bora ateş on 21.01.2026.
//

import Foundation
import UIKit

protocol SplashViewModelInputprotocol: AnyObject {
    
}

protocol SplashViewModeloutputprotocol: AnyObject {
    func goTabbar()
    func didFinish()
    
}


class SplashViewModel {
    
    weak var output: SplashViewModeloutputprotocol?
    
    var onFinish: (() -> Void)?

    func start() {
        // Fetch dynamic tags from Firestore at startup
        FirestoreService.shared.fetchPublisherTags { [weak self] result in
            switch result {
            case .success(let tags):
                // Update SharedTagsCloudView categories dynamically
                let updatedCategories = tags.map { tag -> SharedTagsCloudView.TagInfo in
                    if let existing = SharedTagsCloudView.categories.first(where: { $0.name == tag.name }) {
                        return SharedTagsCloudView.TagInfo(id: tag.id, name: tag.name, color: existing.color, icon: existing.icon)
                    } else {
                        return SharedTagsCloudView.TagInfo(id: tag.id, name: tag.name, color: .systemPurple, icon: "star.fill")
                    }
                }
                
                DispatchQueue.main.async {
                    SharedTagsCloudView.categories = updatedCategories
                    print("✅ dynamic tags loaded: \(tags.count)")
                    self?.onFinish?()
                }
                
            case .failure(let error):
                print("❌ Error fetching tags: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self?.onFinish?()
                }
            }
        }
    }
    
    
}
