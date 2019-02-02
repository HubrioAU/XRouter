//
//  XCTestCase+Extension.swift
//  XRouter_Tests
//
//  Created by Reece Como on 16/1/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest
@testable import XRouter

extension XCTestCase {
    
    // MARK: - Blocking Helpers
    
    /// Navigate
    @discardableResult
    internal func navigate<Route: RouteProvider>(_ router: Router<Route>, to route: Route, failOnError: Bool = true) -> Error? {
        let expectation = self.expectation(description: "Navigate to router")
        var receivedError: Error?
        
        router.navigate(to: route, animated: false) { error in
            receivedError = error
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 3, handler: nil)
        
        if failOnError, let error = receivedError {
            XCTFail("Unexpected error occured navigating to route \(route.name): \(error.localizedDescription)")
        }
        
        return receivedError
    }
    
    /// Navigate and expect error
    func navigateExpectError<Route: RouteProvider>(_ router: Router<Route>, to route: Route, error expectedError: Error) {
        let actualError = navigate(router, to: route, failOnError: false)
        XCTAssertEqual(actualError?.localizedDescription, expectedError.localizedDescription)
    }
    
    /// Open URL
    @discardableResult
    internal func openURL<Route: RouteProvider>(_ router: Router<Route>, url: URL, failOnError: Bool = true) -> Error? {
        let expectation = self.expectation(description: "Navigate to URL")
        var receivedError: Error?
        
        router.openURL(url, animated: false) { error in
            receivedError = error
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 3, handler: nil)
        
        if failOnError, let error = receivedError {
            XCTFail("Unexpected error occured opening URL \(url.absoluteString): \(error.localizedDescription)")
        }
        
        return receivedError
    }
    
    /// Open URL and expect error
    internal func openURLExpectError<Route: RouteProvider>(_ router: Router<Route>, url: URL, error expectedError: Error) {
        let actualError = openURL(router, url: url, failOnError: false)
        XCTAssertEqual(actualError?.localizedDescription, expectedError.localizedDescription)
    }

}
