// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CaminoModels",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "Models",
            targets: ["Models"]),
    ],
    targets: [
        .target(
            name: "Models",
            dependencies: [],
            path: "Sources/Models"),
        .testTarget(
            name: "ModelsTests",
            dependencies: ["Models"]),
    ]
) 