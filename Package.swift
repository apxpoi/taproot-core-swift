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
            name: "taproot-core-cli",
            targets: ["taproot-core-cli"]
        ),
        .library(
            name: "TaprootCore",
            targets: ["TaprootCore"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-crypto.git", from: "3.0.0"),
        .package(path: "../../giant-stone/iso3166-swift"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "taproot-core-cli",
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
                .product(name: "Crypto", package: "swift-crypto"),
                .product(name: "Iso3166", package: "iso3166-swift"),
            ]
        ),
    ]
)
