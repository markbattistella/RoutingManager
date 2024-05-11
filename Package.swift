// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "RoutingManager",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "RoutingManager",
            targets: ["RoutingManager"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "RoutingManager",
            dependencies: [],
            exclude: []
        )
    ]
)
