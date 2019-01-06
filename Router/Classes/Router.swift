//
//  Router.swift
//  Router
//
//  Created by Reece Como on 5/1/19.
//

import UIKit

/**
 Router
 
 ```
 // Define your router
 let router = Router<Routes>()
 
 // Navigate to pages
 try? router.navigate(to: .myPage)
 ```
 */
public class Router<Route: RouteProvider> {
    
    // MARK: - Properties
    
    /// Custom transition delegate
    public weak var customTransitionDelegate: RouterCustomTransitionDelegate?
    
    /// The navigation controller for the currently presented view controller
    public var currentTopViewController: UIViewController? {
        return UIApplication.shared.topViewController()
    }
    
    // MARK: - Methods
    
    /// Initialiser
    public init() {
        // This is just here to set `public` accessor for `init`
    }
    
    ///
    /// Navigate to a route.
    ///
    /// - Note: Has no effect if routing to the view controller/navigation controller you are already on,
    ///          where the view controller is provided by `RouteProvider(_:).prepareForTransition(...)`
    ///
    public func navigate(to route: Route, animated: Bool = true) throws {
        try prepareForNavigation(to: route, animated: animated) { viewController in
            guard let navigationController = self.currentTopViewController?.navigationController else { return }
            
            if viewController !== self.currentTopViewController && viewController !== navigationController {
                self.performNavigation(to: route, with: viewController, from: navigationController, animated: animated)
            }
            
            // Attempting to route to the view controller/navigation
            //  controller you are already on, ignoring request.
        }
        
    }
    
    // MARK: - Implementation
    
    ///
    /// Prepare the route for navigation by:
    ///     - Fetching the view controller we want to present
    ///     - Checking if its already in the view heirarchy
    ///         - Checking if it is a direct ancestor and then closing its children/siblings
    ///
    /// - Note: The completion block will not execute if we could not find a route
    ///
    private func prepareForNavigation(to route: Route,
                                      animated: Bool,
                                      whenReady completion: @escaping (UIViewController) -> Void) throws {
        guard let currentTopViewController = currentTopViewController else {
            throw NSError(domain: "No view controllers present on the view hierachy", code: -1, userInfo: nil)
        }
        
        let viewController = try route.prepareForTransition(from: currentTopViewController)
        
        if viewController.isActive() {
            // View controller is already in the hierachy
            
            if currentTopViewController.hasAncestor(viewController) {
                // Current controller is a direct descendant of this view controller,
                //  so lets pop it and reset the view controllers.
                
                viewController.dismiss(animated: animated) {
                    completion(viewController)
                }
            } else {
                throw NSError(domain: """
The view controller was in the hierachy but was not an ancestor of current view controller, so we were unable to automatically find a route to it
""", code: -1, userInfo: nil)
            }
            
        } else {
            completion(viewController)
        }
    }
    
    /// Perform navigation
    private func performNavigation(to route: Route,
                                   with preparedViewController: UIViewController,
                                   from currentNavigationController: UINavigationController,
                                   animated: Bool) {
        switch route.transition {
        case .push:
            currentNavigationController.pushViewController(preparedViewController, animated: animated)
        case .modal:
            currentNavigationController.present(preparedViewController, animated: animated)
        case .set:
            currentNavigationController.setViewControllers([preparedViewController], animated: animated)
        case .custom:
            customTransitionDelegate?.performTransition(to: preparedViewController,
                                                        from: currentNavigationController,
                                                        transition: route.transition,
                                                        animated: animated)
        }
    }
    
}
