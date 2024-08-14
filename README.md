<!-- markdownlint-disable MD033 MD041 -->
<div align="center">

# RoutingManager

[![Swift Version][Shield1]](https://swiftpackageindex.com/markbattistella/RoutingManager)

[![OS Platforms][Shield2]](https://swiftpackageindex.com/markbattistella/RoutingManager)

[![Licence][Shield3]](https://github.com/markbattistella/RoutingManager/blob/main/LICENSE)

</div>

`RoutingManager` is a Swift package designed to simplify and enhance navigation in SwiftUI applications. It supports stateful navigation with persistent storage, allowing developers to manage complex navigation flows with ease. The package also provides flexible storage options, including in-memory and JSON-based file storage, with the ability to implement custom storage solutions.

## Features

- **Stateful Navigation:** Manage navigation stacks with ease, supporting push, pop, reset, and replace operations.
- **Persistent Storage:** Save and load navigation paths using in-memory or file system storage.
- **Custom Storage Support:** Implement your own storage solutions, such as XML or other formats.
- **Error Handling:** Handle navigation errors with clear and actionable feedback using the `.navigationError` modifier.
- **Environment Injection:** Inject dependencies directly into your views using `@Environment`.

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

To start using `RoutingManager`, import the package and create a `RoutingManager` instance in your SwiftUI view. Here’s a basic setup:

```swift
import SwiftUI
import RoutingManager

typealias Routes = RoutingManager<Route>

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

enum Route: String, NavigationRouteRepresentable {
  case home
  case settings
  var id: String { rawValue }
  var body: some View {
    switch self {
      case .home: HomeView()
      case .settings: SettingsView()
    }
  }
}
```

### Initializing `NavigationWrapper`

The `NavigationWrapper` is a key component of the `RoutingManager` package, providing a way to set up and manage your app's navigation flow in a declarative manner. When initializing `NavigationWrapper`, you configure how your navigation stack is managed, stored, and identified within the app.

```swift
NavigationWrapper(
  storage: .inMemory,
  identifier: "default",
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

   - This parameter defines how the navigation state is stored. The NavigationWrapper supports multiple storage options:
     - `.inMemory`: Stores the navigation state in memory. This is useful for simple use cases where the navigation state doesn't need to persist across app launches.
     - `fileSystem(directory:)`: Stores the navigation state in a file, enabling persistence across app sessions. You can specify a file path or use the default location.
     - Custom storage options can also be implemented by conforming to the `NavigationStorageRepresentable` protocol.

1. `identifier: String`

   - This is a unique identifier for the navigation stack. It allows you to distinguish between different navigation stacks in your app, especially when using persistent storage. For instance, you might have separate stacks for different user flows or sections of your app. The identifier ensures that each stack is managed independently.

1. `for: R.Type`

   - This specifies the type of routes your navigation stack will handle. Typically, this is the enum that conforms to `NavigationRouteRepresentable`, defining all possible routes in your app. By providing the route type, `NavigationWrapper` can manage the navigation between different views based on the routes you define.

1. `content: () -> View`

   - The trailing closure is where you provide the initial view or entry point for your navigation stack. This is the view that users will see when they first launch the app or when the navigation stack is reset. You can structure your navigation flow starting from this view, utilising the routes you've defined.

1. `environmentInjection: (R) -> View`

   - This closure takes a `Route` instance as its parameter, which represents the current route being handled.
   - Inside this closure, you can modify the environment or inject dependencies that are required by the view associated with the route.
   - The closure returns a `View`, which is typically the view defined in the `body` property of the route. However, you can wrap this view with additional modifiers or environment objects as needed.

#### When to Use `environmentInjection`:

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

### Navigation Methods

`RoutingManager` provides several methods to manage navigation stacks:

| **Function** | **Explanation** | **Example** |
|-|-|-|
| **`push(to:)`** | Pushes a new screen onto the navigation stack. | `routeManager.push(to: .home)` |
| **`goBack(_:)`** | Pops screens from the navigation stack. | `routeManager.goBack(1)` |
| **`goToFirstOccurrence(of:)`** | Navigates to the first occurrence of a screen in the stack. | `routeManager.goToFirstOccurrence(of: .settings)` |
| **`goToLastOccurrence(of:)`** | Navigates to the last occurrence of a screen in the stack. | `routeManager.goToLastOccurrence(of: .home)` |
| **`replaceCurrent(with:)`** | Replaces the current screen with a new one. | `routeManager.replaceCurrent(with: .settings)` |
| **`replaceCurrentStack(with:)`** | Replaces the entire navigation stack with a new one. | `routeManager.replaceCurrentStack(with: [.home, .settings])` |
| **`resetNavigation()`** | Resets the navigation stack to an empty state. | `routeManager.resetNavigation()` |

### Storage Options

`RoutingManager` supports multiple storage options for saving and loading navigation paths:

#### In-Memory Storage

In-memory storage is the simplest form of storage. It stores navigation paths temporarily during the app's session and does not persist across app launches.

```swift
@State private var routeManager: Routes = .init(
  storage: .inMemory,
  identifier: "default"
)
```

#### JSON File Storage

JSON file storage saves navigation paths as `.json` files on the device, allowing them to persist across app launches. This is useful for apps that need to restore navigation states after a restart.

```swift
public class XMLFileStorage<T: Codable>: FileStorageRepresentable {
    // Implementation details
}

// Usage:
@State private var routeManager: Routes = .init(
    storage: .custom(storage: FileStorage(XMLFileStorage())),
    identifier: "default"
)
```

#### Custom Storage

You can implement your own storage by conforming to the `FileStorageRepresentable` protocol. For example, here’s how you might implement XML storage:

```swift

// XMLFileStorage.swift
class XMLFileStorage<T: Codable>: FileStorageRepresentable {
  private let fileManager = FileManager.default
  private let directory: URL

  init(directory: FileManager.SearchPathDirectory = .documentDirectory) {
    self.directory = fileManager.urls(for: directory, in: .userDomainMask).first!
  }

  private func fileURL(for identifier: String) -> URL {
    return directory.appendingPathComponent("\(identifier).xml")
  }

  func save(_ object: T, as identifier: String) async throws {
    let encoder = PropertyListEncoder()
    encoder.outputFormat = .xml
    let data = try encoder.encode(object)
    let url = fileURL(for: identifier)
    try data.write(to: url)
  }

  func load(for identifier: String) async throws -> T? {
    let url = fileURL(for: identifier)
    guard fileManager.fileExists(atPath: url.path) else {
      return nil
    }
    let data = try Data(contentsOf: url)
    let decoder = PropertyListDecoder()
    return try decoder.decode(T.self, from: data)
  }

  func delete(for identifier: String) async throws {
    let url = fileURL(for: identifier)
    try fileManager.removeItem(at: url)
  }

  func listAllIdentifiers() async throws -> [String] {
    let files = try fileManager.contentsOfDirectory(atPath: directory.path)
    return files
      .filter { $0.hasSuffix(".xml") }
      .map { $0.replacingOccurrences(of: ".xml", with: "") }
  }
}

// SwiftUI view
@State private var routeManager: Routes = .init(
  storage: .custom(storage: FileStorage(XMLFileStorage<Route>())),
  identifier: "default"
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

## Conclusion

`RoutingManager` is a powerful tool for managing complex navigation flows in SwiftUI applications. With support for persistent storage, custom storage solutions, and robust error handling, it provides a flexible and maintainable way to handle navigation in your app.

## Contributing

Contributions are welcome! If you have suggestions or improvements, please fork the repository and submit a pull request.

## License

`RoutingManager` is released under the MIT license. See [LICENSE](https://github.com/markbattistella/RoutingManager/blob/main/LICENSE) for details.

[Shield1]: https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fmarkbattistella%2FRoutingManager%2Fbadge%3Ftype%3Dswift-versions

[Shield2]: https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fmarkbattistella%2FRoutingManager%2Fbadge%3Ftype%3Dplatforms

[Shield3]: https://img.shields.io/badge/Licence-MIT-white?labelColor=blue&style=flat
