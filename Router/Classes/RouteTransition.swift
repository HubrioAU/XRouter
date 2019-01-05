//
//  RouteTransition.swift
//  Router
//
//  Created by Reece Como on 5/1/19.
//

import Foundation

/**
 Route transition type
 */
public enum RouteTransition {
    
    /// Uses `UINavigationController(_:).pushViewController(_:animated:)`.
    /// If the view controller is already on the navigation stack, this method throws an exception.
    /// - See: https://developer.apple.com/documentation/uikit/uinavigationcontroller/1621887-pushviewcontroller?language=objc
    case push
    
    /// Uses `UINavigationController(_:).setViewControllers(to:animated:)`.
    /// Use this to update or replace the current view controller stack without pushing or popping each controller explicitly.
    /// If animations are enabled, this method decides which type of transition to perform based on whether the last item in the items array is already in the navigation stack. If the view controller is currently in the stack, but is not the topmost item, this method uses a pop transition; if it is the topmost item, no transition is performed. If the view controller is not on the stack, this method uses a push transition. Only one transition is performed, but when that transition finishes, the entire contents of the stack are replaced with the new view controllers. For example, if controllers A, B, and C are on the stack and you set controllers D, A, and B, this method uses a pop transition and the resulting stack contains the controllers D, A, and B.
    /// - See: https://developer.apple.com/documentation/uikit/uinavigationcontroller/1621861-setviewcontrollers
    case set
    
    /// Uses `UIViewController(_:).present(_:animated:completion:)`.
    /// - See: https://developer.apple.com/documentation/uikit/uiviewcontroller/1621380-presentviewcontroller
    case modal
    
    /// Uses a custom transition.
    /// - See `RouterCustomTransitionDelegate` for use.
    case custom(identifier: String)
    
}

extension RouteTransition {
    
    /// Enum case identifier as a `String`
    /// - Example: `case myAwesomeView(withID: Int)` becomes "myAwesomeView"
    public var name: String {
        return String(describing: self).components(separatedBy: "(")[0]
    }
    
}
