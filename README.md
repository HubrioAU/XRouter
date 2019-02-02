# XRouter

A simple routing library for iOS projects.

[![Codacy Badge](https://api.codacy.com/project/badge/Grade/d0ef88b70fc843adb2944ce0d956269d)](https://app.codacy.com/app/hubrioau/XRouter?utm_source=github.com&utm_medium=referral&utm_content=hubrioau/XRouter&utm_campaign=Badge_Grade_Dashboard)
[![CodeCov Badge](https://codecov.io/gh/reececomo/XRouter/branch/master/graph/badge.svg)](https://codecov.io/gh/hubrioau/XRouter)
[![Build Status](https://travis-ci.org/reececomo/XRouter.svg?branch=master)](https://travis-ci.org/hubrioau/XRouter)
[![Docs Badge](https://raw.githubusercontent.com/hubrioau/XRouter/master/docs/badge.svg?sanitize=true)](https://hubrioau.github.io/XRouter)
[![Version](https://img.shields.io/cocoapods/v/XRouter.svg?style=flat)](https://cocoapods.org/pods/XRouter)
[![License](https://img.shields.io/cocoapods/l/XRouter.svg?style=flat)](https://cocoapods.org/pods/XRouter)
[![Platform](https://img.shields.io/cocoapods/p/XRouter.svg?style=flat)](https://cocoapods.org/pods/XRouter)

<p align="center">
<img src="https://raw.githubusercontent.com/hubrioau/XRouter/master/XRouter.jpg" alt="XRouter" width="625" style="max-width:625px;width:auto;height:auto;"/>
</p>

## Usage
### Basic Usage

#### Creating a Router
```swift
// Create a router
let router = Router<MyRoutes>()

// Navigate to a route
router.navigate(to: .loginFlow)

// ... or open a route from a URL
router.openURL(url)
```

#### Configuring Routes

Define your routes, like so:

```swift
enum AppRoute {
    case home
    case profile(withID: Int)
}
```

- Note: By default, enum properties don't factor into equality checks/comparisons. You can provide your own
        implementation of `var name: String` or `static func == (_:_:)` if you would like to override this.

Implement the protocol stubs:
```swift
extension AppRoute: RouteProvider {

    /// Configure the transitions
    var transition: RouteTransition {
        switch self {
        case .home:
            return .push
        case .profile:
            return .modal
        }
    }

    /// Prepare the view controller for the route
    /// - You can use this to configure entry points into flow coordinators
    /// - You can throw errors here to cancel the navigation
    func prepareForTransition(from currentViewController: UIViewController) throws {
        switch self {
        case .home:
            return HomeCoordinator.shared.navigationController
        case .profile(let profileID):
            let myProfile = try Profile.load(withID: profileID)
            return ProfileViewController(profile: myProfile)
        }
    }

}
```

### RxSwift Support
XRouter also supports reactive bindings through the RxSwift framework. Bindings exist for both the `navigate(to:)` and `openURL(_:)` methods, which each return a `Completable` event.
```swift
router.rx.navigate(to: .loginFlow)
router.rx.openURL(url)
```

### Advanced Usage

#### URL Support

You only need to do two things to add URL support to your routes.

First, implement the static method `registerURLs` in your `RouteProvider`.

Here is an example with a single host:
```swift
extension MyRoute: RouteProvider {

    static func registerURLs() -> Router<MyRoute>.URLMatcherGroup? {
        return .group("store.example.com") {
            $0.map("products") { .allProducts }
            $0.map("products/{category}/view") { try .products(category: $0.param("category")) }
            $0.map("user/{id}/profile") { try .viewProfile(withID: $0.param("id")) }
            $0.map("user/*/logout") { .logout }
        }
    }

}
```

Here is an example with multiple domains configured:
```swift
extension MyRoute: RouteProvider {

    static func registerURLs() -> Router<MyRoute>.URLMatcherGroup? {
        return .init(matchers: [
            .group(["example.com", "store.example.com"]) {
                $0.map("products/") { .allProducts }
                $0.map("products/{category}/view") { try .products(category: $0.param("category")) }
                $0.map("user/{id}/profile") { try .viewProfile(withID: $0.param("id")) }
                $0.map("user/*/logout") { .logout }
            },
            .group("affiliate.website.net.au") {
                $0.map("*/referral/") { .openReferralProgram(for: $0.rawURL) }
            }
        ])
    }

}
```

Then call the openURL method inside your URL handler. Here is Universal Links for example:
```swift
extension AppDelegate {

    /// Open Universal Links
    func application(_ application: UIApplication,
                 continue userActivity: NSUserActivity,
                 restorationHandler: @escaping ([Any]?) -> Void) -> Bool
    {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
            let url = userActivity.webpageURL,
            let handledURL = router.openURL(url) else {
            return false // Unrecognized URL
        }

        return handledURL
    }

}
```

#### Handling errors

It can be messy trying to handle errors in every place you call navigate.

You can set a completion handler for a navigation action:

```swift
router.navigate(to: .profilePage(id: "12")) { optionalError in
    if let error = optionalError {
        print("Oh no, there was an unexpected error!")
    } else {
        print("Success!")
    }
}
```

You could wrap or override the navigate functions to provide a default completion handler, if you handle
all navigation errors in the same way. For example, something like this:

```swift
class MyRouter<Route: RouteProvider>: XRouter.Router<Route> {

    /// Navigate to a route. Logs errors.
    override func navigate(to route: Route, animated: Bool = true, completion: ((Error?) -> Void)? = nil) {
        super.navigate(to: route, animated: animated, completion: completion ?? logErrors)
    }

    /// Open a URL to a route. Logs errors.
    @discardableResult
    override func openURL(_ url: URL, animated: Bool = true, completion: ((Error?) -> Void)? = nil) -> Bool {
        return openURL(url, animated: animated, completion: completion ?? logErrors)
    }

    /// Completion handler for `navigate(...)`/`openURL(...)`.
    private func logErrors(_ error: Error?) {
        guard let error = error else { return }

        // Log errors here
    }

}

```

#### Custom Transitions
Here is an example using the popular [Hero Transitions](https://github.com/HeroTransitions/Hero) library.

Set the `customTransitionDelegate` for the `Router`:
```swift
router.customTransitionDelegate = self
```

(Optional) Define your custom transitions in an extension so you can refer to them statically
```swift
extension RouteTransition {
    static var myHeroFade: RouteTransition {
        return .custom(identifier: "heroFade")
    }
}
```

Implement the delegate method `performTransition(...)`:
```swift

extension AppDelegate: RouterCustomTransitionDelegate {
    
    /// Perform a custom transition
    func performTransition(to newViewController: UIViewController,
                           from oldViewController: UIViewController,
                           transition: RouteTransition,
                           animated: Bool) {
        if transition == .myHeroFade {
            oldViewController.hero.isEnabled = true
            newViewController.hero.isEnabled = true
            newViewController.hero.modalAnimationType = .fade
            
            // Creates a container nav stack
            let containerNavController = UINavigationController()
            containerNavController.hero.isEnabled = true
            containerNavController.setViewControllers([newViewController], animated: false)
            
            // Present the hero animation
            oldViewController.present(containerNavController, animated: animated)
        }
    }
    
}
```

And set the transition to `.custom` in your `Routes.swift` file:
```swift
    var transition: RouteTransition {
        switch self {
            case .myRoute:
                return .myHeroFade
        }
    }
```

## Documentation

Complete [documentation is available here](https://reececomo.github.io/XRouter).

## Example

To run the example project, clone the repo, and run it in Xcode 10.

## Requirements

## Installation

### CocoaPods

XRouter is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'XRouter'
```

## Author

Reece Como, reece@hubr.io

## License

XRouter is available under the MIT license. See the LICENSE file for more info.
