//
//  RouteTransition
//  XRouter
//

import UIKit

/**
 The types of presentation transitions for Routes.
 
 ```swift
 let myTransition = RouteTransition { (source, destination, animated, completion) in
     source.present
 }
 ```
 */
public class RouteTransition: Equatable {
    
    /// Performs transition from source view controller to destination view controller.
    public var execute: (_ sourceViewController: UIViewController,
                         _ destViewController: UIViewController,
                         _ animated: Bool,
                         _ completion: @escaping (Error?) -> Void) -> ()
    
    /// Constructor.
    public init(_ execute: @escaping (UIViewController, UIViewController, Bool, @escaping (Error?) -> Void) -> Void) {
        self.execute = execute
    }
    
    /// Equatable.
    public static func == (_ lhs: RouteTransition, _ rhs: RouteTransition) -> Bool {
        return lhs === rhs
    }
    
}

extension RouteTransition {
    
    // MARK: - Built-in Transitions
    
    ///
    /// Automatically infers the best transition to use from the context.
    ///
    public static let inferred = RouteTransition { (source, destination, animated, completion) in
        if (source as? UINavigationController) == nil || (destination as? UINavigationController) != nil {
            modal.execute(source, destination, animated, completion)
        } else if destination.navigationController == source {
            set.execute(source, destination, animated, completion)
        } else {
            push.execute(source, destination, animated, completion)
        }
    }
    
    ///
    /// Uses `UIViewController(_:).present(_:animated:completion:)`.
    ///
    /// - See: https://developer.apple.com/documentation/uikit/uiviewcontroller/1621380-presentviewcontroller
    ///
    public static let modal = RouteTransition { (source, destination, animated, completion) in
        source.present(destination, animated: animated) {
            completion(nil)
        }
    }
    
    ///
    /// Uses `UINavigationController(_:).pushViewController(_:animated:)`.
    ///
    /// - Note: This transition can *only* be used when you are navigating from a `UINavigationController`.
    ///
    /// If the view controller is already on the navigation stack, this method throws an exception.
    /// - See: https://developer.apple.com/documentation/uikit/uinavigationcontroller/1621887-pushviewcontroller?language=objc
    ///
    public static let push = RouteTransition { (source, destination, animated, completion) in
        guard let navController = source as? UINavigationController else {
            completion(RouterError.missingRequiredNavigationController)
            return
        }
        
        navController.pushViewController(destination, animated: animated) {
            completion(nil)
        }
    }
    
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
    public static let set = RouteTransition { (source, destination, animated, completion) in
        guard let navController = source as? UINavigationController else {
            completion(RouterError.missingRequiredNavigationController)
            return
        }
        
        let viewControllers: [UIViewController]
        
        if let index = navController.viewControllers.firstIndex(of: destination) {
            //
            // Pop all view controllers above the destination
            //
            viewControllers = Array(navController.viewControllers[...index])
        } else {
            //
            // Set destination
            //
            viewControllers = [destination]
        }
        
        navController.setViewControllers(viewControllers, animated: animated) {
            completion(nil)
        }
    }
    
}
