//
//  ReactiveTestCase.swift
//  XRouter_ExampleTests
//
//  Created by Reece Como on 2/2/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest
import RxSwift
@testable import XRouter

/**
 RxSwift Reactive extension
 */
class ReactiveTestCase: XCTestCase {
    
    // MARK: - Properties
    
    /// Dispose bag
    var disposeBag = DisposeBag()
    
    // MARK: - RxSwift extensions
    
    /// Navigate
    @discardableResult
    internal func rxNavigate<Route: RouteProvider>(_ router: Router<Route>,
                                                   to route: Route,
                                                   failOnError: Bool = true) -> Error? {
        let expectation = self.expectation(description: "Navigate to router")
        var receivedError: Error?
        
        router.rx.navigate(to: route, animated: false).subscribe(onCompleted: {
            expectation.fulfill()
        }, onError: { error in
            receivedError = error
            expectation.fulfill()
        }).disposed(by: disposeBag)
        
        waitForExpectations(timeout: 3, handler: nil)
        
        if failOnError, let error = receivedError {
            XCTFail("Unexpected error occured navigating to route \(route.name): \(error.localizedDescription)")
        }
        
        return receivedError
    }
    
    /// Navigate and expect error
    func rxNavigateExpectError<Route: RouteProvider>(_ router: Router<Route>, to route: Route, error expectedError: Error) {
        let actualError = rxNavigate(router, to: route, failOnError: false)
        XCTAssertEqual(actualError?.localizedDescription, expectedError.localizedDescription)
    }
    
    /// Open URL
    @discardableResult
    internal func rxOpenURL<Route: RouteProvider>(_ router: Router<Route>, url: URL, failOnError: Bool = true) -> Error? {
        let expectation = self.expectation(description: "Navigate to URL")
        var receivedError: Error?
        
        router.rx.openURL(url, animated: false).subscribe(onSuccess: { _ in
            expectation.fulfill()
        }, onError: { error in
            receivedError = error
            expectation.fulfill()
        }).disposed(by: disposeBag)
        
        waitForExpectations(timeout: 3, handler: nil)
        
        if failOnError, let error = receivedError {
            XCTFail("Unexpected error occured opening URL \(url.absoluteString): \(error.localizedDescription)")
        }
        
        return receivedError
    }
    
    /// Open URL and expect error
    internal func rxOpenURLExpectError<Route: RouteProvider>(_ router: Router<Route>, url: URL, error expectedError: Error) {
        let actualError = rxOpenURL(router, url: url, failOnError: false)
        XCTAssertEqual(actualError?.localizedDescription, expectedError.localizedDescription)
    }
    
}
