// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "RoutingManager",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .macCatalyst(.v17),
        .tvOS(.v17),
        .watchOS(.v10),
        .visionOS(.v1)
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
            exclude: [],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        )
    ]
)
