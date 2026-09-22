//
// Project: RoutingManager
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import RoutingManager
import SwiftUI

struct ThreeColumnExample: View {
    // The sidebar selects a folder; the middle column selects a document ID.
    @State
    private var navigation = NavigationSplitManager<DemoFolder, Int, DemoRoute>()

    var body: some View {
        @Bindable
        var navigation = navigation

        NavigationSplitWrapper(manager: navigation) {
            List(selection: $navigation.sidebarSelection) {
                Section("Folders") {
                    ForEach(DemoFolder.allCases) { folder in
                        NavigationLink(value: folder) {
                            Label(folder.title, systemImage: folder.systemImage)
                        }
                    }
                }
                Section("Programmatic navigation") {
                    Button("Open archived document") {
                        navigation.navigate(
                            to: .init(
                                sidebarSelection: .archive,
                                contentSelection: 3,
                                detailPath: [.history(3)]
                            )
                        )
                    }
                }
            }
            .navigationTitle("Three columns")
        } content: {
            List(navigation.sidebarSelection?.documents ?? [], selection: $navigation.contentSelection) { document in
                NavigationLink(document.title, value: document.id)
            }
            .overlay {
                if navigation.sidebarSelection == nil {
                    ContentUnavailableView("Select a folder", systemImage: "folder")
                }
            }
            .navigationTitle(navigation.sidebarSelection?.title ?? "Documents")
        } detail: {
            if let id = navigation.contentSelection {
                List {
                    Section("Document") {
                        LabeledContent("Document ID", value: id.formatted())
                        NavigationLink("Open details", value: DemoRoute.details(id))
                        Button("Push history") { navigation.push(to: .history(id)) }
                    }
                    Section("Selection") {
                        Button("Clear document selection") { navigation.selectContent(nil) }
                    }
                    SplitNavigationControls<Int>()
                }
                .navigationTitle("Document")
            }
            else {
                ContentUnavailableView(
                    "Select a document",
                    systemImage: "doc",
                    description: Text("Choose a document from the list.")
                )
            }
        } destination: { route in
            SplitDestination<Int>(route: route)
        }
        .navigationSplitViewStyle(.balanced)
    }
}
