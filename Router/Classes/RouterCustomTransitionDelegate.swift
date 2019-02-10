//
//  RouterCustomTransitionDelegate
//  XRouter
//

import UIKit

/**
 Delegate used to configure custom transitions in `Router`
 */
public protocol RouterCustomTransitionDelegate: class {
    
    // MARK: - Delegate methods
    
    /// Perform a custom transition.
    /// Completion handler *must* be triggered.
    func performTransition(to viewController: UIViewController,
                           from sourceViewController: UIViewController,
                           transition: RouteTransition,
                           animated: Bool,
                           completion: ((Error?) -> Void)?)
    
}
