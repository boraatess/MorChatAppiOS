//
//  ViewExtensions.swift
//  MorChatApp
//
//  Created by bora ateş on 9.02.2026.
//

import Foundation
import UIKit

extension UIViewController {
    
    /// Generic alert helper
    /// - Parameters:
    ///   - title: Alert başlığı
    ///   - message: Alert mesajı
    ///   - actions: (title, style, handler) tuple array
    func presentAlert( title: String?,message: String?,) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        present(alert, animated: true)
    }

    func showAutoDismissAlert(title: String?, message: String, duration: TimeInterval,
        completion: (() -> Void)? = nil ) {
           let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
           
           present(alert, animated: true)
           
           DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
               alert.dismiss(animated: true, completion: completion)
           }
      
    }
    
    
}
