// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Camino",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "CaminoContents",
            targets: ["CaminoContents"]),
    ],
    dependencies: [
        .package(name: "CaminoModels", path: "CaminoModels")
    ],
    targets: [
        .target(
            name: "Camino",
            dependencies: [
                .product(name: "Models", package: "CaminoModels")
            ]),
        .target(
            name: "CaminoContents",
            dependencies: [
                .product(name: "Models", package: "CaminoModels")
            ],
            path: "CaminoContents/Sources"),
        .testTarget(
            name: "CaminoTests",
            dependencies: ["Camino"])
    ]
) 