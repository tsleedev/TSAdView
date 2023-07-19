//
//  UIViewController+Preview.swift
//  TSAdManagerUIKitDemo
//
//  Created by TAE SU LEE on 2023/07/19.
//

import SwiftUI

extension UIViewController {
    private struct Preview: UIViewControllerRepresentable {
        let viewController: UIViewController

        func makeUIViewController(context: Context) -> UIViewController {
            return viewController
        }

        func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        }
    }

    public func showPreview() -> some View {
        Preview(viewController: self)
    }
}
