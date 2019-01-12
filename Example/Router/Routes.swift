//
//  Routes.swift
//  XRouter_Example
//
//  Created by Reece Como on 5/1/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XRouter

/**
 Example Routes
 
 */
enum MyRoute: RouteProvider {
    
    /// Root view controller
    case home
    
    /// Pushed red view controller
    case red
    
    /// Pushed blue view controller
    case blue(named: String)
    
    /// Presented modally some example navigation controller.
    ///  Skips directly to 2/3 view controllers
    /// - See: `ExampleFlowController(_:).startBasicFlow()`
    case exampleFlowBasic
    
    /// Presented modally some example navigation controller
    ///  Skips directly to the last view controllers
    /// - See: `ExampleFlowController(_:).startFullFlow()`
    case exampleFlowFull
    
    /// Presented modally view controller with some color
    case other(color: UIColor)
    
    //
    // MARK: - RouteProvider
    //
    
    /// Transitions for the view controllers
    var transition: RouteTransition {
        switch self {
        case .home:
            return .set
        case .red,
             .blue:
            return .push
        case .exampleFlowBasic,
             .exampleFlowFull,
             .other:
            return .modal
        default:
            return .modal
        }
    }
    
    /// Prepare the route for transition and return the view controller
    ///  to transition to on the view hierachy
    func prepareForTransition(from viewController: UIViewController) throws -> UIViewController {
        switch self {
        case .home:
            return AppDelegate.homeViewController
        case .red:
            return ColoredViewController(color: .red, title: "red")
        case .blue(let name):
            return ColoredViewController(color: .blue, title: "blue \(name)")
        case .exampleFlowBasic:
            return ExampleFlowController.shared.startBasicFlow()
        case .exampleFlowFull:
            return ExampleFlowController.shared.startFullFlow()
        case .other(let color):
            // Embedded in a navigation controller
            return UINavigationController(rootViewController: ColoredViewController(color: color, title: name))
        }
    }
    
    static func registerURLs() -> Router<MyRoute>.URLMatcherGroup? {
        return .group(["example.com"]) {
            $0.map("home/") { .home }
            $0.map("colors/red") { .red }
            $0.map("colors/blue/{name}") { try .blue(named: $0.param("name")) }
        }
    }
    
}
