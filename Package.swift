// swift-tools-version:5.9

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "FuturedKit",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
        .watchOS(.v9),
        .tvOS(.v16)
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
        .package(url: "https://github.com/futuredapp/futured-macros", branch: "experiment/data-cache-as-macro")
    ],
    targets: [
        .target(
            name: "FuturedArchitecture",
            dependencies: [
                .product(name: "EnumIdentable", package: "futured-macros"),
                .product(name: "DataCache", package: "futured-macros"),
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
