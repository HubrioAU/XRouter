//
//  MockRouter.swift
//  XRouter_Example
//
//  Created by Reece Como on 12/1/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
@testable import XRouter

/**
 Mocked router
 */
class MockRouter<Route: RouteProvider>: Router<Route> {
    
    private(set) var currentRoute: Route?
    
    /// Set the `currentRoute` when `super.navigate(to:animated)` succeeds
    override func navigate(to route: Route, animated: Bool = false) throws {
        try super.navigate(to: route, animated: animated)
        currentRoute = route
    }
    
}
