//
//  RouterCustomTransitionDelegate.swift
//  Router
//
//  Created by Reece Como on 5/1/19.
//

import Foundation

/**
 Custom transition delegate
 */
public protocol RouterCustomTransitionDelegate: class {
    
    /// Perform a custom transition
    func performTransition(to viewController: UIViewController,
                           from currentNavigationController: UINavigationController,
                           transitionIdentifier: String,
                           animated: Bool)
    
}
