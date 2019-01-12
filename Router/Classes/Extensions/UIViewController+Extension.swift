//
//  UIViewController+Extension.swift
//  XRouter
//
//  Created by Reece Como on 5/1/19.
//

import UIKit

/**
 UIViewController extension
 */
internal extension UIViewController {
    
    // MARK: - Methods
    
    ///
    /// Is this view controller active in the UIApplication hierachy
    ////
    internal func isActive() -> Bool {
        return UIApplication.shared.rootViewController === getRootAncestor()
    }
    
    ///
    /// Is this view controller an ancestor of mine?
    /// - Note: Recursively checks parent, uncle/aunt, and then grantparent view controllers
    ///
    internal func hasAncestor(_ viewController: UIViewController) -> Bool {
        if let ancestor = getNextAncestor() {
            return ancestor === viewController || ancestor.hasChild(viewController) || ancestor.hasAncestor(viewController)
        }
        
        return false
    }
    
    ///
    /// Get the next ancestor view controller
    ///
    /// - Note: This was written as a method call instead of a dynamic property
    ///         because it I felt it helped indicate that it is relatively expensive.
    ///
    internal func getNextAncestor() -> UIViewController? {
        if let navigationController = navigationController {
            // The nearest ancestor in the view controller hierarchy that is a navigation controller.
            return navigationController
        }
        
        if let splitViewController = splitViewController {
            // The nearest ancestor in the view controller hierarchy that is a split view controller.
            return splitViewController
        }
        
        if let tabBarController = tabBarController {
            // The nearest ancestor in the view controller hierarchy that is a tab bar controller.
            return tabBarController
        }
        
        if let presentingViewController = presentingViewController {
            // The view controller that presented this view controller.
            return presentingViewController
        }
        
        // This is an orphan view controller
        return nil
    }
    
    // MARK: - Implementation
    
    ///
    /// Get the root level ancestor view controller
    ///
    /// - Note: This was written as a method call instead of a dynamic property
    ///         because it I felt it helped indicate that it is relatively expensive.
    ///
    private func getRootAncestor() -> UIViewController? {
        var currentViewController = self
        
        while let ancestorViewController = currentViewController.getNextAncestor() {
            currentViewController = ancestorViewController
        }
        
        return currentViewController
    }
    
    /// Is this view controller a direct child of mine
    private func hasChild(_ viewController: UIViewController) -> Bool {
        // Check navigation controller
        if let navigationController = self as? UINavigationController {
            return navigationController.viewControllers.contains(viewController)
        }
        
        // Check split view controllers
        if let splitViewControllers = (self as? UISplitViewController)?.viewControllers {
            for splitViewController in splitViewControllers {
                if splitViewController === viewController || splitViewController.hasChild(viewController) {
                    return true
                }
            }
        }
        
        // Check tab bar view controllers
        if let tabBarViewControllers = (self as? UITabBarController)?.viewControllers {
            for tabBarViewController in tabBarViewControllers {
                if tabBarViewController === viewController || tabBarViewController.hasChild(viewController) {
                    return true
                }
            }
        }
        
        // Check if presenting anything
        if viewController == presentedViewController {
            return true
        }
        
        return false
    }
    
}
