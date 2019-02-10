//
//  Router<RouteType>
//  XRouter
//

import UIKit

/**
 Router
 
 An appliance that allows you to trigger flows and navigate straight to
 statically declared destinations in just one line:
 
 ```
 router.navigate(to: .profile(withID: 23))
 ```
 */
open class Router<Route: RouteType>: RoutingDelegate<Route> {
    
    // MARK: - Properties
    
    /// Custom transition delegate
    public weak var customTransitionDelegate: RouterCustomTransitionDelegate?
    
    /// Routing delegate
    public var routingDelegate: RoutingDelegate<Route>?
    
    /// Window
    public lazy var window: UIWindow? = UIApplication.shared.keyWindow
    
    // MARK: - Internal Helpers
    
    /// Handles all of the navigation for presenting.
    private let navigator: Navigator<Route> = .init()
    
    /// URL Matcher Group.
    ///  - Used to store mappings of URLs to Routes.
    ///  - See `RouteType.registerURLs()`
    internal lazy var urlMatcherGroup: URLMatcherGroup? = Route.registerURLs()
    
    // MARK: - Constructors
    
    /// Initialize explicitly with a window. Defaults to `UIApplication.shared.keyWindow`.
    public init(window: UIWindow?) {
        super.init()
        self.window = window
    }
    
    /// Defaults to `UIApplication.shared.keyWindow`.
    override public init() {
        super.init()
    }
    
    // MARK: - Methods
    
    ///
    /// Navigate to a route.
    ///
    /// - Note: Will not trigger the transition if the the destination view controller is
    ///         the same as the source view controller or it's navigation controller. However,
    ///         it will call `RoutingDelgate(_:).prepareForTransition(to:)` either way.
    ///
    open func navigate(to route: Route,
                       animated: Bool = true,
                       completion: ((Error?) -> Void)? = nil) {
        navigator.navigate(to: route,
                           using: routingDelegate ?? self,
                           rootViewController: window?.rootViewController,
                           customTransitionDelegate: customTransitionDelegate,
                           animated: animated,
                           completion: completion)
    }
    
    ///
    /// Open a URL to a route.
    ///
    /// - Note: The completion handler is triggered in all cases.
    ///
    /// - Note: Register your URL mappings in your `RouteType` by
    ///         implementing the static method `registerURLs`.
    ///
    /// - Returns: A `Bool` indicating whether the URL was handled or not.
    ///
    @discardableResult
    open func openURL(_ url: URL,
                      animated: Bool = true,
                      completion: ((_ error: Error?) -> Void)? = nil) -> Bool {
        do {
            if let route = try urlMatcherGroup?.findMatch(forURL: url) {
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
    
}
