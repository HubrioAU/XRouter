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
open class XRouter<R: RouteType>: RouteHandler<R> {
    
    // MARK: - Properties
    
    /// UIWindow. Defaults to `UIApplication.shared.keyWindow`.
    public lazy var window: UIWindow? = UIApplication.shared.keyWindow
    
    /// Route handler
    public var routeHandler: RouteHandler<R>?
    
    // MARK: - Internal Helpers
    
    /// Handles all of the navigation for presenting.
    private let navigator: Navigator<R> = .init()
    
    /// URL matcher group. Used to map URLs to Routes.
    /// - Note: See `RouteType.registerURLs()`
    internal lazy var urlMatcherGroup: URLMatcherGroup? = R.registerURLs()
    
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
    /// - Note: Triggers `received(unhandledError:)` if an error occurs and no completion
    ///         handler is provided.
    ///
    /// - Note: Will not trigger the transition if the the destination view controller is
    ///         the same as the source view controller or it's navigation controller. However,
    ///         it will call `RoutingDelgate(_:).prepareForTransition(to:)` either way.
    ///
    open func navigate(to route: R,
                       animated: Bool = true,
                       completion: ((Error?) -> Void)? = nil) {
        navigator.navigate(to: route,
                           using: routeHandler ?? self,
                           rootViewController: window?.rootViewController,
                           animated: animated,
                           completion: completionHandler(or: completion))
    }
    
    ///
    /// Open a URL to a route.
    ///
    /// - Note: Triggers `received(unhandledError:)` if an error occurs and no
    ///         completion handler is provided.
    ///
    /// - Note: Register URL mappings in the `RouteType` by implementing the
    ///         static method `registerURLs`.
    ///
    /// - Returns: A `Bool` indicating whether the URL was handled or not.
    ///
    @discardableResult
    open func openURL(_ url: URL,
                      animated: Bool = true,
                      completion: ((_ error: Error?) -> Void)? = nil) -> Bool {
        let urlMatcherError: Error?
        
        do {
            if let route = try urlMatcherGroup?.findMatch(forURL: url) {
                navigate(to: route, animated: animated, completion: completion)
                return true
            }
            
            urlMatcherError = nil
        } catch {
            urlMatcherError = error
        }
        
        completionHandler(or: completion)(urlMatcherError)
        return false
    }
    
    ///
    /// Universal links handler.
    ///
    /// - Note: Triggers `received(unhandledError:)` if an error occurs.
    ///
    /// - Note: Register URL mappings in the `RouteType` by implementing the
    ///         static method `registerURLs`.
    ///
    /// - Returns: A `Bool` indicating whether the `NSUserActivity` was handled
    ///            or not.
    ///
    open func `continue`(_ userActivity: NSUserActivity) -> Bool {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
            let url = userActivity.webpageURL else {
                return false
        }
        
        return openURL(url)
    }
    
    ///
    /// An error occured during `openURL(...)` or `navigate(...)` and no completion
    ///  handler was provided.
    ///
    /// - Note: In debug builds, this will cause an exception. In production builds
    ///         this will fail silently. See `assertionFailure`.
    ///
    open func received(unhandledError error: Error) {
        assertionFailure("An unhandled Router error occured: \(error.localizedDescription)")
    }
    
    // MARK: - Implementation
    
    ///
    /// Reports errors to `received(unhandledError:)` unless a completion handler is provided.
    ///
    private func completionHandler(or completion: ((Error?) -> Void)?) -> ((Error?) -> Void) {
        return completion ?? { error in
            guard let error = error else { return }
            self.received(unhandledError: error)
        }
    }
    
}
