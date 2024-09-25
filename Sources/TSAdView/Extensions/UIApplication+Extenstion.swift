//
//  UIApplication+Extenstion.swift
//  TSAdView
//
//  Created by TAE SU LEE on 9/25/24.
//

import UIKit

extension UIApplication {
    public class func topViewController(base: UIViewController = UIApplication.shared.connectedScenes
        .filter { $0.activationState == .foregroundActive }
        .compactMap { $0 as? UIWindowScene }
        .first?.windows
        .filter { $0.isKeyWindow }
        .first?.rootViewController ?? UIViewController()) -> UIViewController {
        
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController ?? UIViewController())
        }
        
        if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return topViewController(base: selected)
        }
        
        if let presented = base.presentedViewController {
            return topViewController(base: presented)
        }
        
        return base
    }
}
