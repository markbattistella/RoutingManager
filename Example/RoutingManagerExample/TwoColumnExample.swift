//
// Project: RoutingManager
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import RoutingManager
import SwiftUI

struct TwoColumnExample: View {
    // Never means there is no middle-column selection.
    @State
    private var navigation = NavigationSplitManager<DemoFolder, Never, DemoRoute>()

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
                        navigation.navigate(to: .init(sidebarSelection: .archive, detailPath: [.details(3)]))
                    }
                }
            }
            .navigationTitle("Two columns")
        } detail: {
            if let folder = navigation.sidebarSelection {
                List {
                    Section("Documents") {
                        ForEach(folder.documents) { document in
                            NavigationLink(document.title, value: DemoRoute.details(document.id))
                        }
                    }
                    SplitNavigationControls<Never>()
                }
                .navigationTitle(folder.title)
            }
            else {
                ContentUnavailableView(
                    "Select a folder",
                    systemImage: "folder",
                    description: Text("Choose Inbox or Archive.")
                )
            }
        } destination: { route in
            SplitDestination<Never>(route: route)
        }
    }
}
