<!-- markdownlint-disable MD033 MD041 -->
<div align="center">

# RoutingManager

![Licence](https://img.shields.io/badge/Licence-MIT-white?labelColor=blue&style=flat)

</div>

A Swift package that provides a robust and flexible navigation management system for SwiftUI applications. `RoutingManager` allows you to easily manage navigation paths, handle errors, and persist navigation states using customisable storage mechanisms.

## Features

- **Easy Navigation Management:** Simplify your app’s navigation with an intuitive API.
- **Customisable Error Handling:** Handle navigation-related errors with custom error types and a fluent, chain-able interface.
- **Persistence Support:** Save and load navigation paths using customisable storage solutions.
- **SwiftUI Integration:** Seamlessly integrates with SwiftUI’s NavigationStack and @Observable to provide a reactive and modern experience.
- **Extensible:** Easily extend the functionality by conforming to protocols for custom routes and storage mechanisms.

## Installation

### Swift Package Manager

You can add `RoutingManager` to your project via Swift Package Manager. Add the following dependency to your `Package.swift`:

```swift
dependencies: [
  .package(
    url: "https://github.com/markbattistella/RoutingManager.git",
    from: "1.0.0"
  )
]
```

## Usage

### Basic setup

To get started with `RoutingManager`, import it into your SwiftUI view:

```swift
import RoutingManager
```

### Defining routes

Create a custom route by conforming to the `NavigationRouteRepresentable` protocol:

```swift
import SwiftUI
import RoutingManager

enum Route: String, NavigationRouteRepresentable {
  var id: String { rawValue }

  case home
  case detail

  @ViewBuilder
  @MainActor
  var body: some View {
    switch self {
      case .home:
        Text("Home Screen")
      case .detail:
        Text("Detail Screen")
    }
  }
}
```

### Initialising the `RouteManager`

Initialise the `RouteManager` with your routes:

```swift
let routeManager = RouteManager<Route>()
```

### Navigating between screens

Use the `push`, `goBack`, and `reset` methods to manage navigation:

```swift
routeManager.push(to: .home)
  .navigationError { error in
    print("Error occurred: \(error.localizedDescription)")
  }

routeManager.goBack(save: true)
  .navigationError { error in
    print("Error occurred: \(error.localizedDescription)")
  }

routeManager.reset(save: true)
  .navigationError { error in
    print("Error occurred: \(error.localizedDescription)")
  }
```

### Saving and loading navigation paths

`RouteManager` can save and load navigation paths to a storage solution:

```swift
do {
  try routeManager.saveCurrentPath()
} catch {
  print("Failed to save path: \(error.localizedDescription)")
}

do {
  try await routeManager.loadLastSavedPath()
} catch {
  print("Failed to load path: \(error.localizedDescription)")
}
```

## Customising storage

You can create a custom storage solution by conforming to the `NavigationPathStorage` protocol:

```swift
struct CustomPathStorage: NavigationPathStorage {
    func save(data: Data, identifier: String?) throws {
        // Custom save logic
    }

    func load(identifier: String?) throws -> Data {
        // Custom load logic
        return Data()
    }
}

let customStorage = CustomPathStorage()
let routeManager = RouteManager<Route>(storage: customStorage)
```

## Contributing

Contributions are welcome! If you have suggestions or improvements, please fork the repository and submit a pull request.

## License

`RoutingManager` is released under the MIT license. See [LICENSE](https://raw.githubusercontent.com/markbattistella/RoutingManager/main/LICENCE) for details.
