//
//  Router+Rx
//  XRouter
//

#if canImport(RxSwift)

import RxSwift

extension XRouter {
    
    // MARK: - RxSwift
    
    /// Reactive binding for Router.
    public var rx: Reactive<XRouter> { // swiftlint:disable:this identifier_name
        return Reactive(self)
    }
    
}

extension Reactive {
    
    // MARK: - Observables
    
    /// Navigate to a route.
    /// - Returns: A `Completable` indicating when the navigation has completed, or an `.error`.
    public func navigate<R>(to route: R, animated: Bool = true) -> Completable where Base: XRouter<R> {
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
    /// - Returns: A `Single<Bool>` indicating whether the route was handled or not, or an `.error`.
    @discardableResult
    public func openURL<R>(_ url: URL, animated: Bool = true) -> Single<Bool> where Base: XRouter<R> {
        return .create { single in
            do {
                if let route = try self.base.urlMatcherGroup?.findMatch(forURL: url) {
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

#endif
