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
    func performTransition(to newViewController: UIViewController,
                           from currentViewController: UIViewController,
                           transitionIdentifier: String,
                           animated: Bool)
    
}
