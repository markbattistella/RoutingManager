//
// Project: RoutingManager
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import Foundation
import SwiftUI
import Testing

import RoutingManager

@Suite("Split navigation")
@MainActor
struct NavigationSplitManagerTests {
    private typealias TwoColumn = NavigationSplitManager<String, Never, SplitRoute>
    private typealias ThreeColumn = NavigationSplitManager<String, Int, SplitRoute>

    @Test("Two columns select a detail root and clear its path when the sidebar changes")
    func twoColumnSelection() {
        let manager = TwoColumn()
        manager.sidebarSelection = "inbox"
        manager.push(to: .info(1))
        #expect(manager.preferredCompactColumn == .detail)

        manager.sidebarSelection = "archive"
        #expect(manager.detailPath.isEmpty)
        #expect(manager.sidebarSelection == "archive")

        manager.sidebarSelection = nil
        #expect(manager.preferredCompactColumn == .sidebar)
        #expect(manager.snapshot == .init())
    }

    @Test("Three columns clear downstream selections and paths")
    func threeColumnSelection() {
        let manager = ThreeColumn()
        manager.sidebarSelection = "inbox"
        #expect(manager.preferredCompactColumn == .content)
        manager.contentSelection = 1
        manager.push(to: .info(1))
        #expect(manager.preferredCompactColumn == .detail)

        manager.contentSelection = 2
        #expect(manager.detailPath.isEmpty)
        #expect(manager.sidebarSelection == "inbox")
        manager.push(to: .info(2))
        manager.sidebarSelection = "archive"
        #expect(manager.contentSelection == nil)
        #expect(manager.detailPath.isEmpty)
        #expect(manager.preferredCompactColumn == .content)
    }

    @Test("Clearing content returns to the content column, preserving the sidebar")
    func clearContent() {
        let manager = ThreeColumn()
        manager.navigate(to: .init(sidebarSelection: "inbox", contentSelection: 1, detailPath: [.info(1)]))
        manager.contentSelection = nil
        #expect(manager.sidebarSelection == "inbox")
        #expect(manager.detailPath.isEmpty)
        #expect(manager.preferredCompactColumn == .content)
    }

    @Test("Repeated selections preserve the current detail history")
    func unchangedSelection() {
        let manager = ThreeColumn()
        let destination = ThreeColumn.State(
            sidebarSelection: "inbox",
            contentSelection: 1,
            detailPath: [.info(1)]
        )
        manager.navigate(to: destination)
        manager.sidebarSelection = "inbox"
        manager.contentSelection = 1
        #expect(manager.snapshot == destination)
    }

    @Test("Content and detail routes require their parent selections")
    func missingParents() {
        let manager = ThreeColumn()
        #expect(manager.selectContent(1).isMissingPath)
        #expect(manager.push(to: .info(1)).isMissingPath)
        manager.sidebarSelection = "inbox"
        #expect(manager.push(to: .info(1)).isMissingPath)
        manager.detailPath = [.info(1)]
        #expect(manager.lastResult.isMissingPath)
        #expect(manager.detailPath.isEmpty)
        #expect(manager.contentSelection == nil)
    }

    @Test("Detail pops clamp to the path and preserve column selections", arguments: [1, 2, 9])
    func popDetail(count: Int) {
        let manager = ThreeColumn()
        manager.navigate(
            to: .init(
                sidebarSelection: "inbox",
                contentSelection: 1,
                detailPath: [.info(1), .info(2)]
            )
        )
        #expect(manager.goBack(count).succeeded)
        #expect(manager.detailPath.count == max(0, 2 - count))
        #expect(manager.sidebarSelection == "inbox")
        #expect(manager.contentSelection == 1)
    }

    @Test("Invalid pop counts are harmless and an empty detail reports a missing path")
    func invalidPops() {
        let manager = TwoColumn()
        #expect(manager.goBack(0).succeeded)
        #expect(manager.goBack(-1).succeeded)
        #expect(manager.goBack(1).isMissingPath)
        #expect(manager.push().succeeded)
        #expect(manager.replaceCurrentScreen(with: .info(1)).isMissingPath)
        #expect(manager.goToOccurrence(of: .info(1), direction: .first).isMissingPath)
    }

    @Test("Occurrence navigation and replacement operate within the detail path")
    func detailOperations() {
        let manager = TwoColumn()
        manager.sidebarSelection = "inbox"
        manager.push(to: .info(1), .info(2), .info(1), .info(3))
        #expect(manager.goToOccurrence(of: .info(1), direction: .last).succeeded)
        #expect(manager.detailPath == [.info(1), .info(2), .info(1)])
        manager.replaceCurrentScreen(with: .info(4))
        #expect(manager.detailPath.last == .info(4))
        manager.goToOccurrence(of: .info(1), direction: .first)
        #expect(manager.detailPath == [.info(1)])
    }

    @Test("Detail reset preserves selections; full reset clears and deletes saved navigation")
    func resets() {
        let storage = SplitTestStorage<ThreeColumn.State>()
        let manager = ThreeColumn(storageMode: .custom(FileStorage(storage)))
        manager.navigate(to: .init(sidebarSelection: "inbox", contentSelection: 1, detailPath: [.info(1)]))
        manager.resetDetailNavigation()
        #expect(manager.sidebarSelection == "inbox")
        #expect(manager.contentSelection == 1)
        #expect(manager.detailPath.isEmpty)
        #expect(storage.saved?.contentSelection == 1)
        manager.resetNavigation()
        #expect(manager.snapshot == .init())
        #expect(manager.preferredCompactColumn == .sidebar)
        #expect(storage.saved == nil)
    }

    @Test("Two-column snapshots encode Never selections and restore a detail path")
    func twoColumnRestoration() throws {
        let storage = SplitTestStorage<TwoColumn.State>()
        let original = TwoColumn(storageMode: .custom(FileStorage(storage)))
        original.navigate(to: .init(sidebarSelection: "inbox", detailPath: [.info(1)]))
        let encoded = try JSONEncoder().encode(original.snapshot)
        storage.saved = try JSONDecoder().decode(TwoColumn.State.self, from: encoded)
        let restored = TwoColumn(storageMode: .custom(FileStorage(storage)))
        #expect(restored.load().succeeded)
        #expect(restored.snapshot == original.snapshot)
        #expect(restored.preferredCompactColumn == .detail)
    }

    @Test("Three-column navigation is saved as one snapshot and restored without rewriting storage")
    func threeColumnRestoration() throws {
        let storage = SplitTestStorage<ThreeColumn.State>()
        let original = ThreeColumn(storageMode: .custom(FileStorage(storage)))
        original.navigate(to: .init(sidebarSelection: "inbox", contentSelection: 7, detailPath: [.info(7)]))
        #expect(storage.saveCount == 1)
        let encoded = try JSONEncoder().encode(original.snapshot)
        storage.saved = try JSONDecoder().decode(ThreeColumn.State.self, from: encoded)
        let restored = ThreeColumn(storageMode: .custom(FileStorage(storage)))
        #expect(restored.load().succeeded)
        #expect(restored.snapshot == original.snapshot)
        #expect(restored.preferredCompactColumn == .detail)
        #expect(storage.saveCount == 1)
    }

    @Test("Restoring a parent-only selection shows the content column")
    func parentOnlyRestoration() {
        let storage = SplitTestStorage<ThreeColumn.State>()
        storage.saved = .init(sidebarSelection: "inbox")
        let manager = ThreeColumn(storageMode: .custom(FileStorage(storage)))
        #expect(manager.load().succeeded)
        #expect(manager.preferredCompactColumn == .content)
    }

    @Test("Restoration discards structurally orphaned state", arguments: [false, true])
    func orphanedRestoration(hasSidebar: Bool) {
        let storage = SplitTestStorage<ThreeColumn.State>()
        storage.saved = .init(
            sidebarSelection: hasSidebar ? "inbox" : nil,
            contentSelection: hasSidebar ? nil : 7,
            detailPath: [.info(7)]
        )
        let manager = ThreeColumn(storageMode: .custom(FileStorage(storage)))
        #expect(manager.load().succeeded)
        #expect(manager.contentSelection == nil)
        #expect(manager.detailPath.isEmpty)
        #expect(manager.preferredCompactColumn == (hasSidebar ? .content : .sidebar))
    }

    @Test("UI bindings persist selection and interactive detail pops")
    func uiBindings() {
        let storage = SplitTestStorage<ThreeColumn.State>()
        @Bindable
        var manager = ThreeColumn(storageMode: .custom(FileStorage(storage)))
        $manager.sidebarSelection.wrappedValue = "inbox"
        $manager.contentSelection.wrappedValue = 1
        manager.push(to: .info(1), .info(2))
        $manager.detailPath.wrappedValue = [.info(1)]
        #expect(storage.saved == manager.snapshot)
        #expect(storage.saved?.detailPath == [.info(1)])
        $manager.preferredCompactColumn.wrappedValue = .content
        #expect(manager.contentSelection == 1)
        #expect(manager.detailPath == [.info(1)])
    }

    @Test("An initial empty UI path does not erase navigation waiting to be restored")
    func initialPathBindingPreservesStorage() {
        let storage = SplitTestStorage<TwoColumn.State>()
        storage.saved = .init(sidebarSelection: "inbox", detailPath: [.info(1)])
        @Bindable
        var manager = TwoColumn(storageMode: .custom(FileStorage(storage)))
        $manager.detailPath.wrappedValue = []
        #expect(storage.saved?.sidebarSelection == "inbox")
        #expect(manager.load().succeeded)
        #expect(manager.detailPath == [.info(1)])
    }

    @Test("Stale compact-column writes cannot undo a reset or select an orphaned detail")
    func compactColumnAfterReset() {
        @Bindable
        var manager = ThreeColumn()
        manager.navigate(to: .init(sidebarSelection: "inbox", contentSelection: 1, detailPath: [.info(1)]))
        manager.resetNavigation()
        $manager.preferredCompactColumn.wrappedValue = .content
        #expect(manager.preferredCompactColumn == .sidebar)
        $manager.preferredCompactColumn.wrappedValue = .detail
        #expect(manager.preferredCompactColumn == .sidebar)
        manager.sidebarSelection = "inbox"
        $manager.preferredCompactColumn.wrappedValue = .detail
        #expect(manager.preferredCompactColumn == .content)
    }

    @Test("Column presentation changes do not write persisted navigation")
    func presentationIsTransient() {
        let storage = SplitTestStorage<TwoColumn.State>()
        let manager = TwoColumn(storageMode: .custom(FileStorage(storage)))
        manager.sidebarSelection = "inbox"
        manager.columnVisibility = .detailOnly
        manager.preferredCompactColumn = .sidebar
        #expect(storage.saveCount == 1)
        #expect(manager.sidebarSelection == "inbox")
    }

    @Test("A save failure retains in-memory navigation and reports the error")
    func saveFailure() {
        let storage = SplitTestStorage<TwoColumn.State>()
        storage.saveError = SplitStorageError.failed
        let manager = TwoColumn(storageMode: .custom(FileStorage(storage)))
        let result = manager.selectSidebar("inbox")
        guard case .failure(.save) = result else {
            Issue.record("Expected a save error")
            return
        }
        #expect(manager.sidebarSelection == "inbox")
        guard case .failure(.save) = manager.lastResult else {
            Issue.record("Expected lastResult to retain the save error")
            return
        }
    }

    @Test("Missing or failing storage preserves the current navigation on load")
    func loadFailure() {
        let storage = SplitTestStorage<TwoColumn.State>()
        let manager = TwoColumn(storageMode: .custom(FileStorage(storage)))
        manager.sidebarSelection = "inbox"
        storage.saved = nil
        #expect(manager.load().succeeded)
        #expect(manager.sidebarSelection == "inbox")
        storage.loadError = SplitStorageError.failed
        guard case .failure(.load) = manager.load() else {
            Issue.record("Expected a load error")
            return
        }
        #expect(manager.sidebarSelection == "inbox")
        storage.loadError = NavigationError.pathNotFound
        #expect(manager.load().isMissingPath)
    }

    @Test("Deleting navigation reports deletion failures")
    func deleteFailure() {
        let storage = SplitTestStorage<TwoColumn.State>()
        let manager = TwoColumn(storageMode: .custom(FileStorage(storage)))
        manager.sidebarSelection = "inbox"
        storage.deleteError = SplitStorageError.failed
        guard case .failure(.delete) = manager.delete() else {
            Issue.record("Expected a deletion error")
            return
        }
        #expect(manager.sidebarSelection == nil)
        #expect(storage.saved?.sidebarSelection == "inbox")
    }

    @Test("Independent managers do not share navigation or memory storage")
    func independentScenes() {
        let first = TwoColumn()
        let second = TwoColumn()
        first.sidebarSelection = "inbox"
        #expect(second.load().succeeded)
        second.sidebarSelection = "archive"
        #expect(first.load().succeeded)
        #expect(first.sidebarSelection == "inbox")
        #expect(second.sidebarSelection == "archive")
    }

    @Test("Both column counts infer default and custom destination view types")
    func publicWrapperInitializers() {
        let two = TwoColumn()
        let three = ThreeColumn()
        let twoDefault = NavigationSplitWrapper(manager: two) {
            Text("Sidebar")
        } detail: {
            Text("Detail")
        }
        let twoCustom = NavigationSplitWrapper(manager: two) {
            Text("Sidebar")
        } detail: {
            Text("Detail")
        } destination: { route in
            route.body.padding()
        }
        let threeDefault = NavigationSplitWrapper(manager: three) {
            Text("Sidebar")
        } content: {
            Text("Content")
        } detail: {
            Text("Detail")
        }
        let threeCustom = NavigationSplitWrapper(manager: three) {
            Text("Sidebar")
        } content: {
            Text("Content")
        } detail: {
            Text("Detail")
        } destination: { route in
            route.body.padding()
        }
        // Evaluate each body as a smoke check; actual navigation interaction needs a hosted UI.
        _ = twoDefault.body
        _ = twoCustom.body
        _ = threeDefault.body
        _ = threeCustom.body
    }
}

private enum SplitRoute: NavigationRouteRepresentable {
    case info(Int)
    var body: some View { Text("Info") }
}

private final class SplitTestStorage<T: Codable>: FileStorageRepresentable {
    var saved: T?
    var saveCount = 0
    var saveError: (any Error)?
    var loadError: (any Error)?
    var deleteError: (any Error)?

    func save(_ object: T) throws {
        if let saveError { throw saveError }
        saved = object
        saveCount += 1
    }

    func load() throws -> T? {
        if let loadError { throw loadError }
        return saved
    }

    func delete() throws {
        if let deleteError { throw deleteError }
        saved = nil
    }
}

private enum SplitStorageError: Error { case failed }

extension NavigationResult {
    fileprivate var succeeded: Bool {
        if case .success = self { return true }
        return false
    }

    fileprivate var isMissingPath: Bool {
        if case .failure(.pathNotFound) = self { return true }
        return false
    }
}
