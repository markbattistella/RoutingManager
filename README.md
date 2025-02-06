<!-- markdownlint-disable MD033 MD041 -->
<div align="center">

# RoutingManager

[![Swift Version][Shield1]](https://swiftpackageindex.com/markbattistella/RoutingManager)

[![OS Platforms][Shield2]](https://swiftpackageindex.com/markbattistella/RoutingManager)

[![Licence][Shield3]](https://github.com/markbattistella/RoutingManager/blob/main/LICENSE)

</div>

`RoutingManager` is a Swift package designed to simplify and enhance navigation in SwiftUI applications. It provides a structured approach to managing navigation stacks, with support for state persistence and multiple storage options. It also includes robust error handling and flexible environment injection.

## Features

- **Stateful Navigation:** Manage navigation stacks with push, pop, reset, and replace operations.
- **Persistent Storage:** Save and restore navigation state using in-memory, JSON-based file storage, or a custom storage implementation.
- **Custom Storage Support:** Implement your own storage solutions by conforming to `FileStorageRepresentable`.
- **Error Handling:** Handle navigation failures using the `NavigationError` enum and `navigationError` handler.
- **Environment Injection:** Pass dependencies directly into views through `NavigationWrapper`.

## Installation

### Swift Package Manager

To add `RoutingManager` to your project, use the Swift Package Manager.

1. Open your project in Xcode.

1. Go to `File > Add Packages`.

1. In the search bar, enter the URL of the `RoutingManager` repository:

    ```url
    https://github.com/markbattistella/RoutingManager
    ```

1. Click `Add Package`

## Usage

### Getting Started

To start using `RoutingManager`, import the package and create a `RoutingManager` instance in your SwiftUI view. Here's a basic setup:

```swift
import SwiftUI
import RoutingManager

typealias Routes = RoutingManager<Stack, Route>

@main
struct RouteTestApp: App {
  var body: some Scene {
    WindowGroup {
      NavigationWrapper(
        storage: .inMemory,
        identifier: "default",
        for: Route.self
      ) {
        // Your first view
      } environmentInjection: { route in
        // Environment injection
      }
    }
  }
}

enum Stack: String, NavigationStackRepresentable {
  var id: String { rawValue }
  case main
}

enum Route: String, NavigationRouteRepresentable {
  var id: String { String(describing: self) }

  case home
  case products
  case item(id: Int)

  var body: some View {
    switch self {
      case .home:
        HomeView()
      case .products:
        ProductsList()
      case .item(let id):
        ItemDetail(id: id)
    }
  }
}
```

### Initialising `NavigationWrapper`

The `NavigationWrapper` is a key component of the `RoutingManager` package, providing a way to set up and manage your app's navigation flow in a declarative manner.

When initialising `NavigationWrapper`, you configure how your navigation stack is managed and stored within the app.

```swift
NavigationWrapper(
  storage: .memory,
  stack: Stack.main,
  for: Route.self
) {
  // The initial view for the navigation stack
} environmentInjection: { route in
  // Inject dependencies or modify the environment for the route's view
  route.body
}
```

#### Parameters

1. `storage: NavigationStorageOption`

   - This parameter defines how the navigation state is stored. The `NavigationWrapper` supports multiple storage options:
     - `.memory`: Navigation state is stored in memory. It is not and cannot be persisted across app launches.
     - `.json`: Navigation state is stored in a JSON file. It is persisted across app launches if the user chooses.
     - `.custom(FileStorage<[Stack: [Route]]>)`: Navigation state is stored in a custom storage implementation. The user chooses how to handle saving, and loading across app launches.

1. `stack: NavigationStackRepresentable`

   - This is the stack you wish to update routes to. Specifying a stack allows you to initialise multiple `NavigationWrapper` across your app and have it affect specific stacks. For example, a `.main` stack for your navigation, and another one for `.sheet` or different tabs in a `TabView`.

1. `for: R.Type`

   - This specifies the type of routes your navigation stack will handle. Typically, this is the enum that conforms to `NavigationRouteRepresentable`, defining all possible routes in your app. By providing the route type, `NavigationWrapper` can manage the navigation between different views based on the routes you define.

1. `content: () -> View`

   - The trailing closure is where you provide the initial view or entry point for your navigation stack. This is the view that users will see when they first launch the app or when the navigation stack is reset. You can structure your navigation flow starting from this view, utilising the routes you've defined.

1. `environmentInjection: (R) -> View`

   - This closure takes a `Route` instance as its parameter, which represents the current route being handled.
   - Inside this closure, you can modify the environment or inject dependencies that are required by the view associated with the route.
   - The closure returns a `View`, which is typically the view defined in the `body` property of the route. However, you can wrap this view with additional modifiers or environment objects as needed.

#### When to Use `environmentInjection`

- **Dependency Injection:** If your views need access to specific environment objects, you can inject them here. For instance, you might inject a data model or a service object that the view needs to function properly.

- **Dynamic Modifications:** If certain views require dynamic modifications based on the route, you can apply those changes in this closure. This allows for greater flexibility and reuse of views.

##### Example Scenario

Imagine you have a route that requires access to a user profile object, which is stored in an environment. You could inject this dependency directly through the `environmentInjection` closure:

```swift
environmentInjection: { route in
  route.body
    .environmentObject(UserProfile())
}
```

### Navigation route methods

`RoutingManager` provides several methods to manage navigation routing:

| **Function** | **Explanation** | **Example** |
|-------------|---------------|-----------|
| `push(to screens: Route...) -> NavigationResult` | Pushes one or more screens onto the navigation stack. | `push(to: homeScreen, detailsScreen)` |
| `goBack(_ numberOfScreens: Int) -> NavigationResult` | Navigates back by a specified number of screens. | `goBack(2)` |
| `goToOccurrence(of screen: Route, direction: OccurrenceDirection) -> NavigationResult` | Navigates to a specific occurrence of a screen in the navigation stack, based on direction. | `goToOccurrence(of: profileScreen, direction: .first)` |
| `replaceCurrentScreen(with screen: Route) -> NavigationResult` | Replaces the current screen with a new screen. | `replaceCurrentScreen(with: settingsScreen)` |
| `replace(stack: Stack, with routes: [Route]) -> NavigationResult` | Replaces a specific navigation stack with a new sequence of screens, while keeping other stacks unchanged. | `replace(stack: .productStack, with: homeScreen, productsScreen, itemScreen)` |
| `replaceCurrentStack(with routes: [Route]) -> NavigationResult` | Replaces the entire navigation stack associated with this manager with a new sequence of screens. | `replaceCurrentStack(with: homeScreen, profileScreen, settingsScreen)` |
| `override(navigation: [Stack: [Route]]) -> NavigationResult` | Overrides the entire stored navigation state with a new dictionary of stacks and routes. This completely replaces all stacks and routes. | `override(navigation: [.main: [homeScreen, cartScreen], .auth: [loginScreen]])` |
| `resetNavigation() -> NavigationResult` | Resets the navigation stack, removing all screens. | `resetNavigation()` |

### Navigation stack methods

`RoutingManager` provides several methods to manage navigation stacks:

| **Function** | **Explanation** | **Example** |
|-------------|---------------|-----------|
| `listRoutes() -> [Stack: [Route]]` | Retrieves a list of all routes currently present in the navigation stack. | `listRoutes()` |
| `save() -> NavigationResult` | Saves the current navigation state. | `save()` |
| `load() -> NavigationResult` | Loads a previously saved navigation state. | `load()` |
| `delete() -> NavigationResult` | Deletes the saved navigation state. | `delete()` |

### Storage Options

`RoutingManager` supports multiple storage options for saving and loading navigation paths:

#### Memory storage

In-memory storage is the simplest form of storage. It stores navigation paths temporarily during the app's session and does not persist across app launches.

```swift
@State private var routeManager: Routes = .init(
  storage: .memory,
  stack: Stack.main,
  for: Route.self
)
```

#### JSON file storage

JSON file storage saves navigation paths as `.json` files on the device, allowing them to persist across app launches. This is useful for apps that need to restore navigation states after a restart.

```swift
@State private var routeManager: Routes = .init(
  storage: .json,
  stack: Stack.main,
  for: Route.self
)
```

#### Custom Storage

You can implement your own storage by conforming to the `FileStorageRepresentable` protocol. For example, here's how you might implement XML storage:

```swift

// XMLFileStorage.swift
class XMLFileStorage<T: Codable>: FileStorageRepresentable {
  private let fileManager = FileManager.default
  private let fileURL: URL

  init(fileName: String = "NavigationState.xml") {
        let directory = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first!
        self.fileURL = directory.appendingPathComponent(fileName)
  }

  func save(_ object: T) throws {
    let encoder = PropertyListEncoder()
    encoder.outputFormat = .xml
    let data = try encoder.encode(object)
    try data.write(to: fileURL)
  }

  func load() throws -> T? {
    guard FileManager.default.fileExists(atPath: fileURL.path) else { return nil }
    let data = try Data(contentsOf: fileURL)
    do {
      let decoder = PropertyListDecoder()
      return try decoder.decode(T.self, from: data)
    } catch {
      throw NavigationError.load(error)
    }
  }

  func delete() throws {
    guard FileManager.default.fileExists(atPath: fileURL.path) else { return }
    try FileManager.default.removeItem(at: fileURL)
  }
}

// SwiftUI view
@State private var routeManager: Routes = .init(
  storage: .custom(FileStorage(XMLFileStorage())),
  stack: Stack.main,
  for: Route.self
)
```

### Error Handling

`RoutingManager` provides robust error handling with the `.navigationError` modifier. This modifier allows you to handle errors that occur during navigation operations.

```swift
routeManager.push(to: .home)
  .navigationError { error in
    print("An error occurred: \(error.localizedDescription)")
  }
```

## Contributing

Contributions are welcome! If you have suggestions or improvements, please fork the repository and submit a pull request.

## License

`RoutingManager` is released under the MIT license. See LICENCE for details.

[Shield1]: https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fmarkbattistella%2FRoutingManager%2Fbadge%3Ftype%3Dswift-versions

[Shield2]: https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fmarkbattistella%2FRoutingManager%2Fbadge%3Ftype%3Dplatforms

[Shield3]: https://img.shields.io/badge/Licence-MIT-white?labelColor=blue&style=flat
