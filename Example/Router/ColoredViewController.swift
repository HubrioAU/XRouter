//
//  ProfileViewController.swift
//  Router_Example
//
//  Created by Reece Como on 5/1/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit

/**
 A view controller who sets the background color
 */
class ColoredViewController: UIViewController {
    
    /// Background color
    var myColor: UIColor = .white
    
    /// Init with color
    convenience init(color: UIColor, title: String) {
        self.init()
        myColor = color
        self.title = title
    }
    
    /// View will appear, set the background color
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Set the background color
        view.backgroundColor = myColor
    }
    
}
