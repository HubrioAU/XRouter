//
//  Navigator
//  XRouter
//

import Foundation

/**
 The Navigator.
 
 Responsible for handling the navigation events.
 */
internal class Navigator<Route: RouteType> {
    
    // MARK: - Methods
    
    ///
    /// Perform navigation to a Route.
    ///
    ///  - Prepares the navigation stack for transition
    ///  - Transitions to the route's view controller (but only if necessary)
    ///
    internal func navigate(to route: Route,
                           using routingHandler: RoutingHandler<Route>,
                           rootViewController: UIViewController?,
                           customTransitionDelegate: RouterCustomTransitionDelegate?,
                           animated: Bool,
                           completion: ((Error?) -> Void)?) {
        prepareForNavigation(to: route,
                             using: routingHandler,
                             rootViewController: rootViewController,
                             animated: animated,
                             onSuccess: { (sourceViewController, destinationViewController) in
                                self.performTransition(from: sourceViewController,
                                                       to: destinationViewController,
                                                       transition: routingHandler.transition(for: route),
                                                       customTransitionDelegate: customTransitionDelegate,
                                                       animated: animated,
                                                       completion: completion)
                
        }, onError: { error in
            completion?(error)
        })
    }
    
    // MARK: - Implementation
    
    ///
    /// Prepare the route for navigation.
    ///
    ///  - Fetches the route's view controller
    ///  - Checks the view controller is not already in the view hierarchy
    ///  - If it *is* already present, we navigate to the container view controller
    ///
    private func prepareForNavigation(to route: Route,
                                      using routingHandler: RoutingHandler<Route>,
                                      rootViewController: UIViewController?,
                                      animated: Bool,
                                      onSuccess successHandler: @escaping (_ source: UIViewController, _ destination: UIViewController) -> Void,
                                       onError errorHandler: @escaping (Error) -> Void) {
        guard let source = rootViewController?.topViewController else {
            errorHandler(RouterError.missingSourceViewController)
            return
        }
        
        let destination: UIViewController
        
        do {
            destination = try routingHandler.prepareForTransition(to: route)
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
            successHandler(nearestAncestor.topViewController, destination)
        }
    }
    
    ///
    /// Perform navigation
    ///
    private func performTransition(from source: UIViewController,
                                    to destination: UIViewController,
                                    transition: RouteTransition,
                                    customTransitionDelegate: RouterCustomTransitionDelegate?,
                                    animated: Bool,
                                    completion: ((Error?) -> Void)?) {
        // Already here/on current navigation controller
        if destination === source || destination === source.navigationController {
            // No error? -- maybe throw an "already here" error?
            completion?(nil)
            return
        }
        
        // The source view controller will be the navigation controller where
        //  possible - but will otherwise default to the current view controller
        //  i.e. for "present" transitions.
        let source = source.navigationController ?? source
        
        switch transition {
        case .inferred:
            inferTransition(source, destination, animated, completion)
            
        case .push:
            pushTransition(source, destination, animated, completion)
            
        case .set:
            setTransition(source, destination, animated, completion)
            
        case .modal:
            modalTransition(source, destination, animated, completion)
            
        case .custom:
            guard let delegate = customTransitionDelegate else {
                completion?(RouterError.missingCustomTransitionDelegate)
                return
            }
            
            delegate.performTransition(to: destination,
                                       from: source,
                                       transition: transition,
                                       animated: animated,
                                       completion: completion)
        }
    }
    
    // MARK: - Transitions
    
    /// Infer transition from context
    private func inferTransition(_ source: UIViewController,
                                 _ destination: UIViewController,
                                 _ animated: Bool,
                                 _ completion: ((Error?) -> Void)?) {
        if (source as? UINavigationController) == nil || (destination as? UINavigationController) != nil {
            modalTransition(source, destination, animated, completion)
        } else if destination.navigationController == source {
            setTransition(source, destination, animated, completion)
        } else {
            pushTransition(source, destination, animated, completion)
        }
    }
    
    /// Push transition
    private func pushTransition(_ source: UIViewController,
                                _ destination: UIViewController,
                                _ animated: Bool,
                                _ completion: ((Error?) -> Void)?) {
        guard let navController = source as? UINavigationController else {
            completion?(RouterError.missingRequiredNavigationController(for: .push))
            return
        }
        
        navController.pushViewController(destination, animated: animated) {
            completion?(nil)
        }
    }
    
    /// Set transition
    private func setTransition(_ source: UIViewController,
                               _ destination: UIViewController,
                               _ animated: Bool,
                               _ completion: ((Error?) -> Void)?) {
        guard let navController = source as? UINavigationController else {
            completion?(RouterError.missingRequiredNavigationController(for: .set))
            return
        }
        
        let viewControllers: [UIViewController]
        
        if let index = navController.viewControllers.firstIndex(of: destination) {
            //
            // Pop all view controllers above the destination
            //
            viewControllers = Array(navController.viewControllers[...index])
        } else {
            //
            // Set destination
            //
            viewControllers = [destination]
        }
        
        navController.setViewControllers(viewControllers, animated: animated) {
            completion?(nil)
        }
    }
    
    /// Modal transition
    private func modalTransition(_ source: UIViewController,
                                 _ destination: UIViewController,
                                 _ animated: Bool,
                                 _ completion: ((Error?) -> Void)?) {
        source.present(destination, animated: animated) {
            completion?(nil)
        }
    }
    
}
