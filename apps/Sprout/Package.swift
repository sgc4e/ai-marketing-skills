// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SproutKit",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "SproutKit", targets: ["SproutKit"])
    ],
    targets: [
        .target(
            name: "SproutKit",
            path: "Sources/SproutKit"
        ),
        .testTarget(
            name: "SproutKitTests",
            dependencies: ["SproutKit"],
            path: "Tests/SproutKitTests"
        )
    ]
)
