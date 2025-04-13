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
    dependencies: [
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "5.0.0")
    ],
    targets: [
        .target(
            name: "CaminoModels",
            dependencies: ["SwiftyJSON"],
            path: "Sources/CaminoModels",
            publicHeadersPath: "include"),
        .testTarget(
            name: "CaminoModelsTests",
            dependencies: ["CaminoModels"]),
    ]
) 