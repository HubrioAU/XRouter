//
//  RoutingHandlerTests.swift
//  XRouter_Example
//
//  Created by Reece Como on 10/2/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest
import UIKit
@testable import XRouter

// swiftlint:disable force_unwrapping
// We are skipping force_unwrapping for these tests

/**
 Router Tests
 */
class RoutingHandlerTests: ReactiveTestCase {
    
    func testUnconfiguredRouterThrowsError() {
        let router = MockRouter()
        navigateExpectError(router, to: .example, error: RouterError.routeHasNotBeenConfigured)
    }
    
    func testDefaultTransitionIsInferred() {
        let routingHandler = MockRoutingHandler()
        XCTAssertEqual(routingHandler.transition(for: .example), .inferred)
    }
    
}

private enum Route: RouteType {
    case example
}

private class MockRouter: MockRouterBase<Route> { }

private class MockRoutingHandler: RoutingHandler<Route> {
    
    override func prepareForTransition(to route: Route) throws -> UIViewController {
        switch route {
        case .example:
            return UIViewController()
        }
    }
    
}
