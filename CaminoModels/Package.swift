// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CaminoModels",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "CaminoModels",
            targets: ["CaminoModels"]),
    ],
    targets: [
        .target(
            name: "CaminoModels",
            dependencies: [],
            path: "Sources/CaminoModels"),
        .testTarget(
            name: "CaminoModelsTests",
            dependencies: ["CaminoModels"]),
    ]
) 