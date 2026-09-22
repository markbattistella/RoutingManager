//
// Project: RoutingManager
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import RoutingManager
import SwiftUI

struct SplitDestination<ContentSelection: Codable & Hashable>: View {
    @Environment(NavigationSplitManager<DemoFolder, ContentSelection, DemoRoute>.self)
    private var navigation
    let route: DemoRoute

    var body: some View {
        List {
            Section("Current route") {
                LabeledContent("Document ID", value: route.documentID.formatted())
                Button("Push history") { navigation.push(to: .history(route.documentID)) }
                Button("Replace with details") { navigation.replaceCurrentScreen(with: .details(route.documentID)) }
            }
            SplitNavigationControls<ContentSelection>()
        }
        .navigationTitle(route.title)
    }
}
