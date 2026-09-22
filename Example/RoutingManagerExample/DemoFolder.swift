//
// Project: RoutingManager
// Author: Mark Battistella
// Website: https://markbattistella.com
//

enum DemoFolder: String, Codable, CaseIterable, Identifiable {
    case inbox
    case archive

    var id: Self { self }

    var title: String {
        switch self {
            case .inbox: "Inbox"
            case .archive: "Archive"
        }
    }

    var systemImage: String {
        switch self {
            case .inbox: "tray"
            case .archive: "archivebox"
        }
    }

    var documents: [DemoDocument] {
        switch self {
            case .inbox: [.init(id: 1, title: "Travel plans"), .init(id: 2, title: "Shopping list")]
            case .archive: [.init(id: 3, title: "Project notes"), .init(id: 4, title: "Reading list")]
        }
    }
}

struct DemoDocument: Identifiable {
    let id: Int
    let title: String
}
