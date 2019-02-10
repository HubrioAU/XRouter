//
//  ExampleModalCoordinator.swift
//

import UIKit

/**
 Modal Coordinator
 
 An example coordinator for a modal flow.
 */
class ModalCoordinator {
    
    // MARK: - Dependencies
    
    /// Container
    let container: Container
    
    /// Container
    init(container: Container) {
        self.container = container
    }
    
    // MARK: - Navigation
    
    /// Navigation controller
    private(set) lazy var navigationController = UINavigationController(rootViewController: rootViewController)
    
    /// Root view controller
    private lazy var rootViewController: ModalViewController! = container.modalViewController
    
    // MARK: - Methods
    
    /// Start the modal flow
    @discardableResult func start() -> UINavigationController {
        navigationController.setViewControllers([rootViewController], animated: true)
        return navigationController
    }
    
    /// Go to the second page
    @discardableResult func gotoSecondPage() -> UINavigationController {
        navigationController.setViewControllers([rootViewController,
                                                 container.secondModalViewController],
                                                animated: true)
        return navigationController
    }
    
    
    
}
