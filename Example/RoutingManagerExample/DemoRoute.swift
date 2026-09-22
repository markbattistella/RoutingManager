//
// Project: RoutingManager
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import RoutingManager
import SwiftUI

enum DemoRoute: NavigationRouteRepresentable {
    case details(Int)
    case history(Int)

    var documentID: Int {
        switch self {
            case .details(let id), .history(let id): id
        }
    }

    var title: String {
        switch self {
            case .details: "Document details"
            case .history: "Document history"
        }
    }

    var body: some View {
        List {
            LabeledContent("Document ID", value: documentID.formatted())
            Text("This destination is provided by the route’s body.")
        }
        .navigationTitle(title)
    }
}
