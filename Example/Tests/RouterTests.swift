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

// swiftlint:disable force_unwrapping
// We are skipping force_unwrapping for these tests

/**
 Router Tests
 */
class RouterTests: ReactiveTestCase {
    
    /// Home view controller
    static let homeViewController = UIViewController()
    
    /// Test routing works as expected when the root view controller is a navigation controller
    func testRoutingWithUINavigationController() {
        // Create initial navigation stack
        let navigationController = UINavigationController(rootViewController: RouterTests.homeViewController)
        let router = MockRouter(rootViewController: navigationController)
        
        assertRoutingPathsWork(using: router)
    }
    
    /// Set view controller fail when no nav controller
    func testMissingRequiredNavigationController() {
        let router = MockRouter(rootViewController: UIViewController())
        
        // You shouldn't be able to call the set transition from a single modal vc.
        navigate(router, to: .singleModalVC)
        navigateExpectError(router, to: .secondHomeVC, error: RouterError.missingRequiredNavigationController)
    }
    
    /// Test routing works as expected when the root view controller is a tab bar controller
    func testRoutingWithUITabBarController() {
        // Create initial navigation stack
        let tabBarController = UITabBarController()
        let secondTabScreen = UIViewController()
        let firstTab = UINavigationController(rootViewController: RouterTests.homeViewController)
        let secondTab = UINavigationController(rootViewController: secondTabScreen)
        tabBarController.setViewControllers([firstTab, secondTab],
                                            animated: false)
        
        let router = MockRouter(rootViewController: tabBarController)
        
        assertRoutingPathsWork(using: router)
        
        navigate(router, to: .customVC(viewController: secondTabScreen))
        XCTAssertEqual(router.currentRoute!, .customVC(viewController: secondTabScreen))
    }
    
    /// Test navigate throws an error when the route transition requires a navigation controller, but one is not available
    func testNavigateFailsWhenNoNavigationControllerPresentButIsRequiredByTransition() {
        // Create initial navigation stack with a single tab bar controller containing a view controller
        let tabBarController = UITabBarController()
        tabBarController.setViewControllers([RouterTests.homeViewController], animated: false)
        let router = MockRouter(rootViewController: tabBarController)
        
        // This will throw an RouterError.missingRequiredNavigationController(for: .push)
        navigateExpectError(router, to: .settingsVC, error: RouterError.missingRequiredNavigationController)
    }
    
    /// Test navigate succeeds when the route transition requires a navigation controller, and one is available
    func testNavigateSucceedsNavigationControllerPresentAndIsRequiredByTransition() {
        // Create initial navigation stack
        let tabBarController = UITabBarController()
        let nestedNavigationController = UINavigationController(rootViewController: RouterTests.homeViewController)
        tabBarController.setViewControllers([nestedNavigationController], animated: false)
        
        let router = MockRouter(rootViewController: tabBarController)
        
        navigate(router, to: .settingsVC)
        XCTAssertEqual(router.currentRoute, .settingsVC)
    }
    
    /// Test that errors thrown in `RouteType(_:).prepareForTransition` are passed through to `navigate(to:animated:)`
    func testFowardsErrorsThrownInRouteTypePrepareForTransition() {
        let router = MockRouter(rootViewController: UIViewController())
        
        navigateExpectError(router, to: .alwaysFails, error: RouterError.routeHasNotBeenConfigured)
    }
    
    /// Test custom transition delegate is triggered
    func testCustomTransitionDelegateIsTriggered() {
        let router = MockRouter(rootViewController: UIViewController())
        
        navigate(router, to: .customTransitionVC)
        XCTAssert(RouteTransition.customTransitionWasTriggered)
    }
    
    /// Test
    func testURLRouterFailsSilentlyWhenNoRoutesRegistered() {
        let router = MockRouter(rootViewController: UIViewController())
        
        openURL(router, url: URL(string: "http://example.com/static/route")!)
        XCTAssertNil(router.currentRoute)
    }
    
    /// Test assertion failure completion block path is triggered
    func testAssertionFailureCompletionBlockPathIsTriggered() {
        let router = XRouter<TestRoute>(window: nil)
        router.navigate(to: .homeVC)
    }
    
    /// Test missing source view controller
    func testMissingSourceViewController() {
        let router = MockRouter(rootViewController: nil)
        navigateExpectError(router, to: .homeVC, error: RouterError.missingSourceViewController)
    }
    
    /// Test set
    func testSetViewControllerWorksWhenNoViewControllerHasBeenSetBefore() {
        let vc1 = UIViewController()
        let vc2 = UIViewController()
        let router = MockRouter(rootViewController: UINavigationController(rootViewController: vc1))
        
        navigate(router, to: .customVC(viewController: vc2))
        XCTAssertEqual(router.currentRoute, .customVC(viewController: vc2))
    }
    
    //
    // MARK: - Implementation
    //
    
    /// Assert routing works in current circumstance, given this router
    private func assertRoutingPathsWork(using router: MockRouter) {
        // Navigate to home view controller (even though we're already there)
        navigate(router, to: .homeVC)
        XCTAssertEqual(router.currentRoute!, .homeVC)
        
        // Test RxSwift extension
        rxNavigate(router, to: .settingsVC)
        XCTAssertEqual(router.currentRoute!, .settingsVC)
        
        // Test RxSwift failure
        rxNavigateExpectError(router, to: .alwaysFails, error: RouterError.routeHasNotBeenConfigured)
        XCTAssertEqual(router.currentRoute!, .settingsVC)
        
        navigate(router, to: .nestedModalGroup)
        XCTAssertEqual(router.currentRoute!, .nestedModalGroup)
        
        // Lets navigate now to a second popover modal before moving back to .home
        navigate(router, to: .nestedModalGroup)
        XCTAssertEqual(router.currentRoute!, .nestedModalGroup)
        
        navigate(router, to: .singleModalVC)
        XCTAssertEqual(router.currentRoute!, .singleModalVC)
        
        // Test that going back to a route with a `.set` transition succeeds
        navigate(router, to: .homeVC)
        XCTAssertEqual(router.currentRoute!, .homeVC)
        
        // Test calling a failing/cancelled route does not change the current route
        navigate(router, to: .alwaysFails, failOnError: false)
        XCTAssertEqual(router.currentRoute!, .homeVC)
    }
    
}

fileprivate enum TestRoute: RouteType {
    
    /// Set transition, static omnipresent single view controller
    case homeVC // See `RouterTests.homeViewController`
    
    /// Set transition, single view controller
    case secondHomeVC
    
    /// Custom VC, set transition.
    case customVC(viewController: UIViewController)
    
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
    
}

private class MockRouter: MockRouterBase<TestRoute> {
    
    /// Explicitly test transitions
    override func transition(for route: TestRoute) -> RouteTransition {
        switch route {
        case .homeVC,
             .secondHomeVC,
             .customVC:
            return .set
        case .settingsVC,
             .alwaysFails:
            return .push
        case .nestedModalGroup,
             .singleModalVC:
            return .modal
        case .customTransitionVC:
            return .customTransition
        }
    }
    
    /// Prepare for transition
    override func viewController(for route: TestRoute) throws -> UIViewController {
        switch route {
        case .homeVC,
             .secondHomeVC:
            return RouterTests.homeViewController
        case .customVC(let viewController):
            return viewController
        case .settingsVC,
             .singleModalVC,
             .customTransitionVC:
            return UIViewController()
        case .nestedModalGroup:
            return UINavigationController(rootViewController: UIViewController())
        case .alwaysFails:
            throw RouterError.routeHasNotBeenConfigured
        }
    }
    
}

extension RouteTransition {
    
    static var customTransitionWasTriggered = false
    
    static let customTransition = RouteTransition { (source, dest, animated, completion) in
        // Do nothing
        customTransitionWasTriggered = true
        completion(nil)
    }
}
