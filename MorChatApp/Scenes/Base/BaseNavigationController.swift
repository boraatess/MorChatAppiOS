//
//  BaseNavigationController.swift
//  MorChatApp
//
//  Created by Antigravity on 24.03.2026.
//

import UIKit

class BaseNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.interactivePopGestureRecognizer?.delegate = self
    }

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        // Pushing yaparken swipe'ı geçici olarak kapatabiliriz (isteğe bağlı)
        super.pushViewController(viewController, animated: animated)
    }
}

extension BaseNavigationController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        // Sadece root view controller'da değilsek swipe back çalışmalı
        return viewControllers.count > 1
    }
}
