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
    
    ///
    /// Route identifier
    /// - Note: Default implementation provided
    ///
    var name: String { get }
    
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
    
    // MARK: - Computed properties
    
    /// Example: `myProfileView(withID: Int)` becomes "myProfileView"
    public var baseName: String {
        return String(describing: self).components(separatedBy: "(")[0]
    }
    
    /// Route name (default: `baseName`)
    public var name: String {
        return baseName
    }
    
    /// Register URLs (default: none)
    public static func registerURLs() -> URLMatcherGroup<Self>? {
        return nil
    }
    
}

extension RouteType {
    
    // MARK: - Equatable
    
    /// Equatable (default: Compares on `name` property)
    public static func == (_ lhs: Self, _ rhs: Self) -> Bool {
        return lhs.name == rhs.name
    }
    
}
