//
// Project: RoutingManager
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import Foundation
import SwiftUI
import Testing

@testable import RoutingManager

@Suite("NavigationManager", .serialized)
@MainActor
struct NavigationManagerTests {
    @Test("Push appends routes and records success")
    func pushAppendsRoutesAndRecordsSuccess() {
        let manager = makeManager()

        let result = manager.push(to: .home, .details(id: 1))

        #expect(result.isSuccess)
        #expect(manager.lastResult.isSuccess)
        #expect(manager.listRoutes()[.main] == [.home, .details(id: 1)])
    }

    @Test("Go back removes the requested number of routes")
    func goBackRemovesRequestedRoutes() {
        let manager = makeManager()
        manager.push(to: .home, .settings, .details(id: 1))

        let result = manager.goBack(2)

        #expect(result.isSuccess)
        #expect(manager.listRoutes()[.main] == [.home])
    }

    @Test("Go back beyond stack removes the stack without trapping")
    func goBackBeyondStackRemovesStack() {
        let manager = makeManager()
        manager.push(to: .home)

        let result = manager.goBack(5)

        #expect(result.isSuccess)
        #expect(manager.listRoutes()[.main] == nil)
    }

    @Test("Non-positive goBack requests are safe no-ops")
    func nonPositiveGoBackRequestsAreSafeNoOps() {
        let manager = makeManager()
        manager.push(to: .home, .settings)

        #expect(manager.goBack(0).isSuccess)
        #expect(manager.goBack(-1).isSuccess)
        #expect(manager.listRoutes()[.main] == [.home, .settings])
    }

    @Test("Go to occurrence trims to the requested matching route")
    func goToOccurrenceTrimsToRequestedRoute() {
        let manager = makeManager()
        manager.push(to: .home, .settings, .home, .details(id: 2))

        let result = manager.goToOccurrence(of: .home, direction: .last)

        #expect(result.isSuccess)
        #expect(manager.listRoutes()[.main] == [.home, .settings, .home])
    }

    @Test("Missing occurrence records path not found")
    func missingOccurrenceRecordsPathNotFound() {
        let manager = makeManager()
        manager.push(to: .home)

        let result = manager.goToOccurrence(of: .settings, direction: .first)

        #expect(result.isPathNotFound)
        #expect(manager.lastResult.isPathNotFound)
        #expect(manager.listRoutes()[.main] == [.home])
    }

    @Test("Replace current screen updates the final route")
    func replaceCurrentScreenUpdatesFinalRoute() {
        let manager = makeManager()
        manager.push(to: .home, .settings)

        let result = manager.replaceCurrentScreen(with: .details(id: 3))

        #expect(result.isSuccess)
        #expect(manager.listRoutes()[.main] == [.home, .details(id: 3)])
    }

    @Test("Replace current screen fails on an empty stack")
    func replaceCurrentScreenFailsOnEmptyStack() {
        let manager = makeManager()

        let result = manager.replaceCurrentScreen(with: .home)

        #expect(result.isPathNotFound)
        #expect(manager.lastResult.isPathNotFound)
    }

    @Test("Reset removes the current stack")
    func resetRemovesCurrentStack() {
        let manager = makeManager()
        manager.push(to: .home, .settings)

        let result = manager.resetNavigation()

        #expect(result.isSuccess)
        #expect(manager.listRoutes()[.main] == nil)
    }

    @Test("Custom storage can save and load routes")
    func customStorageCanSaveAndLoadRoutes() {
        let storage = InMemoryTestStorage<[TestStack: [TestRoute]]>()
        let savingManager = makeManager(storage: storage)
        savingManager.push(to: .home, .details(id: 9))

        let loadingManager = makeManager(storage: storage)
        let result = loadingManager.load()

        #expect(result.isSuccess)
        #expect(loadingManager.listRoutes()[.main] == [.home, .details(id: 9)])
    }

    @Test("Load preserves navigation errors thrown by storage")
    func loadPreservesNavigationErrorsThrownByStorage() {
        let storage = InMemoryTestStorage<[TestStack: [TestRoute]]>()
        storage.loadError = NavigationError.load(TestStorageError.loadFailed)
        let manager = makeManager(storage: storage)

        let result = manager.load()

        #expect(result.isLoadFailure)
        #expect(manager.lastResult.isLoadFailure)
    }

    @Test("Delete failure is reported as delete failure")
    func deleteFailureIsReportedAsDeleteFailure() {
        let storage = InMemoryTestStorage<[TestStack: [TestRoute]]>()
        storage.deleteError = TestStorageError.deleteFailed
        let manager = makeManager(storage: storage)
        manager.push(to: .home)

        let result = manager.delete()

        #expect(result.isDeleteFailure)
        #expect(manager.lastResult.isDeleteFailure)
    }

    @Test("Empty push is a no-op and does not persist an empty stack")
    func emptyPushDoesNotCreateStack() {
        let storage = InMemoryTestStorage<[TestStack: [TestRoute]]>()
        let manager = makeManager(storage: storage)

        let result = manager.push()

        #expect(result.isSuccess)
        #expect(manager.listRoutes().isEmpty)
        #expect(storage.savedObject == nil)
    }

    @Test("Save failures are reported while preserving the new in-memory route")
    func saveFailurePreservesInMemoryState() {
        let storage = InMemoryTestStorage<[TestStack: [TestRoute]]>()
        storage.saveError = TestStorageError.saveFailed
        let manager = makeManager(storage: storage)

        let result = manager.push(to: .home)

        #expect(result.error?.isSaveFailure == true)
        #expect(manager.listRoutes()[.main] == [.home])
        #expect(storage.savedObject == nil)
    }

    @Test("Missing persisted state is a successful no-op")
    func missingPersistedStateIsSuccessfulNoOp() {
        let manager = makeManager()
        manager.push(to: .home)

        #expect(manager.load().isSuccess)
        #expect(manager.listRoutes()[.main] == [.home])
    }

    @Test("Public replacement APIs update one stack or the complete state")
    func publicReplacementAPIs() {
        let manager = makeManager()

        #expect(manager.replaceCurrentStack(with: [.home]).isSuccess)
        #expect(manager.replace(stack: .secondary, with: [.settings]).isSuccess)
        #expect(manager.listRoutes()[.secondary] == [.settings])
        #expect(manager.override(navigation: [.main: [.details(id: 4)]]).isSuccess)
        #expect(manager.listRoutes() == [.main: [.details(id: 4)]])
    }

    @Test("Occurrence lookup uses route equality even when identifiers collide")
    func occurrenceLookupUsesRouteEquality() {
        let manager = NavigationManager<TestStack, CollidingRoute>(for: .main)
        manager.push(to: .item(1), .item(2), .item(1), .item(3))

        #expect(manager.goToOccurrence(of: .item(2), direction: .first).isSuccess)
        #expect(manager.listRoutes()[.main] == [.item(1), .item(2)])
    }

    @Test("Named JSON stores keep independent managers isolated")
    func namedJSONStoresAreIsolated() throws {
        let directoryURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("RoutingManagerTests-\(UUID().uuidString)", isDirectory: true)
        defer { try? FileManager.default.removeItem(at: directoryURL) }

        let mainStorage = FileStorage(
            JSONFileStorage<[TestStack: [TestRoute]]>(
                fileName: "main.json",
                directoryURL: directoryURL
            )
        )
        let secondaryStorage = FileStorage(
            JSONFileStorage<[TestStack: [TestRoute]]>(
                fileName: "secondary.json",
                directoryURL: directoryURL
            )
        )
        let main = NavigationManager<TestStack, TestRoute>(
            for: .main,
            storageMode: .custom(mainStorage)
        )
        let secondary = NavigationManager<TestStack, TestRoute>(
            for: .secondary,
            storageMode: .custom(secondaryStorage)
        )
        main.push(to: .home)
        secondary.push(to: .settings)

        let restoredMain = NavigationManager<TestStack, TestRoute>(
            for: .main,
            storageMode: .custom(mainStorage)
        )
        let restoredSecondary = NavigationManager<TestStack, TestRoute>(
            for: .secondary,
            storageMode: .custom(secondaryStorage)
        )

        #expect(restoredMain.load().isSuccess)
        #expect(restoredSecondary.load().isSuccess)
        #expect(restoredMain.listRoutes() == [.main: [.home]])
        #expect(restoredSecondary.listRoutes() == [.secondary: [.settings]])
    }

    @Test("Corrupt JSON is reported as a load failure without replacing current state")
    func corruptJSONPreservesCurrentState() throws {
        let directoryURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("RoutingManagerTests-\(UUID().uuidString)", isDirectory: true)
        let fileURL = directoryURL.appendingPathComponent("corrupt.json")
        defer { try? FileManager.default.removeItem(at: directoryURL) }

        let storage = FileStorage(
            JSONFileStorage<[TestStack: [TestRoute]]>(
                fileName: "corrupt.json",
                directoryURL: directoryURL
            )
        )
        let manager = NavigationManager<TestStack, TestRoute>(
            for: .main,
            storageMode: .custom(storage)
        )
        manager.push(to: .home)
        try Data("{not-json".utf8).write(to: fileURL)

        #expect(manager.load().error?.isLoadFailure == true)
        #expect(manager.listRoutes()[.main] == [.home])
    }

    private func makeManager(
        storage: InMemoryTestStorage<[TestStack: [TestRoute]]>? = nil
    ) -> NavigationManager<TestStack, TestRoute> {
        if let storage {
            return NavigationManager(
                for: .main,
                storageMode: .custom(FileStorage(storage))
            )
        }

        return NavigationManager(for: .main)
    }
}

private enum TestStack: String, NavigationStackRepresentable {
    case main
    case secondary
}

private enum TestRoute: Hashable, NavigationRouteRepresentable {
    case home
    case settings
    case details(id: Int)

    @MainActor
    @ViewBuilder
    var body: some View {
        EmptyView()
    }
}

private enum CollidingRoute: Hashable, NavigationRouteRepresentable {
    case item(Int)

    var id: String { "shared-id" }

    @MainActor
    @ViewBuilder
    var body: some View {
        EmptyView()
    }
}

private final class InMemoryTestStorage<T: Codable>: FileStorageRepresentable {
    var savedObject: T?
    var saveError: (any Error)?
    var loadError: (any Error)?
    var deleteError: (any Error)?

    func save(_ object: T) throws {
        if let saveError {
            throw saveError
        }
        savedObject = object
    }

    func load() throws -> T? {
        if let loadError {
            throw loadError
        }
        return savedObject
    }

    func delete() throws {
        if let deleteError {
            throw deleteError
        }
        savedObject = nil
    }
}

private enum TestStorageError: Error {
    case saveFailed
    case loadFailed
    case deleteFailed
}

extension NavigationError {
    fileprivate var isSaveFailure: Bool {
        if case .save = self { return true }
        return false
    }

    fileprivate var isLoadFailure: Bool {
        if case .load = self { return true }
        return false
    }
}

extension NavigationResult {
    fileprivate var isSuccess: Bool {
        if case .success = self {
            return true
        }
        return false
    }

    fileprivate var isPathNotFound: Bool {
        guard case .failure(.pathNotFound) = self else {
            return false
        }
        return true
    }

    fileprivate var isLoadFailure: Bool {
        guard case .failure(.load) = self else {
            return false
        }
        return true
    }

    fileprivate var isDeleteFailure: Bool {
        guard case .failure(.delete) = self else {
            return false
        }
        return true
    }
}
