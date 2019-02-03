//
//  UITabBarDelegate.swift
//  XRouter_Example
//

import UIKit

/**
 Pulled the animation from:
 https://samwize.com/2016/04/27/making-tab-bar-slide-when-selected/
 */
class AnimatedTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    /// Previous view controller
    weak var previousViewController: UIViewController?
    
    // MARK: - UITabBarController
    
    /// View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
    }
    
    // MARK: - UITabBarControllerDelegate
    
    /// Animate tab change
    public func tabBarController(_ tabBarController: UITabBarController,
                                 shouldSelect viewController: UIViewController) -> Bool {
        guard let tabViewControllers = tabBarController.viewControllers,
            let tabIndex = tabViewControllers.index(of: viewController) else {
                return false
        }
        
        
        animate(to: tabIndex, from: selectedViewController)
        return true
    }
    
    // MARK: - Implementation
    
    /// Animate to tab
    func animate(to tabIndex: Int, from currentViewController: UIViewController?) {
        guard let tabViewControllers = viewControllers,
            let currentViewController = currentViewController,
            let toView = tabViewControllers[tabIndex].view,
            let fromView = currentViewController.view,
            let fromIndex = tabViewControllers.index(of: currentViewController),
            fromIndex != tabIndex else {
                return
        }
        
        // Add the toView to the tab bar view
        fromView.superview?.addSubview(toView)
        
        // Position toView off screen (to the left/right of fromView)
        let screenWidth = UIScreen.main.bounds.size.width
        let scrollRight = tabIndex > fromIndex;
        let offset = scrollRight ? screenWidth : -screenWidth
        toView.center = CGPoint(x: fromView.center.x + offset, y: toView.center.y)
        
        // Disable interaction during animation
        view.isUserInteractionEnabled = false
        
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
            // Slide the views by -offset
            fromView.center = CGPoint(x: fromView.center.x - offset, y: fromView.center.y);
            toView.center   = CGPoint(x: toView.center.x - offset, y: toView.center.y);
        }, completion: { finished in
            // Remove the old view from the tabbar view.
            fromView.removeFromSuperview()
            self.selectedIndex = tabIndex
            self.view.isUserInteractionEnabled = true
        })
    }
    
}
