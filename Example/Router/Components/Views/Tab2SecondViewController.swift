//
//  Tab2SecondViewController.swift
//  XRouter_Example
//

import UIKit
import XRouter

/**
 Tab 2 View Controller
 */
class Tab2SecondViewController: UIViewController {
    
    /// Router
    weak var router: Router!
    
    /// Tapped push view controller
    @IBAction func tappedButton(_ sender: Any) {
        router.navigate(to: .tab2Home)
    }
    
}
