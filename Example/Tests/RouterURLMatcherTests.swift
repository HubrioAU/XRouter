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

// swiftlint:disable force_try force_unwrapping
// We are skipping force_try and force_unwrapping for these tests

/**
 Router Tests
 */
class RouterURLMatcherTests: XCTestCase {
    
    /// Test static routes
    func testURLRouterCanMapStaticRoutes() {
        let router = MockRouter<TestRoute>()
        
        try! router.openURL(URL(string: "http://example.com/invalid/route")!)
        XCTAssertNil(router.currentRoute)
        
        try! router.openURL(URL(string: "http://example.com/static/route")!)
        XCTAssertEqual(router.currentRoute, .exampleStaticRoute)
    }
    
    /// Test dynamic string routes
    func testURLRouterCanMapDynamicStringRoutes() {
        let router = MockRouter<TestRoute>()
        
        try! router.openURL(URL(string: "http://example.com/dynamic/string/spaghetti")!)
        if case let TestRoute.exampleStringDynamicRoute(name) = router.currentRoute! {
            XCTAssertEqual(name, "spaghetti")
        } else {
            XCTFail("Was expecting spaghetti")
        }
        
        try! router.openURL(URL(string: "http://example.com/dynamic/string/walrus")!)
        if case let TestRoute.exampleStringDynamicRoute(name) = router.currentRoute! {
            XCTAssertEqual(name, "walrus")
        } else {
            XCTFail("Was expecting walrus")
        }
    }
    
    /// Test dynamic string routes
    func testURLRouterCanMapDynamicIntRoutes() {
        let router = MockRouter<TestRoute>()
        
        try! router.openURL(URL(string: "http://example.com/dynamic/int/1235")!)
        if case let TestRoute.exampleIntDynamicRoute(number) = router.currentRoute! {
            XCTAssertEqual(number, 1235)
        } else {
            XCTFail("Was expecting 1235")
        }
        
        try! router.openURL(URL(string: "http://example.com/dynamic/int/3411")!)
        if case let TestRoute.exampleIntDynamicRoute(number) = router.currentRoute! {
            XCTAssertEqual(number, 3411)
        } else {
            XCTFail("Was expecting 3411")
        }
    }
    
    /// Test dynamic string routes
    func testURLRouterCanMapWildcardRoutes() {
        let router = MockRouter<TestRoute>()
        
        try! router.openURL(URL(string: "http://example.com/dynamic/wildcard-test/whatever")!)
        XCTAssertNil(router.currentRoute)
        
        try! router.openURL(URL(string: "http://example.com/dynamic/wildcard/something/whatever")!)
        XCTAssertEqual(router.currentRoute, .exampleWildcardRoute)
    }
    
    /// Test dynamic string routes
    func testURLMatcherGroupFunctionInitWithOneHost() {
        let matcherGroup = Router<TestRoute>.URLMatcherGroup.group("mystore.com") {
            $0.map("my/cool/route") { .exampleStaticRoute }
            $0.map("static/route/") { .exampleStaticRoute }
        }
        
        XCTAssertEqual(matcherGroup.matchers.count, 1)
    }
    
    /// Test dynamic string routes
    func testQueryStringParameters() {
        let router = MockRouter<TestRoute>()
        XCTAssertNil(router.currentRoute)
        
        // No parameter should set parameter to 0
        try! router.openURL(URL(string: "http://example.com/some-qs/route?whatIsTheTime")!)
        if case let TestRoute.exampleQueryStringRoute(pageNumber) = router.currentRoute! {
            XCTAssertEqual(pageNumber, 0)
        } else {
            XCTFail("Was expecting page number to equal 0")
        }
        
        // Valid page parameter should set value to 7
        try! router.openURL(URL(string: "http://example.com/some-qs/route?page=7")!)
        if case let TestRoute.exampleQueryStringRoute(pageNumber) = router.currentRoute! {
            XCTAssertEqual(pageNumber, 7)
        } else {
            XCTFail("Was expecting page number to equal 7")
        }
        
        // Invalid should default to 0
        try! router.openURL(URL(string: "http://example.com/some-qs/route?page=tortoise")!)
        if case let TestRoute.exampleQueryStringRoute(pageNumber) = router.currentRoute! {
            XCTAssertEqual(pageNumber, 0)
        } else {
            XCTFail("Was expecting page number to equal 0")
        }
        
        // String parameters
        try! router.openURL(URL(string: "http://example.com/some/other-qs/route?name=tortoise")!)
        if case let TestRoute.exampleQueryStringRoute2(name) = router.currentRoute! {
            XCTAssertEqual(name, "tortoise")
        } else {
            XCTFail("Was expecting name to equal tortoise")
        }
    }
    
    /// Test dynamic string routes
    func testRouteMissingParamTriggersError() {
        let router = MockRouter<TestRoute>()
        XCTAssertThrowsError(try router.openURL(URL(string: "http://example.com/route/missing/param")!))
    }
    
    /// Test dynamic string routes
    func testRouteInvalidIntegerParameterTriggersError() {
        let router = MockRouter<TestRoute>()
        XCTAssertThrowsError(try router.openURL(URL(string: "http://example.com/dynamic/int/three")!))
    }
    
}

private enum TestRoute: RouteProvider {
    
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
    
    var transition: RouteTransition {
        return .push
    }
    
    func prepareForTransition(from viewController: UIViewController) throws -> UIViewController {
        switch self {
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
            
        default:
            return UIViewController()
        }
    }
    
    static func registerURLs() -> Router<TestRoute>.URLMatcherGroup? {
        return .init(matchers: [
            .group("example.com") {
                $0.map("static/route/") { .exampleStaticRoute }
                $0.map("dynamic/string/{name}") { try .exampleStringDynamicRoute(named: $0.param("name")) }
                $0.map("dynamic/int/{id}") { try .exampleIntDynamicRoute(withID: $0.param("id")) }
                $0.map("dynamic/wildcard/*/whatever") { .exampleWildcardRoute }
                $0.map("some-qs/route") { .exampleQueryStringRoute(page: $0.queryInt("page") ?? 0) }
                $0.map("some/other-qs/route") { .exampleQueryStringRoute2(name: $0.query("name") ?? "") }
                $0.map("route/missing/param") { try .exampleStringDynamicRoute(named: $0.param("whoops")) }
            },
            .group(["second-website.com",
                    "third.website.net.au"]
            ) {
                $0.map("static/route/") { .exampleStaticRoute }
                $0.map("dynamic/string/{name}") { try .exampleStringDynamicRoute(named: $0.param("name")) }
                $0.map("dynamic/int/{id}") { try .exampleIntDynamicRoute(withID: $0.param("id")) }
                $0.map("dynamic/wildcard/*/whatever") { .exampleWildcardRoute }
                $0.map("some-qs/route") { .exampleQueryStringRoute(page: $0.queryInt("page") ?? 0) }
                $0.map("some/other-qs/route") { .exampleQueryStringRoute2(name: $0.query("name") ?? "") }
                $0.map("route/missing/param") { try .exampleStringDynamicRoute(named: $0.param("whoops")) }
            }
            ]
        )
    }
    
}
