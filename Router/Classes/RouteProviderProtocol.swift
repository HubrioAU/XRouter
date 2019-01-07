//
//  RouteProvider.swift
//  Router
//
//  Created by Reece Como on 5/1/19.
//

import Foundation

/**
 Route Provider
 
 - Note: The default implementations for `name` and `Equatable` make two
         instances of the same route with different parameters equal.

         E.g. `.profile(withID: "123") == .profile(withID: "456")`
 
         If you want a route parameter to indicate uniqueness, implement either
         `name` or `Equatable` in your RouteProvider.
 */
public protocol RouteProvider: Equatable {
    
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
    
    /// Route name (default: `baseName`)
    public var name: String {
        return baseName
    }
    
    /// Example: `myProfileView(withID: Int)` becomes "myProfileView"
    public var baseName: String {
        return String(describing: self).components(separatedBy: "(")[0]
    }
    
}

extension RouteProvider {
    
    // MARK: - Equatable
    
    /// Equatable (default: Compares on `name` property)
    public static func == (_ lhs: Self, _ rhs: Self) -> Bool {
        return lhs.name == rhs.name
    }
    
}
