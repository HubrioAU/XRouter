//
//  Router+URLMatcherGroup
//  XRouter
//

import Foundation

extension Router {
    
    /**
     Maintains a list of URLMatchers, and some shortcuts to create groups.
     */
    public struct URLMatcherGroup {
        
        // MARK: - Properties
        
        /// URL matchers
        public let matchers: [URLMatcher]
        
        // MARK: - Helper methods
        
        /// Set a group of mapped paths for multiple hosts
        public static func group(_ hosts: [String],
                                 _ mapPathsClosure: (URLPathMapper) -> Void) -> URLMatcherGroup {
            return .init(matchers: [URLMatcher(hosts: hosts, mapPathsClosure)])
        }
        
        /// Set a group of mapped paths for a single host
        public static func group(_ host: String,
                                 _ mapPathsClosure: (URLPathMapper) -> Void) -> URLMatcherGroup {
            return group([host], mapPathsClosure)
        }
        
        // MARK: - Methods
        
        /// Find  matching URL
        internal func findMatch(forURL url: URL) throws -> Route? {
            for urlMatcher in matchers {
                if let route = try urlMatcher.match(url: url) {
                    return route
                }
            }
            
            return nil
        }
        
    }

}
