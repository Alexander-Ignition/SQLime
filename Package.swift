// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let swiftSettings: [SwiftSetting] = [
    .enableUpcomingFeature("ExistentialAny"),
    .enableExperimentalFeature("StrictConcurrency"),
]

let package = Package(
    name: "SQLime",
    platforms: [
        .macOS(.v12),
        .iOS(.v12),
    ],
    products: [
        .library(
            name: "SQLime",
            targets: ["SQLime"]
        )
    ],
    targets: [
        .target(
            name: "SQLime",
            dependencies: [],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "SQLimeTests",
            dependencies: ["SQLime"],
            swiftSettings: swiftSettings
        ),
    ]
)
