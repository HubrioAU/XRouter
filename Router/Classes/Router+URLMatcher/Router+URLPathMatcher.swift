//
//  RouteURLPathMatcher.swift
//  XRouter
//
//  Created by Reece Como on 12/1/19.
//

import Foundation

extension Router {
    
    /**
     Router URL Path Matcher
     */
    public class URLPathMatcher {
        
        /// Dynamic path patterns
        private var dynamicPathPatterns = [PathPattern: ((MatchedURL) throws -> Route)]()
        
        /// Simple path patterns
        private var staticPathPatterns = [PathPattern: (() throws -> Route)]()
        
        /// Map a path to a route
        /// - Note: With the `MatchedURL` passed as a parameter in the callback
        public func map(_ pathPattern: PathPattern, _ route: @escaping (MatchedURL) throws -> Route) {
            dynamicPathPatterns[pathPattern] = route
        }
        
        /// Map a path to a route
        public func map(_ pathPattern: PathPattern, _ route: @escaping () throws -> Route) {
            staticPathPatterns[pathPattern] = route
        }
        
        /// Match a Route from a URL
        internal func match(_ url: URL) throws -> Route? {
            // Check for matches on all static paths
            for (pattern, route) in staticPathPatterns {
                if match(pattern, url) != nil {
                    return try route()
                }
            }
            
            // Check for matches on all dynamic paths
            for (pattern, route) in dynamicPathPatterns {
                if let matchedLink = match(pattern, url) {
                    return try route(matchedLink)
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
    
}
