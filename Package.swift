// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "SecureQueryItem",
    platforms: [
      .iOS(.v8), .macOS(.v10_10), .tvOS(.v9), .watchOS(.v2)
    ],
    products: [
        .library(name: "SecureQueryItem", targets: ["SecureQueryItem"]),
    ],
    targets: [
        .target(name: "SecureQueryItem"),
        .testTarget(name: "SecureQueryItemTests", dependencies: ["SecureQueryItem"]),
    ]
)
