//
// Project: RoutingManager
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import SwiftUI

struct ContentView: View {
    private enum Tab: Hashable {
        case stack, twoColumns, threeColumns
    }

    @State
    private var selection = Tab.stack

    var body: some View {
        TabView(selection: $selection) {
            StackExample()
                .tabItem { Label("Stack", systemImage: "square.stack") }
                .tag(Tab.stack)
            TwoColumnExample()
                .tabItem { Label("Two columns", systemImage: "rectangle.split.2x1") }
                .tag(Tab.twoColumns)
            ThreeColumnExample()
                .tabItem { Label("Three columns", systemImage: "rectangle.split.3x1") }
                .tag(Tab.threeColumns)
        }
    }
}

#Preview {
    ContentView()
}
