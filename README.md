<!-- markdownlint-disable MD033 MD041 -->
<div align="center">

# RoutingManager

![Licence](https://img.shields.io/badge/Licence-MIT-white?labelColor=blue&style=flat)

</div>

`RoutingManager` is a Swift package designed to simplify and enhance navigation in SwiftUI applications. It supports stateful navigation with persistent storage, allowing developers to manage complex navigation flows with ease. The package also provides flexible storage options, including in-memory and JSON-based file storage, with the ability to implement custom storage solutions.

## Features

- **Stateful Navigation:** Manage navigation stacks with ease, supporting push, pop, reset, and replace operations.
- **Persistent Storage:** Save and load navigation paths using in-memory or file system storage.
- **Custom Storage Support:** Implement your own storage solutions, such as XML or other formats.
- **Error Handling:** Handle navigation errors with clear and actionable feedback using the `.navigationError` modifier.

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
struct MyApp: App {
  var body: some Scene {
    WindowGroup {
      NavigationStackWrapper()
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

struct NavigationStackWrapper: View {
  @State private var routeManager: Routes = .init(
    storage: .inMemory,
    identifier: "default"
  )
  var body: some View {
    NavigationStack(path: $routeManager.routes) {
      EntryScreen()
        .environment(routeManager)
        .navigationDestination(for: Route.self) { destination in
          destination.body.environment(routeManager)
        }
    }
  }
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

### Full Example

Here’s a full example demonstrating the use of `RoutingManager` with file storage persistence:

```swift
import SwiftUI
import RoutingManager

@main
struct MyApp: App {
  var body: some Scene {
    WindowGroup {
      NavigationStackWrapper()
    }
  }
}

enum Route: String, NavigationRouteRepresentable {
  case home
  case settings
  case profile
  var id: String { rawValue }
  var body: some View {
    switch self {
      case .home: HomeView()
      case .settings: SettingsView()
      case .profile: ProfileView()
    }
  }
}

struct NavigationStackWrapper: View {
  @State private var routeManager: Routes = .init(
    storage: .fileSystem(directory: .documentDirectory),
    identifier: "default"
  )
  var body: some View {
    NavigationStack(path: $routeManager.routes) {
      EntryScreen()
        .environment(routeManager)
        .navigationDestination(for: Route.self) { destination in
          destination.body.environment(routeManager)
        }
    }
  }
}

struct EntryScreen: View {
  @Environment(Routes.self) private var routeManager
  var body: some View {
    VStack {
      Button("Open Home") {
        routeManager.push(to: .home)
      }
      Button("Save Current Route") {
        routeManager.saveRouteStack(for: PathIdentifier(label: "Entry Route"))
      }
      Button("Load Saved Route") {
        Task {
          if let customID = try? await routeManager.getPathIdentifier(for: "Entry Route") {
            await routeManager.load(with: customID)
          }
        }
      }
    }
    .padding()
  }
}

struct HomeView: View {
  @Environment(Routes.self) private var routeManager
  var body: some View {
    Button("Open Settings") {
      routeManager.push(to: .settings)
    }
  }
}

struct SettingsView: View {
  @Environment(Routes.self) private var routeManager
  var body: some View {
    VStack {
      Button("Open Profile") {
        routeManager.push(to: .profile)
      }
      Button("Go Back") {
        routeManager.goBack()
      }
      Button("Reset Navigation") {
        routeManager.resetNavigation()
      }
    }
    .padding()
  }
}

struct ProfileView: View {
  @Environment(Routes.self) private var routeManager
  var body: some View {
    Button("Back to Home") {
      routeManager.goBack()
    }
  }
}
```

## Conclusion

`RoutingManager` is a powerful tool for managing complex navigation flows in SwiftUI applications. With support for persistent storage, custom storage solutions, and robust error handling, it provides a flexible and maintainable way to handle navigation in your app.

## Contributing

Contributions are welcome! If you have suggestions or improvements, please fork the repository and submit a pull request.

## License

`RoutingManager` is released under the MIT license. See [LICENSE](https://github.com/markbattistella/RoutingManager/blob/main/LICENSE) for details.
