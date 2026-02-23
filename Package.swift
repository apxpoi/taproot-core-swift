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
        .library(
            name: "TaprootCore",
            targets: ["TaprootCore"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-crypto.git", from: "3.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "TaprootCore",
            dependencies: [
                .product(name: "Crypto", package: "swift-crypto"),
            ]
        ),
        .testTarget(
            name: "TaprootCoreTests",
            dependencies: [
                "TaprootCore",
                .product(name: "Crypto", package: "swift-crypto"),
            ]
        ),
    ]
)
