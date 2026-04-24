// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TaprootCore",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .executable(
            name: "taproot-core-swift",
            targets: ["taproot-core-swift"]
        ),
        .executable(
            name: "taproot-core-swift-demo",
            targets: ["taproot-core-swift-demo"]
        ),
        .library(
            name: "TaprootCore",
            targets: ["TaprootCore"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-crypto.git", from: "4.5.0"),
        .package(url: "https://github.com/giant-stone/iso3166-swift", from: "2026.3.1"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "taproot-core-swift",
            dependencies: [
                "TaprootCore",
            ]
        ),
        .executableTarget(
            name: "taproot-core-swift-demo",
            dependencies: [
                "TaprootCore",
            ]
        ),
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "TaprootCore",
            dependencies: [
                .product(name: "Crypto", package: "swift-crypto"),
                .product(name: "Iso3166", package: "iso3166-swift"),
            ]
        ),
        .testTarget(
            name: "TaprootCoreTests",
            dependencies: [
                "TaprootCore",
                "taproot-core-swift",
                .product(name: "Crypto", package: "swift-crypto"),
                .product(name: "Iso3166", package: "iso3166-swift"),
            ]
        ),
    ]
)
