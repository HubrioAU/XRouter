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
    /// Configure the view controller for your route here.
    ///
    /// You can either give it the container (i.e. Navigation Controller) or an
    ///   instance of a single view controller.
    ///
    /// - Note: Throw any `Error` here to cancel the transition.
    ///
    open func viewController(for route: R) throws -> UIViewController {
        throw RouterError.routeHasNotBeenConfigured
    }
    
    ///
    /// Presentation transition type for Route.
    ///
    open func transition(for route: R) -> RouteTransition {
        return .inferred
    }
    
}
