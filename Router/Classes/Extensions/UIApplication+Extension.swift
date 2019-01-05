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
    
    ///
    /// Fetch root view controller
    ///
    internal var rootViewController: UIViewController? {
        return keyWindow?.rootViewController
    }
    
    ///
    /// Fetch the top-most view controller
    /// - Author: Stan Feldman
    ///
    internal func topViewController(for baseViewController: UIViewController? = UIApplication.shared.rootViewController) -> UIViewController? {
        if let navigationController = baseViewController as? UINavigationController {
            //
            // Inside a UINavigationController
            //
            return topViewController(for: navigationController.visibleViewController)
        } else if let tabBarController = baseViewController as? UITabBarController {
            //
            // Inside a UITabBarController
            //
            let moreNavigationController = tabBarController.moreNavigationController
            
            if let top = moreNavigationController.topViewController, top.view.window != nil {
                //
                // Inside the UITabBarControllers "more navigation" controller
                //
                return topViewController(for: top)
            } else if let selected = tabBarController.selectedViewController {
                //
                // Inside the top level selected view controller
                //
                return topViewController(for: selected)
            }
        } else if let presentedViewController = baseViewController?.presentedViewController {
            //
            // Presented view controller
            //
            return topViewController(for: presentedViewController)
        }
        
        return baseViewController
    }
    
}
