//
//  UITabBarController+Extension.swift
//  XRouter
//
//  Created by Reece Como on 24/1/19.
//

import UIKit

internal extension UITabBarController {
    
    /// Switch to the tab containing some some descendent view controller.
    internal func switchToTabIfNeeded(for descendantViewController: UIViewController) {
        if let newTabViewController = tabViewController(for: descendantViewController),
            selectedViewController !== newTabViewController {
            selectedViewController = newTabViewController
        }
    }
    
    // MARK: - Implementation
    
    /// Get the parent tab view controller containing some descendent view controller.
    private func tabViewController(for descendantViewController: UIViewController) -> UIViewController? {
        guard let viewControllers = viewControllers else {
            return nil
        }
        
        for viewController in viewControllers where viewController.getLowestCommonAncestor(with: descendantViewController) === viewController {
            return viewController
        }
        
        return nil
    }
    
}
