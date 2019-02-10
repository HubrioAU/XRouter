//
//  MatchedURL
//  XRouter
//

import Foundation

/**
 A URL that has been matched to a registered `RouteType` route.
 
 Used for shortcuts when mapping registered URLs routes.
 
 - Note: For use when handling routing parameters.
 - See: `RouteType.registerURLs(...)`
 
 Usage:
 ```swift
 // Path parameters
 let str: String = try $0.param("myParam")
 let int: Int = try $0.param("id")
 
 // Query string parameters
 let str: String? = $0.query("myParam")
 let int: Int? = $0.query("myParam")
 ```
 */
public class MatchedURL {
    
    /// Associated URL
    public let rawURL: URL
    
    /// Query string parameter shortcuts
    private lazy var queryItems: [String: String] = {
        var queryItems = [String: String]()
        
        if let parts = URLComponents(url: rawURL, resolvingAgainstBaseURL: false),
            let queryParts = parts.queryItems {
            for queryPart in queryParts {
                if let value = queryPart.value {
                    queryItems[queryPart.name] = value
                }
            }
        }
        
        return queryItems
    }()
    
    /// Path parameters storage
    private let parameters: [String: String]
    
    /// Initialiser
    internal init(for url: URL, namedParameters: [String: String]) {
        self.rawURL = url
        self.parameters = namedParameters
    }
    
    // MARK: - Methods
    
    /// Retrieve a named parameter as a `String`
    public func param(_ name: String) throws -> String {
        if let parameter = parameters[name] {
            return parameter
        }
        
        throw RouterError.missingRequiredPathParameter(parameter: name)
    }
    
    /// Retrieve a named parameter as an `Int`
    public func param(_ name: String) throws -> Int {
        let stringParam: String = try param(name)
        
        if let intParam = Int(stringParam) {
            return intParam
        }
        
        throw RouterError.requiredIntegerParameterWasNotAnInteger(parameter: name, stringValue: stringParam)
    }
    
    /// Retrieve a query string parameter as a `String`
    public func query(_ name: String) -> String? {
        return queryItems[name]
    }
    
    /// Retrieve a query string parameter as an `Int`
    public func query(_ name: String) -> Int? {
        if let queryItem = queryItems[name] {
            return Int(queryItem)
        }
        
        return nil
    }
    
}
