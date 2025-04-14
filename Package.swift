// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Camino",
    platforms: [
        .iOS(.v17)
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
        // Swift target for the main package code
        .target(
            name: "CaminoContents",
            dependencies: [
                .product(name: "CaminoModels", package: "CaminoModels"),
                .product(name: "SwiftyJSON", package: "SwiftyJSON")
            ],
            path: "./CaminoContents",
            swiftSettings: [
                .define("DEBUG", .when(configuration: .debug)),
                .define("RELEASE", .when(configuration: .release)),
                .enableUpcomingFeature("BareSlashRegexLiterals"),
                .enableExperimentalFeature("StrictConcurrency")
            ]),
        .testTarget(
            name: "CaminoTests",
            dependencies: ["CaminoContents"],
            path: "./CaminoTests")
    ]
) 