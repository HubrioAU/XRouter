//
//  RainbowFlowController.swift
//  Router_Example
//
//  Created by Reece Como on 5/1/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit

/**
 Example of a flow controller that controls its own navigation heirachy with multiple entry points.
 */
class ExampleFlowController {
    
    // MARK: - Properties
    
    /// Shared instance
    static let shared = ExampleFlowController()
    
    /// View controllers
    private let orangeVC = ColoredViewController(color: .orange, title: "flow page 1")
    private let cyanVC = ColoredViewController(color: .cyan, title: "flow page 2")
    private let magentaVC = ColoredViewController(color: .magenta, title: "flow page 3")
    
    /// Create a navigation controller for all three
    lazy var navigationController: UINavigationController = {
        let navController = UINavigationController()
        navController.setViewControllers([orangeVC, cyanVC, magentaVC], animated: false)
        return navController
    }()
    
    // MARK: - Methods
    
    /// Entry point 1
    /// - Note: This one has only 2 view controllers
    public func startBasicFlow() -> UINavigationController {
        navigationController.setViewControllers([orangeVC, cyanVC], animated: true)
        return navigationController
    }
    
    /// Entry point 2
    /// - Note: This one has all 3 view controllers
    public func startFullFlow() -> UINavigationController {
        navigationController.setViewControllers([orangeVC, cyanVC, magentaVC], animated: true)
        return navigationController
    }
    
}
