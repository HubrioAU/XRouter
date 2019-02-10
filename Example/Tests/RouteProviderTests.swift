//
//  RouteTypeTests.swift
//  XRouter_Tests
//
//  Created by Reece Como on 7/1/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest
import UIKit
@testable import XRouter

/**
 RouteType Tests
 */
class RouteTypeTests: XCTestCase {
    
    /// Test custom transition is triggered
    func testEquatableOnUniqueNames() {
        // We've configured `TestRoute.profile` to be unique on `uniqueID`
        XCTAssertEqual(TestRoute.profile(uniqueParameter: "12345"),
                       TestRoute.profile(uniqueParameter: "12345"))
        
        XCTAssertNotEqual(TestRoute.profile(uniqueParameter: "12345"),
                          TestRoute.profile(uniqueParameter: "ABCDE"))
        
        XCTAssertEqual(TestRoute.settings(someIgnoredParameter: "ABCDE"),
                       TestRoute.settings(someIgnoredParameter: "12345"))
    }
    
}

/**
 We've configured our TestRoutes `name` parameter to be
    unique for `.profile(...)` but not for `.settings(...)`
 */
private enum TestRoute: RouteType {
    
    case profile(uniqueParameter: String)
    case settings(someIgnoredParameter: String)
    
    var name: String {
        if case let .profile(uniqueID) = self {
            return "profile(\(uniqueID))"
        }
        
        return baseName
    }
    
    // MARK: - RouteType
    
    var transition: RouteTransition {
        fatalError("'transition' not implemented")
    }
    
    func prepareForTransition(from viewController: UIViewController) throws -> UIViewController {
        fatalError("'prepareForTransition' not implemented")
    }
    
}
