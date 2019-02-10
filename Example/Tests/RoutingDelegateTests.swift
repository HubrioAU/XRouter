//
//  RoutingDelegateTests.swift
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
class RoutingDelegateTests: ReactiveTestCase {
    
    func testUnconfiguredRouterThrowsError() {
        let router = MockRouter()
        navigateExpectError(router, to: .example, error: RouterError.routeHasNotBeenConfigured)
    }
    
    func testDefaultTransitionIsModal() {
        let routingDelegate = MockRoutingDelegate()
        XCTAssertEqual(routingDelegate.transition(for: .example), .modal)
    }
    
}

private enum Route: RouteType {
    case example
}

private class MockRouter: MockRouterBase<Route> { }

private class MockRoutingDelegate: RoutingDelegate<Route> {
    
    override func prepareForTransition(to route: Route) throws -> UIViewController {
        switch route {
        case .example:
            return UIViewController()
        }
    }
    
}
