// swift-tools-version: 5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "llama-batched-swift",
    platforms: [.macOS(.v12)],
    dependencies: [
        // Option 1: Use your forked llama.cpp with performance optimizations
        .package(url: "https://github.com/yourusername/llama.cpp", revision: "your-commit-hash"),
        
        // Option 2: Use local path to your modified llama.cpp (if working locally)
        // .package(name: "llama", path: "../../"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "llama-batched-swift",
            dependencies: [
                .product(name: "llama", package: "llama.cpp") // Option 1: Remote dependency
                // "llama" // Option 2: Local dependency
            ],
            path: "Sources",
            linkerSettings: [.linkedFramework("Foundation"), .linkedFramework("AppKit")]
        ),
    ]
)
