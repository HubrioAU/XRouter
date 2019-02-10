//
//  MainCoordinator.swift
//

import XRouter

/**
 Main Coordinator
 */
class MainCoordinator {
    
    // MARK: - Dependencies
    
    /// Router
    let router: Router
    
    /// Example coordinator for a modal flow
    let modalCoordinator: ModalCoordinator
    
    /// First tab
    let tab1Coordinator: Tab1Coordinator
    
    /// Second tab
    let tab2Coordinator: Tab2Coordinator
    
    // MARK: - Navigation Stack
    
    /// Root view controller
    private(set) lazy var tabBarController: UITabBarController = {
        let tabBarController = AnimatedTabBarController()
        
        tabBarController.delegate = tabBarController
        
        tabBarController.viewControllers = [
            tab1Coordinator.navigationController,
            tab2Coordinator.navigationController
        ]
        
        return tabBarController
    }()
    
    // MARK: - Methods
    
    /// Constructor. Inject dependencies.
    init(_ router: Router,
         _ modalCoordinator: ModalCoordinator,
         _ tab1Coordinator: Tab1Coordinator,
         _ tab2Coordinator: Tab2Coordinator) {
        self.router = router
        self.modalCoordinator = modalCoordinator
        self.tab1Coordinator = tab1Coordinator
        self.tab2Coordinator = tab2Coordinator
    }
    
    /// Start the main coordinator
    func start(inWindow window: UIWindow?) -> Bool {
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
        
        return true
    }
    
}
