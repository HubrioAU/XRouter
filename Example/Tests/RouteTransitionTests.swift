//
//  RouteTransitionTests.swift
//  XRouter_Tests
//
//  Created by Reece Como on 7/1/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest
@testable import XRouter

class RouteTransitionTests: XCTestCase {
    
    /// Test that the ".name" String identifier
    func testName() {
        // Provided transitions
        XCTAssertEqual(RouteTransition.push.name, "push")
        XCTAssertEqual(RouteTransition.modal.name, "modal")
        XCTAssertEqual(RouteTransition.set.name, "set")
        
        // Custom transitions
        let customTransition: RouteTransition = .custom(identifier: "myCoolTransition")
        XCTAssertEqual(customTransition.name, "myCoolTransition")
    }
    
    /// Test that RouteTransitions are Equatable
    func testEquatable() {
        // Provided transitions
        XCTAssertEqual(RouteTransition.push, RouteTransition.push)
        XCTAssertNotEqual(RouteTransition.push, RouteTransition.modal)
        
        // Custom
        let customTransition: RouteTransition = .custom(identifier: "myTransition")
        XCTAssert(customTransition == .custom(identifier: "myTransition"))
        XCTAssert(customTransition == "myTransition")
        XCTAssertFalse(customTransition == .custom(identifier: "mytransition"))
    }
    
}
