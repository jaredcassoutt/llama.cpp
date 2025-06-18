// swift-tools-version: 5.10
// Debugging example for model loading crashes

import PackageDescription

let package = Package(
    name: "DebugModelLoading",
    platforms: [
        .macOS(.v12),
        .iOS(.v14)
    ],
    products: [
        .executable(name: "DebugModelLoading", targets: ["DebugModelLoading"]),
    ],
    dependencies: [
        .package(path: "../..")
    ],
    targets: [
        .executableTarget(
            name: "DebugModelLoading",
            dependencies: [
                .product(name: "llama", package: "llama.cpp")
            ]
        )
    ]
) 