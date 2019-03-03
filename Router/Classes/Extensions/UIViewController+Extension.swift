//
//  UIViewController+Extension
//  XRouter
//

import UIKit

/**
 UIViewController extension
 */
internal extension UIViewController {
    
    // MARK: - Methods
    
    /// Child if this is a container view controller, otherwise self.
    /// - Note: Currently does not handle split view controller
    internal var topViewController: UIViewController {
        return presentedViewController?.topViewController
            ?? (self as? UITabBarController)?.selectedViewController?.topViewController
            ?? (self as? UINavigationController)?.visibleViewController?.topViewController
            ?? self
    }
    
    /// Dismiss then transition to descendant view controller.
    internal func transition(toDescendant viewController: UIViewController,
                             animated: Bool,
                             completion: @escaping () -> Void) {
        dismissIfNeeded(animated: animated) {
            // Switch tabs if this is a tab bar controller
            if let tabBarController = self as? UITabBarController {
                tabBarController.switchToTabIfNeeded(for: viewController)
            }
            
            completion()
        }
    }
    
    ///
    /// Get the lowest common ancestor between this and another view controller.
    ///
    /// - Returns: Lowest common ancestor, or `nil` if there is no common ancestor.
    ///
    internal func getNearestCommonAncestor(with viewController: UIViewController) -> UIViewController? {
        var currentABranch = self
        var currentBBranch = viewController
        
        var aBranch: [UIViewController] = [currentABranch]
        var bBranch: [UIViewController] = [currentBBranch]
        
        while let directParent = currentABranch.directParentViewController {
            currentABranch = directParent
            aBranch.append(directParent)
        }
        
        while let directParent = currentBBranch.directParentViewController {
            currentBBranch = directParent
            bBranch.append(directParent)
        }
        
        for aViewController in aBranch {
            for bViewController in bBranch where aViewController === bViewController {
                return aViewController
            }
        }
        
        return nil
    }
    
    // MARK: - Implementation
    
    ///
    /// Direct parent view controller
    ///
    /// In order, this goes: Navigation, SplitView, TabBar, Presenting
    ///
    private var directParentViewController: UIViewController? {
        return navigationController
            ?? splitViewController
            ?? tabBarController
            ?? presentingViewController
    }
    
    /// Dismiss modals. Always fires the completion handler.
    private func dismissIfNeeded(animated: Bool, completion: @escaping () -> Void) {
        if presentedViewController == nil {
            completion()
        } else {
            dismiss(animated: animated, completion: completion)
        }
    }
    
}
