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
    
}


/**
 Router
 */
class Router: XRouter.Router<Route> {
    
    // MARK: - Dependencies
    
    /// Container
    let container: Container
    
    // MARK: - Methods
    
    /// Constructor
    public init(container: Container) {
        self.container = container
        super.init()
    }
    
    // MARK: - RouteDestinationProvider
    
    /// Transitions for the view controllers
    override func transition(for route: Route) -> RouteTransition {
        switch route {
        case .tab1Home,
             .tab2Home:
            return .set
        case .pushedVC:
            return .push
        case .modalVC:
            return .modal
        }
    }
    
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
    
    override func navigate(to route: Route, animated: Bool = true, completion: ((Error?) -> Void)? = nil) {
        super.navigate(to: route, animated: animated) { optionalError in
            if let error = optionalError {
                print("There was an error: \(error)")
            }
        }
    }
    
}
