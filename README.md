# XRouter

[![Codacy Badge](https://api.codacy.com/project/badge/Grade/d0ef88b70fc843adb2944ce0d956269d)](https://app.codacy.com/app/reececomo/XRouter?utm_source=github.com&utm_medium=referral&utm_content=reececomo/XRouter&utm_campaign=Badge_Grade_Dashboard)
[![Build Status](https://travis-ci.org/reececomo/XRouter.svg?branch=master)](https://travis-ci.org/reececomo/XRouter)
[![Version](https://img.shields.io/cocoapods/v/XRouter.svg?style=flat)](https://cocoapods.org/pods/XRouter)
[![License](https://img.shields.io/cocoapods/l/XRouter.svg?style=flat)](https://cocoapods.org/pods/XRouter)
[![Platform](https://img.shields.io/cocoapods/p/XRouter.svg?style=flat)](https://cocoapods.org/pods/XRouter)

## Usage
### Basic Usage
```swift
//
let router = Router<Route>()

try? router.navigate(to: .loginFlow)
```

### Defining Routes
```swift
import Router

// Routes
enum Route: RouteProvider {
    case newsfeed
    case profile(userID: String)
    case loginFlow
}

extension Route {
    /// Set the transition types
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
    
    /// Prepare for transition
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
And then implement the delegate method `performTransition(...)`:
```swift

extension AppDelegate: RouterCustomTransitionDelegate {
    
    /// Perform a custom transition
    func performTransition(to newViewController: UIViewController,
                           from currentNavigationController: UINavigationController,
                           transitionIdentifier: String,
                           animated: Bool) {
        if transitionIdentifer == "HeroFade" {
            currentNavigationController.hero.isEnabled = true
            newViewController.hero.isEnabled = true
            newViewController.hero.modalAnimationType = .fade
            
            // Creates a container nav stack
            let container = UINavigationController()
            container.hero.isEnabled = true
            container.setViewControllers([viewController], animated: false)
            
            // Present the hero animation
            navController.present(container, animated: animated)
        }
    }
    
}
```

## Example

To run the example project, clone the repo, and run it in Xcode 10.

## Requirements

## Installation

Router is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Router'
```

## Author

Reece Como, reece.como@gmail.com

## License

Router is available under the MIT license. See the LICENSE file for more info.
