// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "PostureMonitor",
    platforms: [.macOS(.v12)],
    targets: [
        .executableTarget(
            name: "posture-monitor",
            path: "Sources/PostureMonitor",
            linkerSettings: [
                .linkedFramework("CoreMotion"),
                .linkedFramework("AppKit")
            ]
        )
    ]
)
