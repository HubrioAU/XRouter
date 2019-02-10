//
//  Route.URLPathMapper
//  XRouter
//

import Foundation

/**
 Router URL Path Mapper.
 
 - Note: All static paths are resolved before dynamic paths.
 
 Usage:
 ```
 // Static path
 $0.map("/users") { .allUsers }
 
 // Dynamic path
 $0.map("/users/{id}/profile") { try .profile(withID: $0.param("id")) }
 */
public class URLPathMapper<Route: RouteType> {
    
    // MARK: - Typealiases
    
    /// Mapping for a dynamic path
    internal typealias DynamicPathMapping = ((MatchedURL) throws -> Route)
    
    /// Mapping for a static path
    internal typealias StaticPathMapping = (() throws -> Route)
    
    // MARK: - Storage
    
    /// Dynamic path patterns
    private var dynamicPathPatterns = [PathPattern: DynamicPathMapping]()
    
    /// Simple path patterns
    private var staticPathPatterns = [PathPattern: StaticPathMapping]()
    
    // MARK: - Methods
    
    /// Map a path to a route
    /// - Note: With the `MatchedURL` passed as a parameter in the callback
    public func map(_ pathPattern: PathPattern, _ route: @escaping (MatchedURL) throws -> Route) {
        dynamicPathPatterns[pathPattern] = route
    }
    
    /// Map a path to a route
    public func map(_ pathPattern: PathPattern, _ route: @escaping () throws -> Route) {
        staticPathPatterns[pathPattern] = route
    }
    
    // MARK: - Implementation
    
    /// Match a Route from a URL.
    internal func match(_ url: URL) throws -> Route? {
        // Check static paths
        for (pattern, resolveStaticMapping) in staticPathPatterns {
            if match(pattern, url) != nil {
                return try resolveStaticMapping()
            }
        }
        
        // Check dynamic paths
        for (pattern, resolveDynamicMapping) in dynamicPathPatterns {
            if let matchedLink = match(pattern, url) {
                return try resolveDynamicMapping(matchedLink)
            }
        }
        
        return nil
    }
    
    /// Compare a pattern to a URL
    /// - Returns: A matched routable link
    private func match(_ pattern: PathPattern, _ url: URL) -> MatchedURL? {
        let pathComponents = url.pathComponents.compactMap { $0 == "/" ? nil : $0 }
        var parameters = [String: String]()
        
        for (index, patternComponent) in pattern.components.enumerated() {
            guard let pathComponent = pathComponents[safe: index],
                patternComponent.matches(pathComponent) else {
                    return nil
            }
            
            // Store the parameters
            if case let .parameter(name) = patternComponent {
                parameters[name] = pathComponent
            }
        }
        
        return MatchedURL(for: url, namedParameters: parameters)
    }
    
}
