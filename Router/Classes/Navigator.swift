//
//  Navigator
//  XRouter
//

import Foundation

/**
 The Navigator.
 
 Responsible for handling the navigation events.
 */
internal class Navigator<R: RouteType> {
    
    // MARK: - Methods
    
    ///
    /// Perform navigation to a Route.
    ///
    ///  - Prepares the navigation stack for transition
    ///  - Transitions to the route's view controller (but only if necessary)
    ///
    internal func navigate(to route: R,
                           using routeHandler: RouteHandler<R>,
                           rootViewController: UIViewController?,
                           animated: Bool,
                           completion: ((Error?) -> Void)?) {
        prepareForNavigation(to: route,
                             using: routeHandler,
                             rootViewController: rootViewController,
                             animated: animated,
                             onSuccess: { (sourceViewController, destinationViewController) in
                                self.performTransition(from: sourceViewController,
                                                       to: destinationViewController,
                                                       transition: routeHandler.transition(for: route),
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
    private func prepareForNavigation(to route: R,
                                      using routeHandler: RouteHandler<R>,
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
            destination = try routeHandler.prepareForTransition(to: route)
        } catch {
            errorHandler(error)
            return
        }
        
        guard let nearestAncestor = source.getNearestCommonAncestor(with: destination) else {
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
    /// Perform the transition.
    ///
    private func performTransition(from source: UIViewController,
                                   to destination: UIViewController,
                                   transition: RouteTransition,
                                   animated: Bool,
                                   completion: ((Error?) -> Void)?) {
        // Already here/on the current navigation controller.
        if destination === source || destination === source.navigationController {
            completion?(nil)
            return
        }
        
        // The source view controller will be the navigation controller where
        //  possible - but will otherwise default to the current view controller
        //  i.e. for "present" transitions.
        let source = source.navigationController ?? source
        
        // Perform the transition.
        transition.perform(source, destination, animated, completion)
    }
    
}
