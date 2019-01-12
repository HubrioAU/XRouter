//
//  Router+URLMatcher.swift
//  XRouter
//
//  Created by Reece Como on 12/1/19.
//

import Foundation

extension Router {
    
    /**
     Represents a mapping of some set of path matchers for some hosts.
     */
    public class URLMatcher {
        
        /// Hosts to match against
        let hosts: [String]
        
        /// Path matcher
        let pathMatcher: URLPathMatcher
        
        // MARK: -Methods
        
        /// Set a group of mapped paths for some hosts
        public static func group(_ hosts: [String],
                                 _ mapPathsClosure: (URLPathMatcher) -> Void) -> URLMatcher {
            return URLMatcher(hosts: hosts, mapPathsClosure)
        }
        
        /// Set a group of mapped paths for a host
        public static func group(_ host: String,
                                 _ mapPathsClosure: (URLPathMatcher) -> Void) -> URLMatcher {
            return group([host], mapPathsClosure)
        }
        
        // MARK: - Implementation
        
        /// Init
        internal init(hosts: [String], _ mapPathsClosure: (URLPathMatcher) -> Void) {
            self.hosts = hosts
            self.pathMatcher = URLPathMatcher()
            
            // Run the path matching
            mapPathsClosure(pathMatcher)
        }
        
        /// Match a URL to one of the paths, for any host.
        internal func match(url: URL) throws -> Route? {
            guard let host = url.host, hosts.contains(host) else {
                return nil
            }
            
            return try pathMatcher.match(url)
        }
        
    }

}
