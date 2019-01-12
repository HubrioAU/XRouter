//
//  PathPattern.swift
//  XRouter
//
//  Created by Reece Como on 12/1/19.
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
    
    /// Path pattern component
    public enum Component {
        case exact(string: String)
        case parameter(named: String)
        case wildcard
        
        func matches(_ foreignString: String) -> Bool {
            switch self {
            case .exact(let localString):
                return localString == foreignString
            case .wildcard, .parameter:
                return true
            }
        }
    }
    
    /// Raw string value
    private let rawValue: String
    
    /// Get the individual parts
    public lazy var components: [Component] = {
        rawValue.components(separatedBy: "/")
            .compactMap { $0 == "" ? nil : $0 }
            .map { self.component(for: $0) }
    }()
    
    /// Get the `Component` for some string
    private func component(for string: String) -> Component {
        if string == "*" {
            return .wildcard
        } else if string.first == "{" && string.last == "}" {
            let parameterName = string
                .replacingOccurrences(of: "{", with: "")
                .replacingOccurrences(of: "}", with: "")
            return .parameter(named: parameterName)
        } else {
            return .exact(string: string)
        }
    }
    
    /// Init
    required public init(stringLiteral: String) {
        rawValue = stringLiteral
    }
    
    // MARK: - Hashable
    
    /// Hashable
    public var hashValue: Int {
        return rawValue.hashValue
    }
    
    // MARK: - Equatable
    
    /// Equatable
    public static func == (lhs: PathPattern, rhs: PathPattern) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
    
}
