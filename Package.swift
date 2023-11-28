// swift-tools-version:5.8

import PackageDescription

let package = Package(
    name: "FuturedKit",
    platforms: [
        .iOS(.v16),
        .macOS(.v10_15),
        .watchOS(.v9),
        .tvOS(.v16)
    ],
    products: [
        .library(
            name: "FuturedKitArchitecture",
            targets: ["FuturedKitArchitecture"]
        ),
        .library(
            name: "FuturedKitHelpers",
            targets: ["FuturedKitHelpers"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/mkj-is/BindingKit", from: "1.0.0"),
        .package(url: "https://github.com/JohnSundell/CollectionConcurrencyKit", from: "0.1.0")
    ],
    targets: [
        .target(
            name: "FuturedKitArchitecture"
        ),
        .target(
            name: "FuturedKitHelpers",
            dependencies: [
                "FuturedKitArchitecture",
                .product(name: "BindingKit", package: "BindingKit"),
                .product(name: "CollectionConcurrencyKit", package: "CollectionConcurrencyKit")
            ]
        ),
        .testTarget(
            name: "FuturedKitTests",
            dependencies: ["FuturedKitArchitecture", "FuturedKitHelpers"]
        )
    ]
)
