//
//  RouteTransition
//  XRouter
//

import Foundation

/**
 The types of presentation transitions for Routes.
 */
public enum RouteTransition {
    
    // MARK: - Transitions
    
    ///
    /// Automatically infer the best transition to use.
    ///
    case inferred
    
    ///
    /// Uses `UINavigationController(_:).pushViewController(_:animated:)`.
    ///
    /// - Note: This transition can *only* be used when you are navigating from a `UINavigationController`.
    ///
    /// If the view controller is already on the navigation stack, this method throws an exception.
    /// - See: https://developer.apple.com/documentation/uikit/uinavigationcontroller/1621887-pushviewcontroller?language=objc
    ///
    case push
    
    ///
    /// Uses `UIViewController(_:).present(_:animated:completion:)`.
    ///
    /// - See: https://developer.apple.com/documentation/uikit/uiviewcontroller/1621380-presentviewcontroller
    ///
    case modal
    
    ///
    /// Uses `UINavigationController(_:).setViewControllers(to:animated:)`.
    ///
    /// - Note: This transition can *only* be used when you are navigating from a `UINavigationController`.
    ///
    /// Use this to update or replace the current view controller stack without pushing or popping each controller explicitly.
    /// If animations are enabled, this method decides which type of transition to perform based on whether the last item in the items array is already in the navigation stack.
    /// If the view controller is currently in the stack, but is not the topmost item, this method uses a pop transition; if it is the topmost item, no transition is performed. If the view controller is not on the stack, this method uses a push transition.
    /// Only one transition is performed, but when that transition finishes, the entire contents of the stack are replaced with the new view controllers. For example, if controllers A, B, and C are on the stack and you set controllers D, A, and B, this method uses a pop transition and the resulting stack contains the controllers D, A, and B.
    /// - See: https://developer.apple.com/documentation/uikit/uinavigationcontroller/1621861-setviewcontrollers
    ///
    case set
    
    ///
    /// Uses a custom transition.
    ///
    /// - See `RouterCustomTransitionDelegate` for use.
    ///
    case custom(identifier: String)
    
}

extension RouteTransition {
    
    // MARK: - Properties
    
    /// Transition name
    /// - Example: `.custom(identifier: "myTransition")` becomes "myTransition"
    public var name: String {
        if case let .custom(identifier) = self {
            return identifier
        }
        
        return String(describing: self).components(separatedBy: "(")[0]
    }
    
}
    
extension RouteTransition: Equatable {
    
    // MARK: - Equatable
    
    /// Equatable (compares on `name`)
    public static func == (_ lhs: RouteTransition, _ rhs: RouteTransition) -> Bool {
        return lhs.name == rhs.name
    }
    
    /// Compares `name` property to some `String`
    public static func == (_ route: RouteTransition, _ string: String) -> Bool {
        return route.name == string
    }
    
}
