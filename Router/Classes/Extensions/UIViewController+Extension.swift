//
//  UIViewController+Extension.swift
//  Router
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
    
    
    ///
    /// Get the next ancestor view controller
    ///
    /// - Note: This was written as a method call instead of a dynamic property
    ///         because it I felt it helped indicate that it is relatively expensive.
    ///
    private func getNextAncestor() -> UIViewController? {
        if let presentingViewController = presentingViewController {
            // The view controller that presented this view controller.
            return presentingViewController
        }
        
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
        
        // This is an orphan view controller
        return nil
    }
    
    /// Is this view controller a direct child of mine
    private func hasChild(_ viewController: UIViewController) -> Bool {
        if let navigationController = self as? UINavigationController {
            return navigationController.viewControllers.contains(viewController)
        }
        
        if let splitViewController = self as? UISplitViewController {
            return splitViewController.viewControllers.contains(viewController)
        }
        
        if let tabBarViewControllers = (self as? UITabBarController)?.viewControllers {
            return tabBarViewControllers.contains(viewController)
        }
        
        return false
    }
    
}


