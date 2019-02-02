//
//  Router+Rx.swift
//  XRouter
//
//  Created by Reece Como on 2/2/19.
//

#if canImport(RxSwift)
import RxSwift

extension Router {
    
    /// Reactive binding for Router.
    public var rx: Reactive<Router> { // swiftlint:disable:this identifier_name
        return Reactive(self)
    }
    
}

extension Reactive {
    
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
    @discardableResult
    public func openURL<Route>(_ url: URL, animated: Bool = true) -> Completable where Base: Router<Route> {
        return .create { completable in
            self.base.openURL(url, animated: animated) { error in
                if let error = error {
                    completable(.error(error))
                } else {
                    completable(.completed)
                }
            }
            
            return Disposables.create {}
        }
    }
    
}

#endif
