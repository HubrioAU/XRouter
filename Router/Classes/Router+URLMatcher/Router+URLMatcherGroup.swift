//
//  Router+URLMatcherGroup.swift
//  XRouter
//
//  Created by Reece Como on 12/1/19.
//

import Foundation

extension Router {
    
    /**
     A group of URLMatchers, and some shortcuts to create groups.
     */
    public struct URLMatcherGroup {
        
        /// URL matchers
        let matchers: [URLMatcher]
        
        /// Set a group of mapped paths for some hosts
        public static func group(_ hosts: [String],
                                 _ mapPathsClosure: (URLPathMatcher) -> Void) -> URLMatcherGroup {
            return .init(matchers: [URLMatcher(hosts: hosts, mapPathsClosure)])
        }
        
        /// Set a group of mapped paths for a host
        public static func group(_ host: String,
                                 _ mapPathsClosure: (URLPathMatcher) -> Void) -> URLMatcherGroup {
            return group([host], mapPathsClosure)
        }
        
    }

}
