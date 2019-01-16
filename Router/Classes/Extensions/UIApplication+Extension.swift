//
//  UIApplication+Extension.swift
//  XRouter
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
    /// - Source: https://stackoverflow.com/a/50656239
    internal func getTopViewController(for baseViewController: UIViewController? = UIApplication.shared.rootViewController) -> UIViewController? {
        if let navigationController = baseViewController as? UINavigationController {
            return getTopViewController(for: navigationController.visibleViewController)
        }
        
        if let tabBarViewController = baseViewController as? UITabBarController,
            let selectedViewController = tabBarViewController.selectedViewController {
            return getTopViewController(for: selectedViewController)
        }
        
        if let presented = baseViewController?.presentedViewController {
            return getTopViewController(for: presented)
        }
        
        return baseViewController
    }
    
}
