//
//  Router.swift
//  XRouter_Example
//
//  Created by Reece Como on 9/2/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XRouter

/**
 Routes
 */
enum Route: RouteType {
    
    /// Tab 1 home
    case tab1Home
    
    /// Tab 2 home
    case tab2Home
    
    /// Example pushed view controller
    case pushedVC
    
    /// Example modal view controller
    case modalVC
    
    // MARK: - Helper
    
    /// Register URLs
    static func registerURLs() -> URLMatcherGroup<Route>? {
        return .group("hubr.io") {
            $0.map("tab2/home") { .tab2Home }
        }
    }
    
}


/**
 Router
 */
class Router: XRouter<Route> {
    
    // MARK: - Dependencies
    
    /// Container
    let container: Container
    
    // MARK: - Methods
    
    /// Constructor
    public init(container: Container) {
        self.container = container
        super.init()
    }
    
    // MARK: - RouteHandler
    
    /// Prepare the route for transition and return the view controller
    ///  to transition to on the view hierachy
    override func prepareForTransition(to route: Route) throws -> UIViewController {
        switch route {
        case .tab1Home:
            return container.tab1Coordinator.gotoTabHome()
        case .tab2Home:
            return container.tab2Coordinator.navigationController.viewControllers[0]
        case .pushedVC:
            return container.tab2SecondViewController
        case .modalVC:
            return container.modalCoordinator.start()
        }
    }
    
}
