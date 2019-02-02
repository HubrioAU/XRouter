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
class RouterTests: XCTestCase {
    
    /// For making sure our custom error is thrown
    static let routeProviderMockErrorCode = 12345
    
    /// Home view controller
    static let homeViewController = UIViewController()
    
    /// Test routing works as expected when the root view controller is a navigation controller
    func testRoutingWithUINavigationController() {
        // Create initial navigation stack
        let navigationController = UINavigationController(rootViewController: RouterTests.homeViewController)
        let router = MockRouter<TestRoute>(rootViewController: navigationController)
        
        assertRoutingPathsWork(using: router)
    }
    
    /// Set view controller fail when no nav controller
    func testMissingRequiredNavigationController() {
        let router = MockRouter<TestRoute>(rootViewController: UIViewController())
        
        // You shouldn't be able to call the set transition from a single modal vc.
        navigate(router, to: .singleModalVC)
        navigateExpectError(router, to: .secondHomeVC, error: RouterError.missingRequiredNavigationController(for: .set))
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
        
        let router = MockRouter<TestRoute>(rootViewController: tabBarController)
        
        assertRoutingPathsWork(using: router)
        
        navigate(router, to: .customVC(viewController: secondTabScreen))
        XCTAssertEqual(router.currentRoute!, .customVC(viewController: secondTabScreen))
        XCTAssertEqual(router.currentRoute!.transition, .set)
    }
    
    /// Test navigate throws an error when the route transition requires a navigation controller, but one is not available
    func testNavigateFailsWhenNoNavigationControllerPresentButIsRequiredByTransition() {
        // Create initial navigation stack with a single tab bar controller containing a view controller
        let tabBarController = UITabBarController()
        tabBarController.setViewControllers([RouterTests.homeViewController], animated: false)
        let router = MockRouter<TestRoute>(rootViewController: tabBarController)
        
        // This will throw an RouterError.missingRequiredNavigationController(for: .push)
        navigateExpectError(router, to: .settingsVC, error: RouterError.missingRequiredNavigationController(for: .push))
    }
    
    /// Test navigate succeeds when the route transition requires a navigation controller, and one is available
    func testNavigateSucceedsNavigationControllerPresentAndIsRequiredByTransition() {
        // Create initial navigation stack
        let tabBarController = UITabBarController()
        let nestedNavigationController = UINavigationController(rootViewController: RouterTests.homeViewController)
        tabBarController.setViewControllers([nestedNavigationController], animated: false)
        
        let router = MockRouter<TestRoute>(rootViewController: tabBarController)
        
        navigate(router, to: .settingsVC)
        XCTAssertEqual(router.currentRoute, .settingsVC)
        XCTAssertEqual(router.currentRoute?.transition, .push)
    }
    
    /// Test that errors thrown in `RouteProvider(_:).prepareForTransition` are passed through to `navigate(to:animated:)`
    func testFowardsErrorsThrownInRouteProviderPrepareForTransition() {
        let router = MockRouter<TestRoute>(rootViewController: UIViewController())
        
        guard let error = navigate(router, to: .alwaysFails, failOnError: false) else {
            XCTFail("Expected error, but none received")
            return
        }
        
        XCTAssertEqual((error as NSError).code, RouterTests.routeProviderMockErrorCode)
    }
    
    /// Test custom transition delegate is triggered
    func testCustomTransitionDelegateIsTriggered() {
        let mockCustomTransitionDelegate = MockRouterCustomTransitionDelegate()
        let router = MockRouter<TestRoute>(rootViewController: UIViewController())
        router.customTransitionDelegate = mockCustomTransitionDelegate
        
        XCTAssertNil(mockCustomTransitionDelegate.lastTransitionPerformed)
        navigate(router, to: .customTransitionVC)
        XCTAssertEqual(mockCustomTransitionDelegate.lastTransitionPerformed, .custom(identifier: "customTransition"))
    }
    
    /// Test
    func testURLRouterFailsSilentlyWhenNoRoutesRegistered() {
        let router = MockRouter<TestRoute>(rootViewController: UIViewController())
        
        openURL(router, url: URL(string: "http://example.com/static/route")!)
        XCTAssertNil(router.currentRoute)
    }
    
    /// Test missing source view controller
    func testMissingSourceViewController() {
        let router = FailingMockRouter<TestRoute>(rootViewController: UIViewController())
        navigateExpectError(router, to: .homeVC, error: RouterError.missingSourceViewController)
    }
    
    //
    // MARK: - Implementation
    //
    
    /// Assert routing works in current circumstance, given this router
    private func assertRoutingPathsWork(using router: MockRouter<TestRoute>) {
        // Navigate to home view controller (even though we're already there)
        navigate(router, to: .homeVC)
        XCTAssertEqual(router.currentRoute!, .homeVC)
        XCTAssertEqual(router.currentRoute!.transition, .set)
        
        navigate(router, to: .settingsVC)
        XCTAssertEqual(router.currentRoute!, .settingsVC)
        XCTAssertEqual(router.currentRoute!.transition, .push)
        
        navigate(router, to: .nestedModalGroup)
        XCTAssertEqual(router.currentRoute!, .nestedModalGroup)
        XCTAssertEqual(router.currentRoute!.transition, .modal)
        
        // Missing custom navigation delegate
        navigateExpectError(router, to: .customTransitionVC, error: RouterError.missingCustomTransitionDelegate)
        
        // Lets navigate now to a second popover modal before moving back to .home
        navigate(router, to: .nestedModalGroup)
        XCTAssertEqual(router.currentRoute!, .nestedModalGroup)
        XCTAssertEqual(router.currentRoute!.transition, .modal)
        
        navigate(router, to: .singleModalVC)
        XCTAssertEqual(router.currentRoute!, .singleModalVC)
        XCTAssertEqual(router.currentRoute!.transition, .modal)
        
        // Test that going back to a route with a `.set` transition succeeds
        navigate(router, to: .homeVC)
        XCTAssertEqual(router.currentRoute!, .homeVC)
        
        // Test calling a failing/cancelled route does not change the current route
        navigate(router, to: .alwaysFails, failOnError: false)
        XCTAssertEqual(router.currentRoute!, .homeVC)
    }
    
}

private enum TestRoute: RouteProvider {
    
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
    
    var transition: RouteTransition {
        switch self {
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
            return .custom(identifier: "customTransition")
        }
    }
    
    func prepareForTransition(from viewController: UIViewController) throws -> UIViewController {
        switch self {
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
            throw NSError(domain: "Cancelled route: \(name)", code: RouterTests.routeProviderMockErrorCode, userInfo: nil)
        }
    }
    
}

private class MockRouterCustomTransitionDelegate: RouterCustomTransitionDelegate {
    
    private(set) var lastTransitionPerformed: RouteTransition?
    
    func performTransition(to viewController: UIViewController,
                           from sourceViewController: UIViewController,
                           transition: RouteTransition,
                           animated: Bool,
                           completion: ((Error?) -> Void)?) {
        lastTransitionPerformed = transition
        completion?(nil)
    }
    
}
