// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Camino",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
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
                .product(name: "CaminoModels", package: "CaminoModels")
            ]),
        .target(
            name: "CaminoContents",
            dependencies: [
                .product(name: "CaminoModels", package: "CaminoModels")
            ],
            path: "CaminoContents/Sources"),
        .testTarget(
            name: "CaminoTests",
            dependencies: ["Camino"])
    ]
) 