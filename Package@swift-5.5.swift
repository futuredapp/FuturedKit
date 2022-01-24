// swift-tools-version:5.5
// Required for generation of DocC table of contents.
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
    targets: [
        .target(
            name: "FuturedKit",
            dependencies: []
        ),
        .testTarget(
            name: "FuturedKitTests",
            dependencies: ["FuturedKit"]
        )
    ]
)
