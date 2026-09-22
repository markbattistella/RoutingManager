//
// Project: RoutingManager
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import RoutingManager
import SwiftUI

enum DemoStack: String, NavigationStackRepresentable {
    case main
}

struct StackExample: View {
    var body: some View {
        NavigationWrapper(stack: DemoStack.main, for: DemoRoute.self) {
            StackRoot()
        } environmentInjection: { route in
            StackDestination(route: route)
        }
    }
}

private struct StackRoot: View {
    @Environment(NavigationManager<DemoStack, DemoRoute>.self)
    private var navigation

    var body: some View {
        List {
            Section {
                Text("Open a document with a value-based link, or push several routes together.")
            }
            Section("Documents") {
                ForEach(DemoFolder.inbox.documents) { document in
                    NavigationLink(document.title, value: DemoRoute.details(document.id))
                }
            }
            Section("Programmatic navigation") {
                Button("Open details and history") {
                    navigation.push(to: .details(1), .history(1))
                }
            }
            Section("Storage") {
                Text("This example uses memory storage. Each window owns an independent navigation session.")
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Stack navigation")
    }
}

private struct StackDestination: View {
    @Environment(NavigationManager<DemoStack, DemoRoute>.self)
    private var navigation
    let route: DemoRoute

    var body: some View {
        List {
            Section("Current route") {
                LabeledContent("Document ID", value: route.documentID.formatted())
                LabeledContent("Pushed routes", value: (navigation.listRoutes()[.main]?.count ?? 0).formatted())
            }
            Section("Actions") {
                Button("Push history") { navigation.push(to: .history(route.documentID)) }
                Button("Replace with details") { navigation.replaceCurrentScreen(with: .details(route.documentID)) }
                Button("Go back") { navigation.goBack(1) }
                Button("Back to root") { navigation.resetNavigation() }
            }
        }
        .navigationTitle(route.title)
    }
}
