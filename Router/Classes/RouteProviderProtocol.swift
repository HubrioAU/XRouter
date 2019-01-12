//
//  RouteProviderProtocol.swift
//  XRouter
//
//  Created by Reece Como on 5/1/19.
//

import Foundation

/**
 Defines the minimum requirements for describing a Route list.
 
 Your Route list enum should inherit from this protocol.
 
 ```swift
 enum MyRoutes: RouteProvider {
     case homePage
     case profilePage(profileID: Int)
     ...
 ```
 */
public protocol RouteProvider: Equatable {
    
    // MARK: - Properties
    
    ///
    /// Route identifier
    /// - Note: Default implementation provided
    ///
    var name: String { get }
    
    ///
    /// Transition type
    ///
    var transition: RouteTransition { get }
    
    // MARK: - Methods
    
    ///
    /// Prepare the route for transition and return the view controller
    ///  to transition to on the view hierachy.
    ///
    /// - Note: Throwing an error here will cancel the transition
    ///
    func prepareForTransition(from viewController: UIViewController) throws -> UIViewController
    
    ///
    /// Register a URL matcher group
    ///
    static func registerURLs() -> Router<Self>.URLMatcherGroup?
    
}

extension RouteProvider {
    
    // MARK: - Computed properties
    
    /// Example: `myProfileView(withID: Int)` becomes "myProfileView"
    public var baseName: String {
        return String(describing: self).components(separatedBy: "(")[0]
    }
    
    /// Route name (default: `baseName`)
    public var name: String {
        return baseName
    }
    
    public static func registerURLs() -> Router<Self>.URLMatcherGroup? {
        return nil
    }
    
}

extension RouteProvider {
    
    // MARK: - Equatable
    
    /// Equatable (default: Compares on `name` property)
    public static func == (_ lhs: Self, _ rhs: Self) -> Bool {
        return lhs.name == rhs.name
    }
    
}
