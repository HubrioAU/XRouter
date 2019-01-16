//
//  XRouter.swift
//  XRouter
//
//  Created by Reece Como on 5/1/19.
//

import UIKit

/**
 An appliance that analyzes the navigation stack, and navigates you to the content you are trying to display.
 
 ```swift
 // Define your router, with a `RouteProvider`
 let router = Router<AppRoutes>()
 ```
 */
open class Router<Route: RouteProvider> {
    
    // MARK: - Properties
    
    /// Custom transition delegate
    public weak var customTransitionDelegate: RouterCustomTransitionDelegate?
    
    /// Register url matcher group
    private lazy var urlMatcherGroup: URLMatcherGroup? = Route.registerURLs()
    
    // MARK: - Computed properties
    
    /// The navigation controller for the currently presented view controller
    public var currentTopViewController: UIViewController? {
        return UIApplication.shared.getTopViewController()
    }
    
    // MARK: - Methods
    
    /// Initialiser
    public init() {
        // Placeholder, required to expose `init` as `public`
    }
    
    ///
    /// Navigate to a route.
    ///
    /// - Note: Has no effect if routing to the view controller/navigation controller you are already on,
    ///          where the view controller is provided by `RouteProvider(_:).prepareForTransition(...)`
    ///
    open func navigate(to route: Route, animated: Bool = true) throws {
        try prepareForNavigation(to: route, animated: animated) { newViewController in
            guard let currentViewController = self.currentTopViewController else { return }
            
            try self.performNavigation(to: newViewController,
                                       from: currentViewController,
                                       with: route.transition,
                                       animated: animated)
        }
        
    }
    
    ///
    /// Open a URL to a route.
    ///
    /// - Note: Register your URL mappings in your `RouteProvider` by
    ///         implementing the static method `registerURLs`.
    ///
    @discardableResult
    open func openURL(_ url: URL) throws -> Bool {
        guard let urlMatcherGroup = urlMatcherGroup else { return false }
        
        for urlMatcher in urlMatcherGroup.matchers {
            if let route = try urlMatcher.match(url: url) {
                try navigate(to: route)
                return true
            }
        }
        
        return false
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
                                      whenReady completion: @escaping (UIViewController) throws -> Void) throws {
        guard let currentViewController = currentTopViewController else { return }
        
        let newViewController = try route.prepareForTransition(from: currentViewController)
        
        if newViewController === currentViewController.navigationController
            || newViewController === currentViewController {
            // We're already presenting this view controller (or its navigation controller).
            try completion(newViewController)
        } else if newViewController.isActive() {
            // Trying to route to a view controller that is already presented somewhere
            //   in an existing navigation stack.
            
            guard currentViewController.hasAncestor(newViewController) else {
                // If this is not an ancestor of the current view controller, then we won't
                //  be able to automatically find a route.
                throw RouterError.unableToFindRouteToViewController
            }
            
            if let currentNavController = currentViewController.navigationController,
                !currentNavController.isBeingPresented,
                currentNavController == newViewController.navigationController {
                try? completion(newViewController)
            } else {
                // In the meantime let's attempt to find a route by dismissing any modals.
                newViewController.dismiss(animated: animated) {
                    // We were unable to tell ahead of time if there was any errors.
                    // - Note: We could move this to an error closure, but I'm not sure
                    //         what advantage that would give us.
                    try? completion(newViewController)
                }
            }
        } else {
            try completion(newViewController)
        }
    }
    
    /// Perform navigation
    private func performNavigation(to newViewController: UIViewController,
                                   from currentViewController: UIViewController,
                                   with transition: RouteTransition,
                                   animated: Bool) throws {
        // Sanity check, don't navigate if we're already here,
        //  or we're trying to set THIS view controller's navigation controller
        if newViewController === currentViewController
            || newViewController === currentViewController.navigationController {
            return
        }
        
        // The source view controller will be the navigation controller where
        //  possible - but will otherwise default to the current view controller
        //  i.e. for "present" transitions.
        let sourceViewController = currentViewController.navigationController ?? currentViewController
        
        switch transition {
        case .push:
            guard let navController = sourceViewController as? UINavigationController else {
                throw RouterError.missingRequiredNavigationController(for: transition)
            }
            navController.pushViewController(newViewController, animated: animated)
            
        case .set:
            guard let navController = sourceViewController as? UINavigationController else {
                throw RouterError.missingRequiredNavigationController(for: transition)
            }
            navController.setViewControllers([newViewController], animated: animated)
            
        case .modal:
            sourceViewController.present(newViewController, animated: animated)
            
        case .custom:
            guard let customTransitionDelegate = customTransitionDelegate else {
                throw RouterError.missingCustomTransitionDelegate
            }
            
            customTransitionDelegate.performTransition(to: newViewController,
                                                       from: sourceViewController,
                                                       transition: transition,
                                                       animated: animated)
        }
    }
    
}
