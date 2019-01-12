//
//  MatchedRoutableLink.swift
//  XRouter
//
//  Created by Reece Como on 12/1/19.
//

import Foundation

/**
 A routable link that has been matched to a registerd `RouteProvider` route.
 
 - Note: For use when handling routing parameters.
 */
public class MatchedRoutableLink {
    
    /// Associated URL
    public let url: URL
    
    /// Query string parameter shortcuts
    private lazy var queryItems: [String: String] = {
        var queryItems = [String: String]()
        
        if let parts = URLComponents(url: url, resolvingAgainstBaseURL: false),
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
    
    // MARK: - Methods
    
    /// Initialiser
    init(for url: URL, namedParameters: [String: String]) {
        self.url = url
        self.parameters = namedParameters
    }
    
    /// Retrieve a String parameter
    func param(_ name: String) throws -> String {
        if let parameter = parameters[name] {
            return parameter
        }
        
        throw RouterError.missingRequiredParameterWhileUnwrappingURLRoute(parameter: name)
    }
    
    /// Retrieve an Int parameter
    func param(_ name: String) throws -> Int {
        let stringParam: String = try param(name)
        
        if let intParam = Int(stringParam) {
            return intParam
        }
        
        throw RouterError.requiredIntegerParameterWasNotAnInteger(parameter: name, stringValue: stringParam)
    }
    
    /// Retrieve a query string parameter as String
    func query(_ name: String) -> String? {
        return queryItems[name]
    }
    
    /// Retrieve a query string parameter as Integer
    func queryInt(_ name: String) -> Int? {
        if let queryItem = queryItems[name] {
            return Int(queryItem)
        }
        
        return nil
    }
    
}
