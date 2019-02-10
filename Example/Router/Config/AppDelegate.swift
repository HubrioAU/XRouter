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

    /// Window
    lazy var window: UIWindow? = UIWindow(frame: UIScreen.main.bounds)
    
    /// Container
    private let container = Container()
    
    /// Setup app
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return container.mainCoordinator.start(inWindow: window)
    }
    
}
