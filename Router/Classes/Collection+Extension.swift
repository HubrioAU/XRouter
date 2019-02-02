//
//  Collection+Extension.swift
//  XRouter
//
//  Created by Reece Como on 12/1/19.
//

import Foundation

extension Collection {
    
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    /// Source: https://stackoverflow.com/a/30593673
    /// Authors: Nikita Kukushkin, Shaheen Ghiassy
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
    
}
