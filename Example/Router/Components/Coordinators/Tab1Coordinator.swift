//
//  Tab1Coordinator.swift
//

import UIKit

/**
 Tab 1 Coordinator
 
 An example coordinator for a navigation tab.
 */
class Tab1Coordinator {
    
    /// Container
    let container: Container
    
    /// Constructor
    init(container: Container) {
        self.container = container
    }
    
    // MARK: - Navigation
    
    /// Navigation controller
    private(set) lazy var navigationController = UINavigationController(rootViewController: rootViewController)
    
    /// Root view controller
    private lazy var rootViewController: UIViewController = container.tab1ViewController
    
    // MARK: - Methods
    
    /// Goto home page for the tab
    @discardableResult func gotoTabHome() -> UINavigationController {
        navigationController.setViewControllers([rootViewController], animated: true)
        return navigationController
    }
    
    /// Goto home page for the tab
    @discardableResult func gotoProfile(withID identifier: String) -> UINavigationController {
        let viewController = container.profileViewController(withID: identifier)
        navigationController.pushViewController(viewController, animated: true)
        return navigationController
    }
    
}
