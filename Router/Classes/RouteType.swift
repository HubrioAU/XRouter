//
//  RouteType
//  XRouter
//

import Foundation

/**
 Defines the minimum requirements for describing a list of routes.
 - Note: Your Route enum should inherit from this protocol.
 
 ```swift
 enum MyRoutes: RouteType {
     case homePage
     case profilePage(profileID: Int)
     ...
 ```
 */
public protocol RouteType: Equatable {
    
    // MARK: - Properties
    
    /// Route name.
    /// - Note: Default implementation provided.
    var identifier: String { get }
    
    /// Include parameters when calculating uniqueness.
    var uniqueOnParameters: Bool { get }
    
    // MARK: - Methods
    
    ///
    /// Register a URL matcher group.
    ///
    /// Example:
    /// ```
    /// return .group(["website.com", "sales.website.com"]) {
    ///     $0.map("products") { .allProducts(page: $0.query("page") ?? 0) }
    ///     $0.map("products/{category}/") { try .productsShowcase(category: $0.param("category")) }
    ///     $0.map("user/*/logout") { .userLogout }
    /// }
    /// ```
    ///
    static func registerURLs() -> URLMatcherGroup<Self>?
    
}
    
extension RouteType {
        
    // MARK: - Equatable
    
    /// Equatable (default: Compares on String representation of self)
    public static func == (_ lhs: Self, _ rhs: Self) -> Bool {
        return lhs.identifier == rhs.identifier
    }

}

extension RouteType {
    
    // MARK: - Computed properties
    
    /// Route name. Example: `myProfileView(withID: Int)` becomes "myProfileView"
    public var name: String {
        return String(describing: self).components(separatedBy: "(")[0]
    }
    
}

extension RouteType {
    
    // MARK: - Default implementation
    
    /// Unique identifier for equality checks. (default: includes parameters)
    public var identifier: String {
        if uniqueOnParameters {
            return String(describing: self)
        }
        
        return name
    }
    
    /// Includes any parameters when calculating uniqueness. (default: true)
    public var uniqueOnParameters: Bool {
        return true
    }
    
    /// Register URLs (default: none)
    public static func registerURLs() -> URLMatcherGroup<Self>? {
        return nil
    }
    
}
