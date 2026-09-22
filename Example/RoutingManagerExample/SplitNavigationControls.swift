//
// Project: RoutingManager
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import RoutingManager
import SwiftUI

struct SplitNavigationControls<ContentSelection: Codable & Hashable>: View {
    @Environment(NavigationSplitManager<DemoFolder, ContentSelection, DemoRoute>.self)
    private var navigation

    var body: some View {
        Section("Navigation") {
            Button("Go back one route") { navigation.goBack(1) }
                .disabled(navigation.detailPath.isEmpty)
            Button("Back to detail root") { navigation.resetDetailNavigation() }
                .disabled(navigation.detailPath.isEmpty)
            Button("Switch folder") {
                navigation.selectSidebar(navigation.sidebarSelection == .inbox ? .archive : .inbox)
            }
            Button("Reset navigation") { navigation.resetNavigation() }
        }
        Section("Presentation") {
            Menu("Column visibility") {
                Button("Automatic") { navigation.columnVisibility = .automatic }
                Button("All columns") { navigation.columnVisibility = .all }
                Button("Detail only") { navigation.columnVisibility = .detailOnly }
            }
            Button("Show folders in compact layout") {
                navigation.resetDetailNavigation()
                navigation.preferredCompactColumn = .sidebar
            }
        }
        Section {
            LabeledContent("Folder", value: navigation.sidebarSelection?.title ?? "None")
            LabeledContent("Pushed routes", value: navigation.detailPath.count.formatted())
        } header: {
            Text("Navigation state")
        } footer: {
            Text("Selections and routes are saved in memory. Changing a parent selection clears its child navigation.")
        }
    }
}
