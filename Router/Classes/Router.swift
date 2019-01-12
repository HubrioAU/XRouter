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
        return UIApplication.shared.topViewController()
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
            try self.performNavigation(to: newViewController,
                                       from: self.currentTopViewController!, // swiftlint:disable:this force_unwrapping
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
        let currentViewController = currentTopViewController! // swiftlint:disable:this force_unwrapping
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
            
            // In the meantime let's attempt to find a route by dismissing any modals.
            newViewController.dismiss(animated: animated) {
                // We were unable to tell ahead of time if there was any errors.
                // - Note: We could move this to an error closure, but I'm not sure
                //         what advantage that would give us.
                try? completion(newViewController)
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
        // Sanity check, don't navigate if we're already here
        if newViewController === currentViewController.navigationController
            || newViewController === currentViewController {
            return
        }
        
        let fromViewController = currentViewController.navigationController ?? currentViewController
        
        if transition.requiresNavigationController, fromViewController as? UINavigationController == nil {
            throw RouterError.missingRequiredNavigationController(for: transition)
        }
        
        switch transition {
        case .push:
            (fromViewController as! UINavigationController).pushViewController(newViewController, animated: animated)
        case .set:
            (fromViewController as! UINavigationController).setViewControllers([newViewController], animated: animated)
        case .modal:
            fromViewController.present(newViewController, animated: animated)
        case .custom:
            customTransitionDelegate?.performTransition(to: newViewController,
                                                        from: fromViewController,
                                                        transition: transition,
                                                        animated: animated)
        }
    }
    
}
