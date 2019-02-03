//
//  PathPattern
//  XRouter
//

import Foundation

/**
 Path pattern definition for pattern matching
 
 ```swift
 let pathPattern: PathPattern = "/my/{adjective}/string/{number}"
 
 pathPattern.matches("/my/cool/string/1")       // `true`
 pathPattern.matches("/my/awesome/string/2")    // `true`
 pathPattern.matches("/your/cool/string/3")     // `false`, mismatch on expected static element first
 pathPattern.matches("/my/cool/string/hello")   // `true`
 ```
 
 */
public class PathPattern: ExpressibleByStringLiteral, Hashable {
    
    // MARK: - Properties
    
    /// Get the individual parts
    public lazy var components: [Component] = {
        rawValue.components(separatedBy: "/")
            .compactMap { $0 == "" ? nil : $0 }
            .map { self.component(for: $0) }
    }()
    
    /// Raw string value
    private let rawValue: String
    
    // MARK: - Methods
    
    ///
    /// Initialize with string literal
    ///
    /// ```
    /// let pattern: PathPattern = "/check/{this}/out"
    /// ```
    ///
    required public init(stringLiteral: String) {
        rawValue = stringLiteral
    }
    
    // MARK: - Hashable
    
    /// Hashable
    public var hashValue: Int {
        return rawValue.hashValue
    }
    
    /// Compares on raw strings
    public static func == (lhs: PathPattern, rhs: PathPattern) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
    
    // MARK: - Implementation
    
    /// Get the `Component` for some string
    private func component(for string: String) -> Component {
        if string == "*" {
            return .wildcard
        } else if string.first == "{" && string.last == "}" {
            let parameterName = string
                .replacingOccurrences(of: "{", with: "")
                .replacingOccurrences(of: "}", with: "")
            return .parameter(named: parameterName)
        }
        
        return .exact(string: string)
    }
    
}
