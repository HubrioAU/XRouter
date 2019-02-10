//
//  PushedViewController.swift
//  XRouter_Example
//

import UIKit
import XRouter

/**
 Pushed View Controller
 */
class PushedViewController: UIViewController {
    
    /// Router
    weak var router: Router!
    
    /// Tapped button
    @IBAction func tappedButton(_ sender: Any) {
        router.navigate(to: .tab2Home)
    }
    
}
