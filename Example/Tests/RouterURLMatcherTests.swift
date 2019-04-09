//
//  RouterURLMatcherTests.swift
//  XRouter_Tests
//
//  Created by Reece Como on 12/1/19.
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
class RouterURLMatcherTests: ReactiveTestCase {
    
    /// Test static routes
    func testURLRouterCanMapStaticRoutes() {
        let router = MockRouter(rootViewController: UINavigationController(rootViewController: UIViewController()))
        
        openURL(router, url: URL(string: "http://example.com/invalid/route")!)
        XCTAssertNil(router.currentRoute)
        
        openURL(router, url: URL(string: "http://example.com/static/route")!)
        XCTAssertEqual(router.currentRoute, .exampleStaticRoute)
    }
    
    /// Test dynamic string routes
    func testURLRouterCanMapDynamicStringRoutes() {
        let router = MockRouter(rootViewController: UINavigationController(rootViewController: UIViewController()))
        
        openURL(router, url: URL(string: "http://example.com/dynamic/string/spaghetti")!)
        if case let TestRoute.exampleStringDynamicRoute(name) = router.currentRoute! {
            XCTAssertEqual(name, "spaghetti")
        } else {
            XCTFail("Was expecting spaghetti")
        }
        
        openURL(router, url: URL(string: "http://example.com/dynamic/string/walrus")!)
        if case let TestRoute.exampleStringDynamicRoute(name) = router.currentRoute! {
            XCTAssertEqual(name, "walrus")
        } else {
            XCTFail("Was expecting walrus")
        }
    }
    
    /// Test dynamic string routes
    func testURLRouterCanMapDynamicIntRoutes() {
        let router = MockRouter(rootViewController: UINavigationController(rootViewController: UIViewController()))
        
        openURL(router, url: URL(string: "http://example.com/dynamic/int/1235")!)
        if case let TestRoute.exampleIntDynamicRoute(number) = router.currentRoute! {
            XCTAssertEqual(number, 1235)
        } else {
            XCTFail("Was expecting 1235")
        }
        
        openURL(router, url: URL(string: "http://example.com/dynamic/int/3411")!)
        if case let TestRoute.exampleIntDynamicRoute(number) = router.currentRoute! {
            XCTAssertEqual(number, 3411)
        } else {
            XCTFail("Was expecting 3411")
        }
    }
    
    /// Test dynamic string routes
    func testURLRouterCanMapWildcardRoutes() {
        let router = MockRouter(rootViewController: UINavigationController(rootViewController: UIViewController()))
        
        openURL(router, url: URL(string: "http://example.com/dynamic/wildcard-test/whatever")!)
        XCTAssertNil(router.currentRoute)
        
        openURL(router, url: URL(string: "http://example.com/dynamic/wildcard/something/whatever")!)
        XCTAssertEqual(router.currentRoute, .exampleWildcardRoute)
    }
    
    /// Test dynamic string routes
    func testURLMatcherGroupFunctionInitWithOneHost() {
        let matcherGroup = URLMatcherGroup<TestRoute>.group("mystore.com") {
            $0.map("my/cool/route") { .exampleStaticRoute }
            $0.map("static/route/") { .exampleStaticRoute }
        }
        
        XCTAssertEqual(matcherGroup.matchers.count, 1)
    }
    
    /// Test dynamic string routes
    func testQueryStringParameters() {
        let router = MockRouter(rootViewController: UINavigationController(rootViewController: UIViewController()))
        XCTAssertNil(router.currentRoute)
        
        // No parameter should set parameter to 0
        openURL(router, url: URL(string: "http://example.com/some-qs/route?whatIsTheTime")!)
        if let route = router.currentRoute, case let TestRoute.exampleQueryStringRoute(pageNumber) = route {
            XCTAssertEqual(pageNumber, 0)
        } else {
            XCTFail("Was expecting page number to equal 0")
        }
        
        // Valid page parameter should set value to 7
        openURL(router, url: URL(string: "http://example.com/some-qs/route?page=7")!)
        if let route = router.currentRoute, case let TestRoute.exampleQueryStringRoute(pageNumber) = route {
            XCTAssertEqual(pageNumber, 7)
        } else {
            XCTFail("Was expecting page number to equal 7")
        }
        
        // Invalid should default to 0
        openURL(router, url: URL(string: "http://example.com/some-qs/route?page=tortoise")!)
        if let route = router.currentRoute, case let TestRoute.exampleQueryStringRoute(pageNumber) = route {
            XCTAssertEqual(pageNumber, 0)
        } else {
            XCTFail("Was expecting page number to equal 0")
        }
        
        // String parameters
        openURL(router, url: URL(string: "http://example.com/some/other-qs/route?name=tortoise")!)
        if case let TestRoute.exampleQueryStringRoute2(name) = router.currentRoute! {
            XCTAssertEqual(name, "tortoise")
        } else {
            XCTFail("Was expecting name to equal tortoise")
        }
        
        // Test RxSwift extension works too
        rxOpenURL(router, url: URL(string: "http://example.com/some/other-qs/route?name=tortoise")!)
        if case let TestRoute.exampleQueryStringRoute2(name) = router.currentRoute! {
            XCTAssertEqual(name, "tortoise")
        } else {
            XCTFail("Was expecting name to equal tortoise")
        }
    }
    
    /// Test dynamic string routes
    func testRouteMissingParamTriggersError() {
        let router = MockRouter(rootViewController: UINavigationController(rootViewController: UIViewController()))
        openURLExpectError(router, url: URL(string: "http://example.com/route/missing/param")!,
                           error: RouterError.missingRequiredPathParameter(parameter: "whoops"))
    }
    
    /// Test dynamic string routes
    func testRouteInvalidIntegerParameterTriggersError() {
        let router = MockRouter(rootViewController: UINavigationController(rootViewController: UIViewController()))
        openURLExpectError(router, url: URL(string: "http://example.com/dynamic/int/three")!,
                           error: RouterError.requiredIntegerParameterWasNotAnInteger(parameter: "id", stringValue: "three"))
        
        // Test RxSwift extension works too
        rxOpenURLExpectError(router, url: URL(string: "http://example.com/dynamic/int/three")!,
                           error: RouterError.requiredIntegerParameterWasNotAnInteger(parameter: "id", stringValue: "three"))
    }
    
    /// Test rx.openURL captures an error thrown during transition
    func testReactiveExtensionCatchesErrors() {
        let router = MockRouter()
        
        // Test RxSwift extension works too
        rxOpenURLExpectError(router, url: URL(string: "http://example.com/failing")!,
                             error: RouterError.routeHasNotBeenConfigured)
    }
    
}

private enum TestRoute: RouteType {
    
    /// Static route
    case exampleStaticRoute
    
    /// Has custom name
    case exampleStringDynamicRoute(named: String)
    
    /// Has custom identifier
    case exampleIntDynamicRoute(withID: Int)
    
    /// Wildcard route
    case exampleWildcardRoute
    
    /// Wildcard route
    case exampleQueryStringRoute(page: Int)
    
    /// Wildcard route
    case exampleQueryStringRoute2(name: String)
    
    /// Route that fails during routing
    case failingRoute
    
    static func registerURLs() -> URLMatcherGroup<TestRoute>? {
        return .init(matchers: [
            .group("example.com") {
                $0.map("static/route/") { .exampleStaticRoute }
                $0.map("dynamic/string/{name}") { try .exampleStringDynamicRoute(named: $0.param("name")) }
                $0.map("dynamic/int/{id}") { try .exampleIntDynamicRoute(withID: $0.param("id")) }
                $0.map("dynamic/wildcard/*/whatever") { .exampleWildcardRoute }
                $0.map("some-qs/route") { .exampleQueryStringRoute(page: $0.query("page") ?? 0) }
                $0.map("some/other-qs/route") { .exampleQueryStringRoute2(name: $0.query("name") ?? "") }
                $0.map("route/missing/param") { try .exampleStringDynamicRoute(named: $0.param("whoops")) }
                $0.map("failing") { .failingRoute }
            },
            .group(["second-website.com",
                    "third.website.net.au"]
            ) {
                $0.map("static/route/") { .exampleStaticRoute }
                $0.map("dynamic/string/{name}") { try .exampleStringDynamicRoute(named: $0.param("name")) }
                $0.map("dynamic/int/{id}") { try .exampleIntDynamicRoute(withID: $0.param("id")) }
                $0.map("dynamic/wildcard/*/whatever") { .exampleWildcardRoute }
                $0.map("some-qs/route") { .exampleQueryStringRoute(page: $0.query("page") ?? 0) }
                $0.map("some/other-qs/route") { .exampleQueryStringRoute2(name: $0.query("name") ?? "") }
                $0.map("route/missing/param") { try .exampleStringDynamicRoute(named: $0.param("whoops")) }
            }
            ]
        )
    }
    
}

private class MockRouter: MockRouterBase<TestRoute> {
    
    override func viewController(for route: TestRoute) throws -> UIViewController {
        switch route {
        case .exampleStaticRoute:
            let viewController = UIViewController()
            viewController.title = "My Static Route"
            return viewController
            
        case .exampleStringDynamicRoute(let name):
            let viewController = UIViewController()
            viewController.title = name
            return viewController
            
        case .exampleIntDynamicRoute(let identifier):
            let viewController = UIViewController()
            viewController.title = "id:\(identifier)"
            return viewController
            
        case .failingRoute:
            throw RouterError.routeHasNotBeenConfigured
            
        default:
            return UIViewController()
        }
    }
    
}
