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
    
    /// For making sure our custom error is thrown
    static let routeProviderMockErrorCode = 12345
    
    /// Home view controller
    static let homeViewController = UIViewController()
    
    /// Test routing works as expected when the root view controller is a navigation controller
    func testRoutingWithUINavigationController() {
        let router = MockRouter<TestRoute>()
        
        // Create initial navigation stack
        let navigationController = UINavigationController(rootViewController: RouterTests.homeViewController)
        UIApplication.shared.keyWindow?.rootViewController = navigationController
        
        assertRoutingPathsWork(using: router)
    }
    
    /// Test routing works as expected when the root view controller is a tab bar controller
    func testRoutingWithUITabBarController() {
        let router = MockRouter<TestRoute>()
        
        // Create initial navigation stack
        let tabBarController = UITabBarController()
        let nestedNavigationController = UINavigationController(rootViewController: RouterTests.homeViewController)
        tabBarController.setViewControllers([nestedNavigationController], animated: false)
        UIApplication.shared.keyWindow?.rootViewController = tabBarController
        
        assertRoutingPathsWork(using: router)
        
        try! router.navigate(to: .secondHomeVC)
        XCTAssertEqual(router.currentRoute!, .secondHomeVC)
        XCTAssertEqual(router.currentRoute!.transition, .set)
    }
    
    /// Test navigate throws an error when the route transition requires a navigation controller, but one is not available
    func testNavigateFailsWhenNoNavigationControllerPresentButIsRequiredByTransition() {
        let router = MockRouter<TestRoute>()
        
        // Create initial navigation stack with a single tab bar controller containing a view controller
        let tabBarController = UITabBarController()
        tabBarController.setViewControllers([RouterTests.homeViewController], animated: false)
        UIApplication.shared.keyWindow?.rootViewController = tabBarController
        
        // This will throw an RouterError.missingRequiredNavigationController
        XCTAssertThrowsError(try router.navigate(to: .settingsVC))
    }
    
    /// Test navigate succeeds when the route transition requires a navigation controller, and one is available
    func testNavigateSucceedsNavigationControllerPresentAndIsRequiredByTransition() {
        let router = MockRouter<TestRoute>()
        
        // Create initial navigation stack
        let tabBarController = UITabBarController()
        let nestedNavigationController = UINavigationController(rootViewController: RouterTests.homeViewController)
        tabBarController.setViewControllers([nestedNavigationController], animated: false)
        UIApplication.shared.keyWindow?.rootViewController = tabBarController
        
        try! router.navigate(to: .settingsVC)
        XCTAssertEqual(router.currentRoute!, .settingsVC)
        XCTAssertEqual(router.currentRoute!.transition, .push)
    }
    
    /// Test that errors thrown in `RouteProvider(_:).prepareForTransition` are passed through to `navigate(to:animated:)`
    func testFowardsErrorsThrownInRouteProviderPrepareForTransition() {
        let router = MockRouter<TestRoute>()
        
        do {
            try router.navigate(to: .alwaysFails)
            XCTFail("navigate(to:animated:) was expected to throw an error, but did not")
        } catch {
            XCTAssertEqual((error as NSError).code, RouterTests.routeProviderMockErrorCode)
        }
    }
    
    /// Test custom transition delegate is triggered
    func testCustomTransitionDelegateIsTriggered() {
        let mockCustomTransitionDelegate = MockRouterCustomTransitionDelegate()
        let router = MockRouter<TestRoute>(customTransitionDelegate: mockCustomTransitionDelegate)
        
        XCTAssertNil(mockCustomTransitionDelegate.lastTransitionPerformed)
        try? router.navigate(to: .customTransitionVC)
        XCTAssertEqual(mockCustomTransitionDelegate.lastTransitionPerformed, .custom(identifier: "customTransition"))
    }
    
    //
    // MARK: - Implementation
    //
    
    /// Assert routing works in current circumstance, given this router
    private func assertRoutingPathsWork(using router: MockRouter<TestRoute>) {
        // Navigate to home view controller (even though we're already there)
        try! router.navigate(to: .homeVC)
        XCTAssertEqual(router.currentRoute!, .homeVC)
        XCTAssertEqual(router.currentRoute!.transition, .set)
        
        try! router.navigate(to: .settingsVC)
        XCTAssertEqual(router.currentRoute!, .settingsVC)
        XCTAssertEqual(router.currentRoute!.transition, .push)
        
        try! router.navigate(to: .nestedModalGroup)
        XCTAssertEqual(router.currentRoute!, .nestedModalGroup)
        XCTAssertEqual(router.currentRoute!.transition, .modal)
        
        try! router.navigate(to: .customTransitionVC)
        XCTAssertEqual(router.currentRoute!, .customTransitionVC)
        XCTAssertEqual(router.currentRoute!.transition, .custom(identifier: "customTransition"))
        
        // Lets navigate now to a second popover modal before moving back to .home
        try! router.navigate(to: .nestedModalGroup)
        XCTAssertEqual(router.currentRoute!, .nestedModalGroup)
        XCTAssertEqual(router.currentRoute!.transition, .modal)
        
        try! router.navigate(to: .singleModalVC)
        XCTAssertEqual(router.currentRoute!, .singleModalVC)
        XCTAssertEqual(router.currentRoute!.transition, .modal)
        
        // Test that going back to a route with a `.set` transition succeeds
        try! router.navigate(to: .homeVC)
        XCTAssertEqual(router.currentRoute!, .homeVC)
        
        // Test calling a failing/cancelled route does not change the current route
        try? router.navigate(to: .alwaysFails)
        XCTAssertEqual(router.currentRoute!, .homeVC)
    }
    
}

private class MockRouter<Route: RouteProvider>: Router<Route> {
    
    private(set) var currentRoute: Route?
    
    /// Set the `currentRoute` when `super.navigate(to:animated)` succeeds
    override func navigate(to route: Route, animated: Bool = false) throws {
        try super.navigate(to: route, animated: animated)
        currentRoute = route
    }
    
}

private enum TestRoute: RouteProvider {
    
    /// Set transition, static omnipresent single view controller
    case homeVC // See `RouterTests.homeViewController`
    
    /// Set transition, single view controller
    case secondHomeVC
    
    /// Push transition, single view controller
    case settingsVC
    
    /// Custom transition, single view controller
    case customTransitionVC
    
    /// Modal transition, single view controller
    case singleModalVC
    
    /// Modal transition, navigation controller with embedded view controller
    case nestedModalGroup
    
    /// *Always cancels transition*
    case alwaysFails
    
    var transition: RouteTransition {
        switch self {
        case .homeVC,
             .secondHomeVC:
            return .set
        case .settingsVC,
             .alwaysFails:
            return .push
        case .nestedModalGroup,
             .singleModalVC:
            return .modal
        case .customTransitionVC:
            return .custom(identifier: "customTransition")
        }
    }
    
    func prepareForTransition(from viewController: UIViewController) throws -> UIViewController {
        switch self {
        case .homeVC,
             .secondHomeVC:
            return RouterTests.homeViewController
        case .settingsVC,
             .singleModalVC,
             .customTransitionVC:
            return UIViewController()
        case .nestedModalGroup:
            return UINavigationController(rootViewController: UIViewController())
        case .alwaysFails:
            throw NSError(domain: "Cancelled route: \(name)", code: RouterTests.routeProviderMockErrorCode, userInfo: nil)
        }
    }
    
}

private class MockRouterCustomTransitionDelegate: RouterCustomTransitionDelegate {
    
    private(set) var lastTransitionPerformed: RouteTransition?
    
    func performTransition(to viewController: UIViewController,
                           from parentViewController: UIViewController,
                           transition: RouteTransition,
                           animated: Bool) {
        lastTransitionPerformed = transition
    }
    
}
