//
//  ColorExtensions.swift
//  MorChatApp
//
//  Created by bora ateş on 15.02.2026.
//

import Foundation
import UIKit

extension UIColor {

    convenience init(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat = 1.0) {
        self.init(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: a)
    }

    private static func dynamicColor(light: UIColor, dark: UIColor) -> UIColor {
        UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? dark : light
        }
    }
    
    enum App {

        static let primary = UIColor(r: 255, g: 79, b: 135)
        static let tabbarSelectedColor = primary
        static let tabbarBgColor = dynamicColor(
            light: UIColor(r: 248, g: 246, b: 252),
            dark: UIColor(r: 18, g: 14, b: 32)
        )

        static let screenBackground = dynamicColor(
            light: UIColor(r: 248, g: 246, b: 252),
            dark: UIColor(r: 13, g: 10, b: 24)
        )
        static let elevatedBackground = dynamicColor(
            light: .white,
            dark: UIColor(r: 28, g: 22, b: 45)
        )
        static let secondaryElevatedBackground = dynamicColor(
            light: UIColor(r: 240, g: 236, b: 247),
            dark: UIColor(r: 38, g: 31, b: 60)
        )
        static let cardBackground = dynamicColor(
            light: .white,
            dark: UIColor(r: 33, g: 26, b: 53)
        )
        static let inputBackground = dynamicColor(
            light: UIColor(r: 242, g: 239, b: 247),
            dark: UIColor(r: 44, g: 36, b: 67)
        )
        static let border = dynamicColor(
            light: UIColor.black.withAlphaComponent(0.08),
            dark: UIColor.white.withAlphaComponent(0.10)
        )
        static let separator = dynamicColor(
            light: UIColor.black.withAlphaComponent(0.10),
            dark: UIColor.white.withAlphaComponent(0.10)
        )
        static let shadow = dynamicColor(
            light: UIColor.black.withAlphaComponent(0.12),
            dark: UIColor.black.withAlphaComponent(0.35)
        )
        static let primaryText = dynamicColor(
            light: UIColor(r: 24, g: 20, b: 35),
            dark: UIColor(r: 247, g: 244, b: 252)
        )
        static let secondaryText = dynamicColor(
            light: UIColor(r: 93, g: 88, b: 112),
            dark: UIColor(r: 183, g: 177, b: 201)
        )
        static let tertiaryText = dynamicColor(
            light: UIColor(r: 122, g: 117, b: 141),
            dark: UIColor(r: 144, g: 138, b: 164)
        )
        static let statusOnlineBackground = dynamicColor(
            light: UIColor(r: 224, g: 247, b: 229),
            dark: UIColor(r: 30, g: 72, b: 45)
        )
        static let statusOnlineText = dynamicColor(
            light: UIColor(r: 29, g: 122, b: 58),
            dark: UIColor(r: 154, g: 233, b: 179)
        )
        static let statusOfflineBackground = dynamicColor(
            light: UIColor(r: 253, g: 227, b: 229),
            dark: UIColor(r: 82, g: 36, b: 42)
        )
        static let statusOfflineText = dynamicColor(
            light: UIColor(r: 179, g: 47, b: 63),
            dark: UIColor(r: 255, g: 178, b: 187)
        )
        static let chromeOverlay = UIColor.white.withAlphaComponent(0.24)
        static let actionBackground = dynamicColor(
            light: UIColor(r: 87, g: 47, b: 115),
            dark: UIColor(r: 104, g: 61, b: 138)
        )
        static let actionForeground = UIColor.white
    }
}
