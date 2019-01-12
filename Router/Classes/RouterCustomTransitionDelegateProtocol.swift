//
//  XRouterCustomTransitionDelegateProtocol.swift
//  XRouter
//
//  Created by Reece Como on 5/1/19.
//

import UIKit

/**
 Delegate methods that can be used to configure custom transitions in `XRouter.Router`.
 */
public protocol RouterCustomTransitionDelegate: class {
    
    // MARK: - Delegate methods
    
    /// Perform a custom transition
    func performTransition(to viewController: UIViewController,
                           from parentViewController: UIViewController,
                           transition: RouteTransition,
                           animated: Bool)
    
}
