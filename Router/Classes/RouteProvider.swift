//
//  RouteProvider.swift
//  Router
//
//  Created by Reece Como on 5/1/19.
//

import Foundation

/**
 Route Provider
 */
public protocol RouteProvider {
    
    ///
    /// Route name
    /// - Note: Default implementation provided
    ///
    var name: String { get }
    
    ///
    /// Transition type
    ///
    var transition: RouteTransition { get }
    
    ///
    /// Prepare the route for transition and return the view controller
    ///  to transition to on the view hierachy
    ///
    /// - Note: Throwing an error here will cancel the transition
    ///
    func prepareForTransition(from viewController: UIViewController) throws -> UIViewController
    
}

extension RouteProvider {
    
    /// Enum case identifier as a `String`
    /// - Example: `case myAwesomeView(withID: Int)` becomes "myAwesomeView"
    public var name: String {
        return String(describing: self).components(separatedBy: "(")[0]
    }
    
}
