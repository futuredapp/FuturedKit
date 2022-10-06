// swift-tools-version:5.6

import PackageDescription

let package = Package(
    name: "FuturedKit",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .watchOS(.v6),
        .tvOS(.v13)
    ],
    products: [
        .library(
            name: "FuturedKit",
            targets: ["FuturedKit"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/mkj-is/BindingKit", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "FuturedKit",
            dependencies: [
                .product(name: "BindingKit", package: "BindingKit")
            ]
        ),
        .testTarget(
            name: "FuturedKitTests",
            dependencies: ["FuturedKit"]
        )
    ]
)
