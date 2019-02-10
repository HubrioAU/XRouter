//
//  Container.swift
//  XRouter_Example
//

import XRouter

// swiftlint:disable force_unwrapping

/**
 Dependency Injection Container
 */
class Container {
    
    // MARK: - Router
    
    /// Share an instance of the router.
    lazy var router: Router! = {
        let router = Router(container: self)
        return router
    }()
    
    // MARK: - Coordinators
    
    /// Resolve the main coordinator
    lazy var mainCoordinator = MainCoordinator(router,
                                               modalCoordinator,
                                               tab1Coordinator,
                                               tab2Coordinator)
    
    /// Resolve the example coordinator for a modal flow
    lazy var modalCoordinator = ModalCoordinator(container: self)
    
    /// Resolve the example coordinator for a tab
    lazy var tab1Coordinator = Tab1Coordinator(container: self)
    
    /// Resolve the example coordinator for a tab
    lazy var tab2Coordinator = Tab2Coordinator(container: self)
    
    // Add coordinators here...
    
    // MARK: - Views
    
    /// Tab 1 view controller
    var tab1ViewController: Tab1ViewController! {
        let viewController = UIStoryboard(name: "Storyboard", bundle: nil)
            .instantiateViewController(withIdentifier: "Tab1ViewController") as! Tab1ViewController
        
        viewController.coordinator = tab1Coordinator
        viewController.title = "Tab 1"
        
        return viewController
    }
    
    /// Tab 2 view controller
    var tab2ViewController: Tab2ViewController! {
        let viewController = UIStoryboard(name: "Storyboard", bundle: nil)
            .instantiateViewController(withIdentifier: "Tab2ViewController") as! Tab2ViewController
        
        viewController.router = router
        viewController.title = "Tab 2"
        
        return viewController
    }
    
    /// Tab 2 second view controller
    var tab2SecondViewController: Tab2SecondViewController! {
        let viewController = UIStoryboard(name: "Storyboard", bundle: nil)
            .instantiateViewController(withIdentifier: "Tab2SecondViewController") as! Tab2SecondViewController
        
        viewController.router = router
        
        return viewController
    }
    
    /// Profile view controller
    func profileViewController(withID identifier: String) -> UIViewController {
        let viewController = UIStoryboard(name: "Storyboard", bundle: nil)
            .instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        
        viewController.router = router
        viewController.title = identifier
        
        return viewController
    }
    
    /// Modal view controller
    var modalViewController: ModalViewController! {
        let viewController = UIStoryboard(name: "Storyboard", bundle: nil)
            .instantiateViewController(withIdentifier: "ModalViewController") as! ModalViewController
        
        viewController.coordinator = modalCoordinator
        
        return viewController
    }
    
    /// Second modal view controller
    var secondModalViewController: UIViewController! {
        let viewController = UIStoryboard(name: "Storyboard", bundle: nil)
            .instantiateViewController(withIdentifier: "SecondModalViewController") as! PushedViewController
        
        viewController.router = router
        
        return viewController
    }
    
}
