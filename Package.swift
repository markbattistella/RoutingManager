// swift-tools-version: 6.0

import PackageDescription

let package = Package(
  name: "RoutingManager",
  platforms: [
    .iOS(.v17),
    .macOS(.v14),
    .macCatalyst(.v17),
    .tvOS(.v17),
    .watchOS(.v10),
    .visionOS(.v1),
  ],
  products: [
    .library(
      name: "RoutingManager",
      targets: ["RoutingManager"]
    )
  ],
  dependencies: [
    .package(url: "https://github.com/markbattistella/SimpleLogger", from: "26.0.0")
  ],
  targets: [
    .target(
      name: "RoutingManager",
      dependencies: ["SimpleLogger"],
      swiftSettings: [
        .swiftLanguageMode(.v6)
      ]
    ),
    .testTarget(
      name: "RoutingManagerTests",
      dependencies: ["RoutingManager"],
      swiftSettings: [
        .swiftLanguageMode(.v6)
      ]
    ),
  ],
  swiftLanguageModes: [.v6]
)
