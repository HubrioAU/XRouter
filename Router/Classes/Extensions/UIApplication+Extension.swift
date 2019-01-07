//
//  UIApplication+Extension.swift
//  Router
//
//  Created by Reece Como on 5/1/19.
//

import Foundation

/**
 UIApplication extension
 */
internal extension UIApplication {
    
    /// Shortcut for the root view controller
    internal var rootViewController: UIViewController? {
        return keyWindow?.rootViewController
    }
    
    /// Fetch the top-most view controller
    /// - Author: Stan Feldman
    internal func topViewController(for baseViewController: UIViewController? = UIApplication.shared.rootViewController) -> UIViewController? {
        if let navigationController = baseViewController as? UINavigationController {
            return topViewController(for: navigationController.visibleViewController)
        }
        
        if let tabBarController = baseViewController as? UITabBarController {
            let moreNavigationController = tabBarController.moreNavigationController
            
            if let top = moreNavigationController.topViewController, top.view.window != nil {
                return topViewController(for: top)
            }
            
            if let selected = tabBarController.selectedViewController {
                return topViewController(for: selected)
            }
        }
        
        if let presentedViewController = baseViewController?.presentedViewController {
            return topViewController(for: presentedViewController)
        }
        
        return baseViewController
    }
    
}
