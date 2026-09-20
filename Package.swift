// swift-tools-version: 6.4
import PackageDescription

let package = Package(
    name: "MemoryRestartBar",
    platforms: [
        .macOS(.v27)
    ],
    products: [
        .executable(name: "MemoryRestartBar", targets: ["MemoryRestartBar"])
    ],
    targets: [
        .executableTarget(
            name: "MemoryRestartBar",
            path: "Sources/MemoryRestartBar"
        ),
        .testTarget(
            name: "MemoryRestartBarTests",
            dependencies: ["MemoryRestartBar"],
            path: "Tests/MemoryRestartBarTests"
        )
    ]
)
