// swift-tools-version: 6.2

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "FuturedKit",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .watchOS(.v10),
        .tvOS(.v17)
    ],
    products: [
        .library(
            name: "FuturedArchitecture",
            targets: ["FuturedArchitecture"]
        ),
        .library(
            name: "FuturedHelpers",
            targets: ["FuturedHelpers"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/mkj-is/BindingKit", from: "1.0.0"),
        .package(url: "https://github.com/JohnSundell/CollectionConcurrencyKit", from: "0.1.0"),
        .package(url: "https://github.com/futuredapp/futured-macros", from: "0.1.0")
    ],
    targets: [
        .target(
            name: "FuturedArchitecture",
            dependencies: [
                .product(name: "FuturedMacros", package: "futured-macros")
            ]
        ),
        .target(
            name: "FuturedHelpers",
            dependencies: [
                "FuturedArchitecture",
                .product(name: "BindingKit", package: "BindingKit"),
                .product(name: "CollectionConcurrencyKit", package: "CollectionConcurrencyKit")
            ]
        ),
        .testTarget(
            name: "FuturedKitTests",
            dependencies: ["FuturedArchitecture", "FuturedHelpers"]
        )
    ]
)
