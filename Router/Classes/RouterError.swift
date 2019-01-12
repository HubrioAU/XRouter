//
//  XRouterError.swift
//  XRouter
//
//  Created by Reece Como on 7/1/19.
//

import Foundation

/**
 Errors that can be thrown by Router.
 */
public enum RouterError {
    
    // MARK: - Errors
    
    /// The route transition can only be called from a UINavigationController
    case missingRequiredNavigationController(for: RouteTransition)
    
    /// The view controller was in the hierachy but was not an ancestor of the current view controller, so we were unable to automatically find a route to it.
    case unableToFindRouteToViewController
    
    /// Missing required parameter while unwrapping URL route
    case missingRequiredParameterWhileUnwrappingURLRoute(parameter: String)
    
    /// A required parameter was found, but it was not an Int
    case requiredIntegerParameterWasNotAnInteger(parameter: String, stringValue: String)
}

extension RouterError: LocalizedError {
    
    // MARK: - LocalizedError
    
    /// A localized message describing what error occurred.
    public var errorDescription: String? {
        switch self {
        case .missingRequiredNavigationController(let transition):
            return """
            You cannot navigate to this route using transition \"\(transition.name)\" without a navigation controller.
            """
        case .unableToFindRouteToViewController:
            return """
            The view controller was in the hierachy but was not an ancestor of the current view controller, so we were unable to automatically find a route to it.
            """
        case .missingRequiredParameterWhileUnwrappingURLRoute(let name):
            return """
            Missing required paramter \"\(name)\" while unwrapping URL route.
            """
        case .requiredIntegerParameterWasNotAnInteger(let name, let stringValue):
            return """
            Required integer parameter \"\(name)\" existed, but was not an integer.
            Instead \"\(stringValue)\" was received."
            """
        }
    }
    
    /// A localized message describing how one might recover from the failure.
    public var recoverySuggestion: String? {
        switch self {
        case .missingRequiredNavigationController:
            return """
            Nest the parent view controller in a `UINavigationController`.
            """
        case .unableToFindRouteToViewController:
            return """
            Something funky has occured.
            Please log an issue at: https://github.com/reececomo/XRouter
            """
        case .missingRequiredParameterWhileUnwrappingURLRoute(let name):
            return """
            You referenced a parameter \"\(name)\" that wasn't declared in the `PathPattern`.
            Please include the parameter in `PathPattern`, or remove it from the mapping.
            """
        case .requiredIntegerParameterWasNotAnInteger(_, let stringValue):
            return """
            The value that was received was \"\(stringValue)\", which could not be cast to `Int`.
            """
        }
    }
    
    /// A localized message describing the reason for the failure.
    public var failureReason: String? {
        return errorDescription
    }
    
    /// A localized message providing "help" text if the user requests help.
    public var helpAnchor: String? {
        return nil // Not implemented
    }
    
}
