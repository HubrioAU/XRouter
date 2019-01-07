# XRouter

A simple routing library for iOS projects.

[![Codacy Badge](https://api.codacy.com/project/badge/Grade/d0ef88b70fc843adb2944ce0d956269d)](https://app.codacy.com/app/reececomo/XRouter?utm_source=github.com&utm_medium=referral&utm_content=reececomo/XRouter&utm_campaign=Badge_Grade_Dashboard)
[![Build Status](https://travis-ci.org/reececomo/XRouter.svg?branch=master)](https://travis-ci.org/reececomo/XRouter)
[![Version](https://img.shields.io/cocoapods/v/XRouter.svg?style=flat)](https://cocoapods.org/pods/XRouter)
[![License](https://img.shields.io/cocoapods/l/XRouter.svg?style=flat)](https://cocoapods.org/pods/XRouter)
[![Platform](https://img.shields.io/cocoapods/p/XRouter.svg?style=flat)](https://cocoapods.org/pods/XRouter)

<p align="center">
<img src="https://raw.githubusercontent.com/reececomo/XRouter/master/XRouter.jpg" alt="XRouter" width="625" style="max-width:625px;width:auto;height:auto;"/>
</p>

## Usage
### Basic Usage
```swift
// Create a router
let router = Router<Route>()

// Navigate to route
try? router.navigate(to: .loginFlow)
```

### Defining Routes
```swift
import XRouter

/// Define your routes
enum Route: RouteProvider {
    case newsfeed
    case profile(userID: String)
    case loginFlow
}

extension Route {

    /// Set the route transitions
    var transition: RouteTransition {
        switch self {
        case .newsfeed:
            return .set
        case .profile:
            return .push
        case .loginFlow:
            return .modal
        }
    }
    
    /// Prepare the view controllers for the routing
    func prepareForTransition(from viewController: UIViewController) throws -> UIViewController {
        switch self {
        case .newsfeed:
            return NewsfeedManager.shared.navigationController
        case .profile(let userID):
            return UserProfileViewController(userID: userID)
        case .loginFlow:
            return LoginFlowManager.shared.start()
        }
    }
}
```

### Custom Transitions
Here is an example using the popular [Hero Transitions](https://github.com/HeroTransitions/Hero) library.
Set the `customTransitionDelegate` for the `Router`:
```swift
router.customTransitionDelegate = self
```
Implement the delegate method `performTransition(...)`:
```swift

extension AppDelegate: RouterCustomTransitionDelegate {
    
    /// Perform a custom transition
    func performTransition(to newViewController: UIViewController,
                           from navController: UINavigationController,
                           transition: RouteTransition,
                           animated: Bool) {
        if transition == "myHeroFade" {
            navController = true
            newViewController.hero.isEnabled = true
            newViewController.hero.modalAnimationType = .fade
            
            // Creates a container nav stack
            let container = UINavigationController()
            container.hero.isEnabled = true
            container.setViewControllers([newViewController], animated: false)
            
            // Present the hero animation
            navController.present(container, animated: animated)
        }
    }
    
}
```
And set the transition to `.custom` in your `Routes.swift` file:
```swift
    var transition: RouteTransition {
        switch self {
            case .myRoute:
                return .custom(identifier: "myHeroFade")
        }
    }
```

## Example

To run the example project, clone the repo, and run it in Xcode 10.

## Requirements

## Installation

XRouter is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'XRouter'
```

## Author

Reece Como, reece.como@gmail.com

## License

Router is available under the MIT license. See the LICENSE file for more info.
