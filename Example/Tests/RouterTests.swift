//
//  RouteTransitionTests.swift
//  XRouter_Tests
//
//  Created by Reece Como on 7/1/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest
import UIKit
@testable import XRouter

// swiftlint:disable force_try force_unwrapping
// We are skipping force_try and force_unwrapping for these tests

/**
 Router Tests
 */
class RouterTests: XCTestCase {
    
    /// For custom
    static let routeProviderMockErrorCode = 12345
    
    /// Test that errors thrown in `RouteProvider(_:).prepareForTransition` are passed through to `navigate(to:animated:)`
    func testNavigateWorksForAllRouteTransitions() {
        let router = MockRouter<TestRoute>()
        
        try! router.navigate(to: .home)
        XCTAssertEqual(router.currentRoute!, .home)
        XCTAssertEqual(router.currentRoute!.transition, .set)
        
        try! router.navigate(to: .settings)
        XCTAssertEqual(router.currentRoute!, .settings)
        XCTAssertEqual(router.currentRoute!.transition, .push)
        
        try! router.navigate(to: .profile(withID: "test-id"))
        XCTAssertEqual(router.currentRoute!, .profile(withID: "test-id"))
        XCTAssertEqual(router.currentRoute!.transition, .modal)
        
        try! router.navigate(to: .oneWithCustomTransition)
        XCTAssertEqual(router.currentRoute!, .oneWithCustomTransition)
        XCTAssertEqual(router.currentRoute!.transition, .custom(identifier: "customTransition"))
        
        // Test that going back to a route with a `.set` transition succeeds
        try! router.navigate(to: .home)
        XCTAssertEqual(router.currentRoute!, .home)
        
        // Test calling a failing/cancelled route does not change the current route
        try? router.navigate(to: .alwaysFails)
        XCTAssertEqual(router.currentRoute!, .home)
    }
    
    /// Test that errors thrown in `RouteProvider(_:).prepareForTransition` are passed through to `navigate(to:animated:)`
    func testPassesErrorsThrownInRouteProviderPrepareForTransition() {
        let router = MockRouter<TestRoute>()
        
        do {
            try router.navigate(to: .alwaysFails)
            XCTFail("navigate(to:animated:) was expected to throw an error, but did not")
        } catch {
            XCTAssertEqual((error as NSError).code, RouterTests.routeProviderMockErrorCode)
        }
    }
    
    /// Test custom transition is triggered
    func testCustomTransitionDelegateIsTriggered() {
        let mockCustomTransitionDelegate = MockRouterCustomTransitionDelegate()
        let router = MockRouter<TestRoute>(customTransitionDelegate: mockCustomTransitionDelegate)
        
        XCTAssertNil(mockCustomTransitionDelegate.lastTransitionPerformed)
        try? router.navigate(to: .oneWithCustomTransition)
        XCTAssertEqual(mockCustomTransitionDelegate.lastTransitionPerformed, .custom(identifier: "customTransition"))
    }
    
}

private class MockRouter<Route: RouteProvider>: Router<Route> {
    
    private(set) var currentRoute: Route?
    
    /// Set the `currentRoute` when `super.navigate(to:animated)` succeeds
    override func navigate(to route: Route, animated: Bool = false) throws {
        try super.navigate(to: route, animated: false)
        currentRoute = route
    }
    
}

private enum TestRoute: RouteProvider {
    
    case home
    case profile(withID: String)
    case settings
    case oneWithCustomTransition
    case alwaysFails
    
    var transition: RouteTransition {
        switch self {
        case .home:
            return .set
        case .settings,
             .alwaysFails:
            return .push
        case .profile:
            return .modal
        case .oneWithCustomTransition:
            return .custom(identifier: "customTransition")
        }
    }
    
    func prepareForTransition(from viewController: UIViewController) throws -> UIViewController {
        switch self {
        case .home:
            return UIViewController()
        case .settings:
            return UIViewController()
        case .profile:
            return UINavigationController(rootViewController: UIViewController())
        case .oneWithCustomTransition:
            return UIViewController()
        case .alwaysFails:
            throw NSError(domain: "Cancelled route: \(name)", code: RouterTests.routeProviderMockErrorCode, userInfo: nil)
        }
    }
    
}

private class MockRouterCustomTransitionDelegate: RouterCustomTransitionDelegate {
    
    private(set) var lastTransitionPerformed: RouteTransition?
    
    func performTransition(to viewController: UIViewController,
                           from currentNavigationController: UINavigationController,
                           transition: RouteTransition,
                           animated: Bool) {
        lastTransitionPerformed = transition
    }
    
}
