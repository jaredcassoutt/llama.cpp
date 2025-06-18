// swift-tools-version: 5.10
// Example showing how to use llama.cpp XCFramework in your Swift package

import PackageDescription

let package = Package(
    name: "LlamaExample",
    platforms: [
        .macOS(.v12),
        .iOS(.v14),
        .watchOS(.v4),
        .tvOS(.v14),
        .visionOS(.v1)
    ],
    products: [
        .executable(name: "LlamaExample", targets: ["LlamaExample"]),
    ],
    dependencies: [
        // Option 1: Use the llama.cpp repository directly
        .package(url: "https://github.com/ggml-org/llama.cpp.git", from: "b5689")
        
        // Option 2: Define the binary target yourself (more control)
        // .package(name: "llama", path: "../YourLocalLlamaPackage")
    ],
    targets: [
        .executableTarget(
            name: "LlamaExample",
            dependencies: [
                .product(name: "llama", package: "llama.cpp")
            ]
        ),
        // Option 2 alternative: define binary target locally
        // .binaryTarget(
        //     name: "llama",
        //     url: "https://github.com/ggml-org/llama.cpp/releases/download/b5689/llama-b5689-xcframework.zip",
        //     checksum: "593fff39ea2250ffe3ff5ac1c06d8aa8655a80d190a3fb8adc42d64d75affa25"
        // )
    ]
) 