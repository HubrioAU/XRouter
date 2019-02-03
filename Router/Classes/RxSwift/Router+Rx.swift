//
//  Router+Rx
//  XRouter
//

//#if canImport(RxSwift)

import RxSwift

extension Router {
    
    // MARK: - RxSwift
    
    /// Reactive binding for Router.
    public var rx: Reactive<Router> { // swiftlint:disable:this identifier_name
        return Reactive(self)
    }
    
}

extension Reactive {
    
    // MARK: - Completables
    
    /// Navigate to a route.
    public func navigate<Route>(to route: Route, animated: Bool = true) -> Completable where Base: Router<Route> {
        return .create { completable in
            self.base.navigate(to: route, animated: animated) { error in
                if let error = error {
                    completable(.error(error))
                } else {
                    completable(.completed)
                }
            }
            
            return Disposables.create {}
        }
    }
    
    /// Open a URL.
    /// - Returns: A `Single<Bool>` indicating whether the route was handled or not.
    @discardableResult
    public func openURL<Route>(_ url: URL, animated: Bool = true) -> Single<Bool> where Base: Router<Route> {
        return .create { single in
            do {
                if let route = try self.base.findMatchingRoute(for: url) {
                    self.base.navigate(to: route, animated: animated) { error in
                        if let error = error {
                            single(.error(error)) // Routing error
                        } else {
                            single(.success(true))
                        }
                    }
                } else {
                    single(.success(false)) // Unable to handle URL
                }
            } catch {
                // Error thrown while matching route
                single(.error(error))
            }
            
            return Disposables.create {}
        }
    }
    
}

//#endif
