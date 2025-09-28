// swift-tools-version:5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PeakOperation",
    platforms: [.macOS(.v14),
                .iOS(.v12)],
    products: [
        .library(name: "PeakOperation",
                 targets: ["PeakOperation"]),
    ],
    targets: [
        .target(name: "PeakOperation",),
        .testTarget(name: "PeakOperationTests",
                    dependencies: ["PeakOperation"]),
    ]
)
