# Change Log

Notable changes to this project will be documented in this file. See [standard-version](https://github.com/conventional-changelog/standard-version) for commit guidelines.

# [v1.3.0](https://github.com/hubrioAU/XRouter/releases/tag/1.3.0)
- Renamed `Router` to `XRouter`.
- Moved navigation transition logic to `Navigator` class.
- Renamed `RouteProvider` to `RouteType`.
- Moved `prepareForTransition(...)` to new class `RoutingHandler`.
- Added `RouteTransition.inferred` which automatically infers transition type.
- Added `received(unhandledError:)` handler to `XRouter`.
- Removed `UIApplication` specific logic. Router now manages a specific UIWindow (defaults to lazy load `UIApplication.shared.keyWindow`).

# [v1.2.6](https://github.com/hubrioAU/XRouter/releases/tag/1.2.6)
- Use the delegate method [tabBarController(_:shouldSelect:)](https://developer.apple.com/documentation/uikit/uitabbarcontrollerdelegate/1621166-tabbarcontroller) before transitioning between tabs.
- Improve the Example project/UI Tests.

# [v1.2.3 - v1.2.5](https://github.com/hubrioAU/XRouter/releases/tag/1.2.4)
- Added RxSwift extension.
- Update RxSwift extension method `openURL(_:)` to return `Single<Bool>` instead of `Completable`.
- Bugfix for [v1.2.4](https://github.com/hubrioAU/XRouter/releases/tag/1.2.4) to fix RxSwift import.

# [v1.2.1](https://github.com/hubrioAU/XRouter/releases/tag/1.2.1)
- Improve support for UITabBarController, fix issue with UINavigationController set transition.

# [v1.1.0](https://github.com/hubrioAU/XRouter/releases/tag/1.1.0)
- Added URL mapping, deep links and universal link support.
- Added `openURL(_:)` method to Router.

# [v1.0.0](https://github.com/hubrioAU/XRouter/releases/tag/1.0.0)
- Initial release.
