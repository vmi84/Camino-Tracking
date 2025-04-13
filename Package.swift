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
        .package(name: "CaminoModels", path: "CaminoModels"),
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "5.0.0")
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
                .product(name: "CaminoModels", package: "CaminoModels"),
                "SwiftyJSON"
            ],
            path: "CaminoContents"),
        .testTarget(
            name: "CaminoTests",
            dependencies: ["Camino"])
    ]
) 