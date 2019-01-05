//
//  AppDelegate.swift
//  XRouter_Example
//
//  Created by Reece Como on 01/05/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import XRouter

/**
 Demo project
 */

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    /// Router
    let router = Router<Route>()

    /// Window
    var window: UIWindow?
    
    /// Home View Controller
    static let homeViewController = ColoredViewController(color: .green, title: "home")

    /// Setup app
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = UINavigationController(rootViewController: AppDelegate.homeViewController)
        window?.makeKeyAndVisible()
        
        navigateToNextRoute(delay: 3)
        return true
    }
    
    // MARK: - Automatic Demo Implementation
    
    /// Index for the current page
    private var currentPageIndex = 0
    
    /// Pages to cycle through
    private let pages: [Route] = [
        .home,
        .red,
        .blue,
        .other(color: .purple),
        .other(color: .yellow),
        .exampleFlowBasic,
        .exampleFlowFull,
        .home,
        .exampleFlowFull,
        .blue,
        .other(color: .purple),
        .exampleFlowBasic,
        .home,
        .home,
        .other(color: .orange),
        .red
    ]
    
    /// Go to the next route
    private func navigateToNextRoute(delay: TimeInterval = 3) {
        let nextRoute = getNextRoute()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            print("Routing to: \(nextRoute.name)")
            try? self.router.navigate(to: nextRoute)
            
            // Start next route
            self.navigateToNextRoute(delay: delay)
        }
    }
    
    /// Get a the next route
    private func getNextRoute() -> Route {
        let nextRoute = pages[currentPageIndex]
        currentPageIndex = (currentPageIndex + 1) % pages.count
        return nextRoute
    }
    
}
