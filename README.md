# XRouter

Decouple your code with abstract routing.
Define app-level destinations, add powerful deep-linking and stop writing the same boilerplate over and over.

[![Codacy Badge](https://api.codacy.com/project/badge/Grade/d0ef88b70fc843adb2944ce0d956269d)](https://app.codacy.com/app/hubrioAU/XRouter?utm_source=github.com&utm_medium=referral&utm_content=hubrioAU/XRouter&utm_campaign=Badge_Grade_Dashboard)
[![CodeCov Badge](https://codecov.io/gh/hubrioAU/XRouter/branch/master/graph/badge.svg)](https://codecov.io/gh/hubrioau/XRouter)
[![Build Status](https://travis-ci.org/hubrioAU/XRouter.svg?branch=master)](https://travis-ci.org/hubrioAU/XRouter)
[![Docs Badge](https://raw.githubusercontent.com/hubrioAU/XRouter/master/docs/badge.svg?sanitize=true)](https://hubrioau.github.io/XRouter)
[![Version](https://img.shields.io/cocoapods/v/XRouter.svg?style=flat)](https://cocoapods.org/pods/XRouter)
[![License](https://img.shields.io/cocoapods/l/XRouter.svg?style=flat)](https://cocoapods.org/pods/XRouter)
[![Language](https://img.shields.io/badge/RxSwift-compatible-blueviolet.svg)](https://swift.org)

<p align="center">
<img src="https://raw.githubusercontent.com/hubrioau/XRouter/master/XRouter.jpg?17-Mar" alt="XRouter" width="400" style="max-width:400px;width:auto;height:auto;"/>
</p>

## Get Started

It's very easy to get started.

### Configuration

#### 1. Define AppRoutes
Create an `AppRoutes.swift` file.
```swift
enum AppRoute: RouteType {
    case newsfeed
    case login
    case signup
    case profile(userID: Int)
}
```

#### 2. Configure Destinations
Extend a concrete Router instance to resolve your view controllers.
```swift
class Router: XRouter<AppRoute> {

    override func prepareDestination(for route: AppRoute) throws -> UIViewController {
        switch route {
        case .newsfeed: return
            newsfeedController.rootViewController
            
        case .login:
            return LoginFlowCoordinator().start()
            
        case .signup:
            return SignupFlowCoordinator().start()
            
        case let .profile(userID):
            guard let profile = profilesRepository.fetch(userId) else {
                throw NotFoundError("Could not find profile with that ID.")
            }
            
            return UserProfileViewController().configured(with: profile)
        }
    }
    
}
```

#### 3. Use Router
```swift
// Navigate directly to a route
router.navigate(to: .profile(3355))
```

### Advanced Usage

### RxSwift
XRouter also supports the RxSwift framework out of the box. Bindings exist for `navigate(to:)`, which returns a `Completable`, and `openURL(_:)`, which returns a `Single<Bool>`.
```swift
router.rx.navigate(to: .loginFlow) // -> Completable
router.rx.openURL(url) // -> Single<Bool>
```

#### Deep Link Support

XRouter provides support for deep links and universal links.

You only need to do one thing to add URL support for your routes.
Implement the static method `registerURLs`:
```swift
enum AppRoute: RouteType {

    static func registerURLs() -> URLMatcherGroup<Route>? {
        return .group {
            $0.map("/products") { .allProducts }
            $0.map("/user/*/logout") { .logout }
            $0.map("/products/{cat}/view") { try .products(category: $0.path("cat")) }
            
            $0.map("/user/{id}/profile") {
                try .viewProfile(withID: $0.path("id"), parameters: $0.query)
            }
        }
    }

}
```

Then you can call the `openURL(_:animated:completion:)` and/or `continue(_ userActivity:)` methods, e.g. from in your AppDelegate:
```swift
extension AppDelegate {

    /// Handle deep links.
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return router.openURL(url, animated: false)
    }

    /// Handle universal links.
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        return router.continue(userActivity)
    }

}
```

You can even define more advanced URL routing. For example, these rules could be used to match:

* `http://example.com/login` --> `.login`
* `https://example.com/signup` --> `.signup`
* `customScheme://myApp/qr-code?code=abcdef...` --> `.openQRCode("abcdef...")`
* `https://www.example.com/products` --> `.allProducts`
* `https://api.example.com/user/my-user-name/logout` --> `.logout`

```swift
enum AppRoute: RouteType {

    static func registerURLs() -> URLMatcherGroup<AppRoute>? {
        return .init(matchers: [
            .host("example.com") {
                $0.map("/login") { .login }
                $0.map("/signup") { .signup }
            },
            .scheme("customScheme") {
                $0.map("/qr-code") { .openQRCode($0.query("code")) }
            },
            .group {
                $0.map("/products") { .allProducts }
                $0.map("/user/*/logout") { .logout }
            }
        ])
    }

}
```

#### Handling errors

If you handle all navigation errors in the same way, you can override the `received(unhandledError:)` method.

```swift
class Router: XRouter<Route> {

    override func received(unhandledError error: Error) {
        log.error("Oh no! An error occured: \(error)")
    }

}

```

Or you can set a custom completion handler for some individual navigation action:

```swift
router.navigate(to: .profilePage(withID: 24)) { (optionalError) in
    if let error = optionalError {
        print("Oh no, we couldn't go here because there was an error!")
    }
}
```

#### Custom Transitions
Here is an example using the popular [Hero Transitions](https://github.com/HeroTransitions/Hero) library.

Define your custom transitions:
```swift
  /// Hero cross fade transition
  let heroCrossFade = RouteTransition { (source, dest, animated, completion) in
      source.hero.isEnabled = true
      dest.hero.isEnabled = true
      dest.hero.modalAnimationType = .fade

      // Present the hero animation
      source.present(dest, animated: animated) {
          completion(nil)
      }
  }
```

And set the transition to your custom transition in your Router:
```swift
    override func transition(for route: AppRoute) -> RouteTransition {
        if case Route.profile = route {
          return heroCrossFade
        }

        return .automatic
    }
```

## Documentation

Complete [documentation is available here](https://hubrioau.github.io/XRouter/) and is generated using [Jazzy](https://github.com/realm/jazzy).

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
