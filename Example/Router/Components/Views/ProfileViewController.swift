//
//  ProfileViewController.swift
//  XRouter_Example
//

import UIKit
import XRouter

/**
 Profile View Controller
 */
class ProfileViewController: UIViewController {
    
    /// Router
    weak var router: Router!
    
    /// Tap present modal
    @IBAction func tappedPresentModal(_ sender: Any) {
        router.navigate(to: .modalVC)
    }
    
}
