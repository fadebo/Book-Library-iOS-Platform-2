// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ReviewGenerator",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "ReviewGenerator",
            targets: ["ReviewGenerator"]),
    ],
    targets: [
        .target(
            name: "ReviewGenerator",
            dependencies: []),
        .testTarget(
            name: "ReviewGeneratorTests",
            dependencies: ["ReviewGenerator"]),
    ]
)
