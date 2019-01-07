//
//  UIViewControllerExtensionTests.swift
//  XRouter_Tests
//
//  Created by Reece Como on 8/1/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest
import UIKit
@testable import XRouter

/**
 RouteProvider Tests
 */
class UIViewControllerExtensionTests: XCTestCase {
    
    /// Test custom transition is triggered
    func testHasAncestor() {
        let viewController1 = UINavigationController()
        let viewController2 = UIViewController()
        XCTAssertFalse(viewController1.hasAncestor(viewController2))
        
        let viewController3 = UIViewController()
        let viewController4 = UINavigationController(rootViewController: viewController3)
        XCTAssert(viewController3.hasAncestor(viewController4))
    }
    
}
