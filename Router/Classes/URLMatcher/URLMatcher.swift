//
//  Router+URLMatcher
//  XRouter
//

import Foundation

/**
 Represents a list of URL mappings for a set of paths on some host(s).
 */
public class URLMatcher<Route: RouteType> {
    
    // MARK: - Properties
    
    /// Only matches against these hosts
    internal let hosts: [String]
    
    /// Path mapper
    internal let pathMapper: URLPathMapper<Route>
    
    // MARK: - Methods
    
    /// Set a group of mapped paths for some hosts
    public static func group(_ hosts: [String],
                             _ mapPathsClosure: (URLPathMapper<Route>) -> Void) -> URLMatcher {
        return URLMatcher(hosts: hosts, mapPathsClosure)
    }
    
    /// Set a group of mapped paths for a host
    public static func group(_ host: String,
                             _ mapPathsClosure: (URLPathMapper<Route>) -> Void) -> URLMatcher {
        return group([host], mapPathsClosure)
    }
    
    // MARK: - Implementation
    
    /// Init
    internal init(hosts: [String], _ mapPathsClosure: (URLPathMapper<Route>) -> Void) {
        self.hosts = hosts
        self.pathMapper = URLPathMapper()
        
        // Run the path matching
        mapPathsClosure(pathMapper)
    }
    
    /// Match a URL to one of the paths, for any host.
    internal func match(url: URL) throws -> Route? {
        guard let host = url.host, hosts.contains(host) else {
            return nil
        }
        
        return try pathMapper.match(url)
    }
    
}
