//
//  RoutingHandler
//  XRouter
//

import Foundation

/**
 Routing Delegate
 
 This delegate is provided as a generic base class.
 
 Feel free to inherit from this base class and override the
 methods `prepareForTransition(to:)` and `transition(for:)`.
 */
open class RoutingHandler<Route: RouteType> {
    
    // MARK: - Methods
    
    ///
    /// Return the view controller for your Route here.
    ///
    /// It can be either a container (i.e. Navigation Controller) or an
    ///   instance of a single view controller.
    ///
    /// - Note: Throw an Error here to cancel the transition.
    ///
    open func prepareForTransition(to route: Route) throws -> UIViewController {
        throw RouterError.routeHasNotBeenConfigured
    }
    
    ///
    /// Presentation transition type for Route.
    ///
    open func transition(for route: Route) -> RouteTransition {
        return .inferred
    }
    
    // MARK: - Constructor
    
    /// Constructor
    public init() {
        // Required to set class visibility to public.
    }
    
}
