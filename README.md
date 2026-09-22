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
- `NavigationSplitWrapper` for two- and three-column navigation with managed selections
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

## Example App

Open [`RoutingManager.xcworkspace`](RoutingManager.xcworkspace) and select the
`RoutingManagerExample` scheme. The workspace includes this package and an example app linked
through a local package reference. Run it on iPhone, iPad, or Mac (iOS 17+ / macOS 14+).

| Tab | Demonstrates | Source |
| --- | --- | --- |
| Stack | Value-based links, pushing multiple routes, replacement, back, and reset. | [StackExample.swift](Example/RoutingManagerExample/StackExample.swift) |
| Two columns | Sidebar selection, a detail stack, coordinated navigation, and column controls. | [TwoColumnExample.swift](Example/RoutingManagerExample/TwoColumnExample.swift) |
| Three columns | Folder and document selections, detail routes, clearing selections, and compact adaptation. | [ThreeColumnExample.swift](Example/RoutingManagerExample/ThreeColumnExample.swift) |

The examples use memory storage, with independent managers in each window. Try switching a
folder while a detail route is pushed, resetting navigation, and resizing or rotating the window.
The split manager's JSON and custom storage options are described below.

The package remains at the repository root and can still be consumed through Swift Package
Manager without building the example app.

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
            } environmentInjection: { route in
                route.body
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
| `replaceCurrentStack(with:)` | Replaces every route in the manager's current stack. |
| `replace(stack:with:)` | Replaces one stack while preserving the others. |
| `override(navigation:)` | Replaces the complete navigation state. |
| `resetNavigation()` | Clears the current stack. |
| `listRoutes()` | Returns all currently managed stacks and routes. |
| `load()` | Loads state from the configured storage. |
| `delete()` | Deletes the current stack from state and storage. |

Each mutating operation returns a `NavigationResult` and updates `lastResult`. Inspect
`isSuccess` or `error` directly, or use `navigationError(_:)` for chained handling. Persistence
failures leave the requested in-memory navigation in place so the UI and result cannot disagree.

```swift
navigation.push(to: .item(id: 42))
    .navigationError { error in
        print(error.localizedDescription)
    }
```

## Split Navigation

`NavigationSplitWrapper` presents a native `NavigationSplitView` with a `NavigationStack` in
its detail column. `NavigationSplitManager` owns the selections and detail routes. The existing
stack-only manager and its saved data format are unchanged.

### Shared models

Sidebar and content selections need `Hashable` and `Codable`; they do not need to provide a view.
Use stable IDs or enums as selections. The default route and stack IDs are intended for debugging
and ordinary in-process identification; override `id` with an explicit, versioned value when it is
part of a durable deep link or persisted external record. Detail routes use `NavigationRouteRepresentable` as usual.
Use distinct types for selections and pushed routes so that value-based links resolve to the
intended column.

```swift
import RoutingManager
import SwiftUI

enum LibrarySection: String, CaseIterable, Identifiable, Codable {
    case inbox, archive
    var id: Self { self }
}

enum LibraryRoute: NavigationRouteRepresentable {
    case information(Int)

    var body: some View {
        switch self {
        case .information(let id):
            Text("Information for item \(id)")
        }
    }
}
```

### Two columns

Use `Never` for the unused content selection type. The sidebar selection determines the detail
root, and routes push further into that detail.

```swift
struct TwoColumnLibrary: View {
    @State private var navigation = NavigationSplitManager<LibrarySection, Never, LibraryRoute>()

    var body: some View {
        @Bindable var navigation = navigation

        NavigationSplitWrapper(manager: navigation) {
            List(LibrarySection.allCases, selection: $navigation.sidebarSelection) { section in
                NavigationLink(section.rawValue.capitalized, value: section)
            }
            .navigationTitle("Library")
        } detail: {
            if let section = navigation.sidebarSelection {
                List {
                    NavigationLink("Item information", value: LibraryRoute.information(1))
                }
                .navigationTitle(section.rawValue.capitalized)
            } else {
                Text("Select a section")
            }
        }
    }
}
```

Own the root view inside each `WindowGroup` so each window gets its own manager. The wrapper
observes the manager passed to it; it does not retain an initial copy in its own `@State`.

### Three columns

Replace `Never` with the middle column's selection type and add the `content` builder. In this
example the sidebar selects a section, the content column selects an integer item ID, and the
detail column can push information routes.

```swift
struct ThreeColumnLibrary: View {
    @State private var navigation = NavigationSplitManager<LibrarySection, Int, LibraryRoute>()

    private var itemIDs: [Int] {
        switch navigation.sidebarSelection {
        case .inbox: [1, 2, 3]
        case .archive: [4, 5]
        case nil: []
        }
    }

    var body: some View {
        @Bindable var navigation = navigation

        NavigationSplitWrapper(manager: navigation) {
            List(LibrarySection.allCases, selection: $navigation.sidebarSelection) { section in
                NavigationLink(section.rawValue.capitalized, value: section)
            }
            .navigationTitle("Library")
        } content: {
            List(itemIDs, id: \.self, selection: $navigation.contentSelection) { id in
                NavigationLink("Item \(id)", value: id)
            }
            .navigationTitle("Items")
        } detail: {
            if let id = navigation.contentSelection {
                List {
                    NavigationLink("Item information", value: LibraryRoute.information(id))
                }
                .navigationTitle("Item \(id)")
            } else {
                Text("Select an item")
            }
        }
    }
}
```

Bind leading lists to the corresponding manager selection. Use `NavigationLink(value:)` for
selection rows so SwiftUI can coordinate column navigation when the interface collapses.
The wrapper already supplies the detail `NavigationStack` and route destination registration.

### Programmatic navigation

The manager is available through the environment in every column and every pushed destination.
The generic arguments must match the manager supplied to the wrapper.
Destinations used here should request `NavigationSplitManager`; the split wrapper does not inject
the stack-only `NavigationManager`.

```swift
struct ItemActions: View {
    @Environment(NavigationSplitManager<LibrarySection, Int, LibraryRoute>.self)
    private var navigation

    var body: some View {
        Button("Open archived item") {
            navigation.navigate(to: .init(
                sidebarSelection: .archive,
                contentSelection: 4,
                detailPath: [.information(4)]
            ))
        }
    }
}
```

`navigate(to:)` updates selections and path together and persists once. The manager clears
structurally invalid child state, such as a content selection without a sidebar selection.
The app remains responsible for checking whether IDs exist and belong to the selected parent.

| Operation | Behaviour |
| --- | --- |
| `selectSidebar(_:)` / `sidebarSelection =` | A changed value clears the content selection and detail path. |
| `selectContent(_:)` / `contentSelection =` | A changed value clears the detail path; non-nil values require a sidebar selection. |
| `push(to:)` | Pushes detail routes; requires a selected detail root. |
| `goBack(_:)` | Pops detail routes and preserves column selections. |
| `goToOccurrence(of:direction:)` | Pops to a matching detail route occurrence. |
| `replaceCurrentScreen(with:)` | Replaces the top detail route. |
| `resetDetailNavigation()` | Clears only the detail path. |
| `resetNavigation()` / `delete()` | Clears all selections and routes, deletes persisted state, and prefers the sidebar in compact layouts. |
| `navigate(to:)` | Applies a complete selection/path snapshot. |
| `load()` | Explicitly restores a saved snapshot. |

Reassigning the same selection preserves its existing detail history. Switching to another
selection clears history; this release does not keep a separate remembered path for each item.
A full reset, clearing the sidebar selection, or applying a snapshot without a sidebar selection
starts a new split-view presentation, also resetting view-local state inside its columns.
SwiftUI-driven path and selection changes persist through the same setters as programmatic changes.
Methods return `NavigationResult`. Binding-driven updates report failures through `lastResult`.
Storage failures leave the new in-memory state in place, matching the existing stack manager.

### Persistence

Memory storage is the default. For JSON storage, provide a filename unique to the split interface
and, when independently restoring multiple windows, to the window's stable identity.

```swift
let navigation = NavigationSplitManager<LibrarySection, Int, LibraryRoute>(
    storageMode: .json(fileName: "LibrarySplitNavigation.json")
)
navigation.load()
```

Files are stored in the user's documents directory. Use a different filename from the stack
manager's `NavigationState.json`; the formats are different and no migration is required when
they use separate files. Avoid sharing a filename across managers that save independently.

Call `load()` once when the owning scene is ready to restore; the wrapper does not load
automatically. A missing file is a successful no-op. Failed loads preserve the current
navigation. Validate restored IDs against your data and use `navigate(to:)` to replace stale state.

For custom storage, wrap a `FileStorageRepresentable` implementation whose `T` is
`NavigationSplitState<LibrarySection, Int, LibraryRoute>` in `FileStorage`, then pass `.custom(storage)`.
The public `snapshot` provides the same Codable state. Visibility and the preferred compact
column are transient; loading derives the preferred column from the restored selections.

### Presentation and destinations

`columnVisibility` and `preferredCompactColumn` are bindable SwiftUI values. For example, assign
`.all` to `columnVisibility` to request all columns, or `.sidebar` to `preferredCompactColumn`
to request the sidebar in a collapsed layout. These are preferences that SwiftUI resolves
against the current layout. To leave a pushed detail flow programmatically, clear its path with
`resetDetailNavigation()` before requesting an earlier compact column.
Requests for columns whose parent selections are missing fall back to the nearest available
parent. This prevents delayed compact navigation updates from undoing a reset.

Apply `navigationSplitViewColumnWidth` to a column's content and `navigationSplitViewStyle`
to the wrapper. SwiftUI handles collapse and expansion; don't swap wrappers based on screen width.
See [Apple's NavigationSplitView documentation](https://developer.apple.com/documentation/swiftui/navigationsplitview)
for platform-specific presentation behaviour.

Both wrapper initializers accept an optional trailing `destination` builder in their custom
destination overload. For example, `destination: { route in route.body.environment(service) }`
injects a dependency into pushed views. Without that builder, each destination uses `route.body`.
The split manager remains available through the environment in either case.

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

Legacy `.json` storage writes navigation state to `NavigationState.json` in the user's documents
directory. Prefer `.jsonFile(fileName:)` with a unique filename for each independently persisted
manager; managers using the same file replace the complete stored snapshot. Call `load()` when you
want to restore a previously saved path. A missing file is a successful no-op.

```swift
let navigation = NavigationManager<AppStack, AppRoute>(
    for: .main,
    storageMode: .jsonFile(fileName: "MainNavigation.json")
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
