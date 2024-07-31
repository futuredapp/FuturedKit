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
            targets: [
                "FuturedArchitecture",
                "EnumIdentifiersGenerator"
            ]
        ),
        .library(
            name: "FuturedHelpers",
            targets: ["FuturedHelpers"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/mkj-is/BindingKit", from: "1.0.0"),
        .package(url: "https://github.com/JohnSundell/CollectionConcurrencyKit", from: "0.1.0"),
        .package(url: "https://github.com/apple/swift-syntax.git", from: "509.0.0")
    ],
    targets: [
        .target(
            name: "EnumIdentifiersGenerator",
            dependencies: [
                "EnumIdentifiersGeneratorMacro"
            ]
        ),
        .macro(
            name: "EnumIdentifiersGeneratorMacro",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),
        .target(
            name: "FuturedArchitecture"
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
