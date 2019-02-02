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
    let router = Router<MyRoute>()

    /// Window
    var window: UIWindow?
    
    /// Home View Controller
    static let homeViewController = ColoredViewController(color: .green, title: "home")
    
    /// Second tab view contorller
    static let secondTabViewController = ColoredViewController(color: .brown, title: "other tab")
    
    /// Setup app
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        window = UIWindow(frame: UIScreen.main.bounds)
        
        // Create tab bar controller
        let tabBarController = UITabBarController()
        let tabOneNavigationController = UINavigationController(rootViewController: AppDelegate.homeViewController)
        let tabTwoNavigationController = UINavigationController(rootViewController: AppDelegate.secondTabViewController)
        
        tabBarController.setViewControllers([
            tabOneNavigationController,
            tabTwoNavigationController
            ], animated: false)
        
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
        
        let delay: TimeInterval = 2
        openURLS(delay: delay, andThen: {
            self.navigateToNextRoute(delay: delay)
        })
        
        return true
    }
    
    // MARK: - Automatic Demo Implementation
    
    /// Index for the current page
    private var currentPageIndex = 0
    
    /// Pages to cycle through
    private let pages: [MyRoute] = [
        .red,
        .blue(named: "default"),
        .other(color: .purple),
        .other(color: .yellow),
        .exampleFlowBasic,
        .exampleFlowFull,
        .home,
        .exampleFlowFull,
        .blue(named: "default"),
        .other(color: .purple),
        .exampleFlowBasic,
        .home,
        .home,
        .other(color: .orange),
        .red
    ]
    
    /// Open all the URLs
    private func openURLS(delay: TimeInterval = 3, andThen completion: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            guard let url = URL(string: "https://example.com/colors/red") else { return }
            print("Routing to red")
            self.router.openURL(url)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                guard let url = URL(string: "https://example.com/colors/blue/link") else { return }
                print("Routing to blue")
                self.router.openURL(url)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    guard let url = URL(string: "https://example.com/home") else { return }
                    print("Routing to home")
                    self.router.openURL(url)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: completion)
                }
            }
        }
    }
    
    /// Go to the next route
    private func navigateToNextRoute(delay: TimeInterval = 3) {
        let nextRoute = getNextRoute()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            print("Routing to: \(nextRoute.name)")
            self.router.navigate(to: nextRoute)
            
            // Start next route
            self.navigateToNextRoute(delay: delay)
        }
    }
    
    /// Get a the next route
    private func getNextRoute() -> MyRoute {
        let nextRoute = pages[currentPageIndex]
        currentPageIndex = (currentPageIndex + 1) % pages.count
        return nextRoute
    }
    
}
