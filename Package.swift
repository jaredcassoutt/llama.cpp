// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "llama",
    platforms: [
        .macOS(.v12),
        .iOS(.v14),
        .watchOS(.v4),
        .tvOS(.v14),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "llama",
            targets: ["llama"]
        ),
    ],
    targets: [
        .binaryTarget(
            name: "llama",
            url: "https://github.com/ggml-org/llama.cpp/releases/download/b5689/llama-b5689-xcframework.zip",
            checksum: "593fff39ea2250ffe3ff5ac1c06d8aa8655a80d190a3fb8adc42d64d75affa25"
        )
    ]
) 