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
    /// - Note: Has no effect if the destination view controller is the view controller or navigation controller
    ///         you are presently on - as provided by `RouteProvider(_:).prepareForTransition(...)`.
    ///
    open func navigate(to route: Route, animated: Bool = true, completion: ((Error?) -> Void)? = nil) {
        prepareForNavigation(to: route, animated: animated, successHandler: { source, destination in
            self.performNavigation(from: source,
                                   to: destination,
                                   with: route.transition,
                                   animated: animated,
                                   completion: completion)
        }, errorHandler: { error in
            completion?(error)
        })
    }
    
    ///
    /// Open a URL to a route.
    ///
    /// - Note: Register your URL mappings in your `RouteProvider` by
    ///         implementing the static method `registerURLs`.
    ///
    @discardableResult
    open func openURL(_ url: URL, animated: Bool = true, completion: ((Error?) -> Void)? = nil) -> Bool {
        do {
            if let route = try findMatchingRoute(for: url) {
                navigate(to: route, animated: animated, completion: completion)
                return true
            } else {
                completion?(nil) // No matching route.
            }
        } catch {
            completion?(error) // There was an error.
        }
        
        return false
    }
    
    // MARK: - Implementation
    
    ///
    /// Prepare the route for navigation.
    ///
    ///     - Fetching the view controller we want to present
    ///     - Checking if its already in the view heirarchy
    ///         - Checking if it is a direct ancestor and then closing its children/siblings
    ///
    /// - Note: The completion block will not execute if we could not find a route
    ///
    private func prepareForNavigation(to route: Route,
                                      animated: Bool,
                                      successHandler: @escaping (_ source: UIViewController, _ destination: UIViewController) -> Void,
                                      errorHandler: @escaping (Error) -> Void) {
        guard let source = currentTopViewController else {
            errorHandler(RouterError.missingSourceViewController)
            return
        }
        
        let destination: UIViewController
        
        do {
            destination = try route.prepareForTransition(from: source)
        } catch {
            errorHandler(error)
            return
        }
    
        guard let nearestAncestor = source.getLowestCommonAncestor(with: destination) else {
            // No common ancestor - Adding destination to the stack for the first time
            successHandler(source, destination)
            return
        }
        
        // Clear modal - then prepare for child view controller.
        nearestAncestor.transition(toDescendant: destination, animated: animated) {
            successHandler(nearestAncestor.visibleViewController, destination)
        }
    }
    
    /// Perform navigation
    private func performNavigation(from source: UIViewController,
                                   to destination: UIViewController,
                                   with transition: RouteTransition,
                                   animated: Bool,
                                   completion: ((Error?) -> Void)?) {
        // Already here/on current navigation controller
        if destination === source || destination === source.navigationController {
            // No error? -- maybe throw an "already here" error
            completion?(nil)
            return
        }
        
        // The source view controller will be the navigation controller where
        //  possible - but will otherwise default to the current view controller
        //  i.e. for "present" transitions.
        let source = source.navigationController ?? source
        
        switch transition {
        case .push:
            if let navController = source as? UINavigationController {
                navController.pushViewController(destination, animated: animated) {
                    completion?(nil)
                }
            } else {
                completion?(RouterError.missingRequiredNavigationController(for: transition))
            }
            
            
        case .set:
            if let navController = source as? UINavigationController {
                navController.setViewControllers([destination], animated: animated) {
                    completion?(nil)
                }
            } else {
                completion?(RouterError.missingRequiredNavigationController(for: transition))
            }
            
        case .modal:
            source.present(destination, animated: animated) {
                completion?(nil)
            }
            
        case .custom:
            if let customTransitionDelegate = customTransitionDelegate {
                customTransitionDelegate.performTransition(to: destination,
                                                           from: source,
                                                           transition: transition,
                                                           animated: animated,
                                                           completion: completion)
            } else {
                completion?(RouterError.missingCustomTransitionDelegate)
            }
        }
    }
    
    ///
    /// Find a matching Route for a URL.
    ///
    /// - Note: This method throws an error when the route is mapped
    ///         but the mapping fails.
    ///
    private func findMatchingRoute(for url: URL) throws -> Route? {
        if let urlMatcherGroup = urlMatcherGroup {
            for urlMatcher in urlMatcherGroup.matchers {
                if let route = try urlMatcher.match(url: url) {
                    return route
                }
            }
        }
        
        return nil
    }
    
}
