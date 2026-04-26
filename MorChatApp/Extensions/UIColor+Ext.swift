//
//  UIColor+Ext.swift
//  MorChatApp
//
//  Created by antigravity on 20.04.2026.
//

import UIKit

extension UIColor {
    
    // MARK: - Brand Colors
    static let appPurple = UIColor(red: 0.43, green: 0.11, blue: 0.66, alpha: 1.0)
    static let appLightPurple = UIColor(red: 0.70, green: 0.40, blue: 0.85, alpha: 1.0)
    static let appDarkPurple = UIColor(red: 0.25, green: 0.05, blue: 0.40, alpha: 1.0)
    
    static let indigoPurple = UIColor(red: 0.169, green: 0.103, blue: 0.421, alpha: 1.0)
    

    // MARK: - Secondary Colors
    static let appOrange = UIColor(red: 1.00, green: 0.60, blue: 0.00, alpha: 1.0)
    static let appPink = UIColor(red: 1.00, green: 0.20, blue: 0.60, alpha: 1.0)
    
    // MARK: - Neutral Colors
    static let appGray = UIColor(white: 0.95, alpha: 1.0)
    static let appDarkGray = UIColor(white: 0.30, alpha: 1.0)
    
    // MARK: - Hex Initialization
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if hexSanitized.hasPrefix("#") {
            hexSanitized.remove(at: hexSanitized.startIndex)
        }
        
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let r, g, b, a: CGFloat
        if hexSanitized.count == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0
            a = 1.0
        } else if hexSanitized.count == 8 {
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0
        } else {
            r = 0; g = 0; b = 0; a = 1.0
        }
        
        self.init(red: r, green: g, blue: b, alpha: a)
    }
}
