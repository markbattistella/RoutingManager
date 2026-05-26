<!-- markdownlint-disable MD033 MD041 -->
<div align="center">

# RoutingManager

[![Swift Version][Shield1]](https://swiftpackageindex.com/markbattistella/RoutingManager)

[![OS Platforms][Shield2]](https://swiftpackageindex.com/markbattistella/RoutingManager)

[![Licence][Shield3]](https://github.com/markbattistella/RoutingManager/blob/main/LICENSE)

</div>

`RoutingManager` is a SwiftUI navigation package built around a main-actor
`NavigationManager`. It manages typed `NavigationStack` paths, exposes route operations such as
push/back/reset, and can persist navigation state through memory, JSON file, or custom storage.

## Features

- Typed SwiftUI route and stack models
- Observable `NavigationManager` for push, back, reset, load, and delete operations
- `NavigationWrapper` for binding a manager to `NavigationStack`
- Memory, JSON file, and custom storage support
- Result-based navigation error handling
- Swift 6 language mode

## Installation

Add `RoutingManager` to your Swift project using Swift Package Manager.

```swift
dependencies: [
    .package(url: "https://github.com/markbattistella/RoutingManager", from: "26.3.8")
]
```

## Requirements

- Swift 6.0+
- iOS 17.0+, macOS 14.0+, Mac Catalyst 17.0+, tvOS 17.0+, watchOS 10.0+, visionOS 1.0+

## Usage

Define a stack and route type:

```swift
import RoutingManager
import SwiftUI

enum AppStack: NavigationStackRepresentable {
    case main
}

enum AppRoute: NavigationRouteRepresentable {
    case products
    case item(id: Int)

    @MainActor
    @ViewBuilder
    var body: some View {
        switch self {
        case .products:
            ProductsView()
        case .item(let id):
            ItemDetailView(id: id)
        }
    }
}
```

Wrap your root view in `NavigationWrapper`:

```swift
@main
struct ExampleApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationWrapper(
                storage: .memory,
                stack: AppStack.main,
                for: AppRoute.self
            ) {
                HomeView()
            }
        }
    }
}
```

Access the manager from child views:

```swift
struct HomeView: View {
    @Environment(NavigationManager<AppStack, AppRoute>.self)
    private var navigation

    var body: some View {
        Button("Products") {
            navigation.push(to: .products)
        }
    }
}
```

Inject dependencies into destinations when needed:

```swift
NavigationWrapper(
    storage: .json,
    stack: AppStack.main,
    for: AppRoute.self
) {
    HomeView()
} environmentInjection: { route in
    route.body
        .environment(CatalogService())
}
```

## Navigation Operations

`NavigationManager` is main-actor isolated because it owns mutable UI navigation state.

| Function | Description |
| --- | --- |
| `push(to:)` | Pushes one or more routes onto the current stack. |
| `goBack(_:)` | Removes routes from the current stack. Non-positive values are safe no-ops. |
| `goToOccurrence(of:direction:)` | Trims the stack to the first or last matching route occurrence. |
| `replaceCurrentScreen(with:)` | Replaces the current top route. |
| `resetNavigation()` | Clears the current stack. |
| `listRoutes()` | Returns all currently managed stacks and routes. |
| `load()` | Loads state from the configured storage. |
| `delete()` | Deletes the current stack from state and storage. |

Each mutating operation returns a `NavigationResult` and updates `lastResult`.

```swift
navigation.push(to: .item(id: 42))
    .navigationError { error in
        print(error.localizedDescription)
    }
```

## Storage

### Memory

Memory storage keeps navigation state only for the lifetime of the manager.

```swift
let navigation = NavigationManager<AppStack, AppRoute>(
    for: .main,
    storageMode: .memory
)
```

### JSON

JSON storage writes navigation state to `NavigationState.json` in the user's documents directory.
Call `load()` when you want to restore a previously saved path.

```swift
let navigation = NavigationManager<AppStack, AppRoute>(
    for: .main,
    storageMode: .json
)

navigation.load()
```

### Custom

Implement `FileStorageRepresentable` when you need a different backing store.

```swift
final class XMLFileStorage<T: Codable>: FileStorageRepresentable {
    private let fileURL: URL

    init(fileName: String = "NavigationState.xml") {
        let directory = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first ?? URL(fileURLWithPath: NSTemporaryDirectory())
        self.fileURL = directory.appendingPathComponent(fileName)
    }

    func save(_ object: T) throws {
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .xml
        let data = try encoder.encode(object)
        try data.write(to: fileURL, options: .atomic)
    }

    func load() throws -> T? {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return nil
        }

        let data = try Data(contentsOf: fileURL)
        return try PropertyListDecoder().decode(T.self, from: data)
    }

    func delete() throws {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return
        }

        try FileManager.default.removeItem(at: fileURL)
    }
}

let storage = FileStorage(XMLFileStorage<[AppStack: [AppRoute]]>())

let navigation = NavigationManager<AppStack, AppRoute>(
    for: .main,
    storageMode: .custom(storage)
)
```

## License

`RoutingManager` is released under the MIT license. See `LICENSE` for details.

[Shield1]: https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fmarkbattistella%2FRoutingManager%2Fbadge%3Ftype%3Dswift-versions

[Shield2]: https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fmarkbattistella%2FRoutingManager%2Fbadge%3Ftype%3Dplatforms

[Shield3]: https://img.shields.io/badge/Licence-MIT-white?labelColor=blue&style=flat
