//
//  RouterError.swift
//  Router
//
//  Created by Reece Como on 7/1/19.
//

import Foundation

/**
 Router errors
 */
enum RouterError {
    
    /// The route transition can only be called from a UINavigationController
    case missingRequiredNavigationController(for: RouteTransition)
    
    /// Unable to find a route to the view controller
    case unableToFindRouteToViewController
    
}

extension RouterError: LocalizedError {
    
    // MARK: - LocalizedError
    
    /// A localized message describing what error occurred.
    public var errorDescription: String? {
        switch self {
        case .missingRequiredNavigationController(let transition):
            return """
            You cannot call this RouteTransition (\(transition.name)) without a navigation controller.
            """
        case .unableToFindRouteToViewController:
            return """
            The view controller was in the hierachy but was not an ancestor of the current view controller, so we were unable to automatically find a route to it.
            """
        }
    }
    
    /// A localized message describing the reason for the failure.
    public var failureReason: String? {
        switch self {
        case .missingRequiredNavigationController(let transition):
            return """
            RouteTransition.\(transition.name) requires the parent view controller to be a UINavigationController.
            """
        case .unableToFindRouteToViewController:
            return errorDescription
        }
    }
    
    /// A localized message describing how one might recover from the failure.
    public var recoverySuggestion: String? {
        switch self {
        case .missingRequiredNavigationController:
            return """
            Nest the parent view controller in a UINavigationController.
            """
        case .unableToFindRouteToViewController:
            return """
            TODO: Come back to this
            """
        }
    }
    
    /// A localized message providing "help" text if the user requests help.
    public var helpAnchor: String? {
        return nil // Not implemented
    }
    
}
