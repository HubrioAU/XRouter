//
//  RouterCustomTransitionDelegateProtocol.swift
//  Router
//
//  Created by Reece Como on 5/1/19.
//

import UIKit

/**
 Custom transition delegate
 */
public protocol RouterCustomTransitionDelegate: class {
    
    /// Perform a custom transition
    func performTransition(to viewController: UIViewController,
                           from parentViewController: UIViewController,
                           transition: RouteTransition,
                           animated: Bool)
    
}
