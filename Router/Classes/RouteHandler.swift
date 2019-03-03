//
//  RouteHandler
//  XRouter
//

import Foundation

/**
 Route Handler
 
 This delegate is provided as a generic base class.
 
 Feel free to inherit from this base class and override the
 methods `prepareForTransition(to:)` and `transition(for:)`.
 */
open class RouteHandler<R: RouteType> {
    
    // MARK: - Constructor
    
    /// Constructor.
    /// Required to set class visibility to public.
    public init() {}
    
    // MARK: - Methods
    
    ///
    /// Return the view controller for your Route here.
    ///
    /// It can be either a container (i.e. Navigation Controller) or an
    ///   instance of a single view controller.
    ///
    /// - Note: Throw an Error here to cancel the transition.
    ///
    open func prepareForTransition(to route: R) throws -> UIViewController {
        throw RouterError.routeHasNotBeenConfigured
    }
    
    ///
    /// Presentation transition type for Route.
    ///
    open func transition(for route: R) -> RouteTransition {
        return .inferred
    }
    
}
