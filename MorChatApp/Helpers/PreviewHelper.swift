//
//  PreviewHelper.swift
//  MorChatApp
//
//  Created by bora ateş on 16.04.2026.
//

import Foundation
// PreviewHelper.swift — projeye bir kere ekleyin

import SwiftUI

// UIViewController için
extension UIViewController {
    func asPreview() -> some View {
        ViewControllerPreview(viewController: self)
    }
}

// UIView için
extension UIView {
    func asPreview() -> some View {
        ViewPreview(view: self)
    }
}

// MARK: - Internal Wrappers

struct ViewControllerPreview: UIViewControllerRepresentable {
    let viewController: UIViewController
    
    func makeUIViewController(context: Context) -> UIViewController {
        viewController
    }
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

struct ViewPreview: UIViewRepresentable {
    let view: UIView
    
    func makeUIView(context: Context) -> UIView { view }
    func updateUIView(_ uiView: UIView, context: Context) {}
}
