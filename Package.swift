// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Camino",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    dependencies: [
        .package(path: "CaminoModels")
    ],
    targets: [
        .target(
            name: "Camino",
            dependencies: [.product(name: "Models", package: "CaminoModels")]),
        .testTarget(
            name: "CaminoTests",
            dependencies: ["Camino"]),
    ]
) 