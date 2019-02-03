//
//  PathPattern+Component
//  XRouter
//

import Foundation

extension PathPattern {

    /**
     Path pattern component for pattern matching.
     */
    public enum Component {
        
        // MARK: - Component match type
        
        /// Exact match component
        case exact(string: String)
        
        /// Parameterized component
        case parameter(named: String)
        
        /// Wildcard (ignored) component
        case wildcard
        
        // MARK: - Methods
        
        /// Does this match some string
        func matches(_ foreignString: String) -> Bool {
            switch self {
            case .exact(let localString):
                return localString == foreignString
            case .wildcard, .parameter:
                return true
            }
        }
        
    }

}
