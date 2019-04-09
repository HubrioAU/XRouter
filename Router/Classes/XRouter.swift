//
//  Router<RouteType>
//  XRouter
//

import UIKit

/**
 A routing appliance used to navigate to the start of flows.
 
 ```
 router.navigate(to: .profile(withID: 23))
 ```
 */
open class XRouter<R: RouteType>: RouteHandler<R> {
    
    // MARK: - Properties
    
    /// UIWindow. Defaults to `UIApplication.shared.keyWindow`.
    public lazy var window: UIWindow? = UIApplication.shared.keyWindow
    
    /// Route handler. Defaults to `self`.
    public lazy var routeHandler: RouteHandler<R> = self
    
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
                           using: routeHandler,
                           rootViewController: window?.rootViewController,
                           animated: animated,
                           completion: completion ?? fallbackCompletionHandler)
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
        let completion = completion ?? fallbackCompletionHandler
        
        do {
            if let route = try urlMatcherGroup?.findMatch(forURL: url) {
                navigate(to: route, animated: animated, completion: completion)
                return true
            }
            
            urlMatcherError = nil
        } catch {
            urlMatcherError = error
        }
        
        completion(urlMatcherError)
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
    /// An unhandled error occured during `navigate(...)` or `openURL(...)`.
    ///
    /// - Note: Uses `assertionFailure(_:file:line:)`. In debug builds,
    ///         this will throw a runtime exception. In production builds
    ///         this will fail silently.
    ///
    /// - See: https://developer.apple.com/documentation/swift/1539616-assertionfailure
    ///
    open func received(unhandledError error: Error) {
        assertionFailure("XRouter received an unhandled error: \(error.localizedDescription)")
    }
    
    // MARK: - Implementation
    
    /// Fallback completion handler to report unhandled errors.
    private func fallbackCompletionHandler(_ optionalError: Error?) {
        guard let error = optionalError else { return }
        received(unhandledError: error)
    }
    
}
