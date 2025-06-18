# Using llama.cpp XCFramework with Swift Package Manager

As of February 21, 2025, llama.cpp has moved to distributing precompiled XCFrameworks instead of source code through Swift Package Manager. This change eliminates the need to compile C/C++ sources locally while maintaining compatibility with Swift projects.

## What Changed

- **Removed**: `Package.swift` with source compilation
- **Removed**: `Sources/` directory with C/C++ source files  
- **Removed**: `spm-headers/` directory with SPM-specific headers
- **Added**: Precompiled XCFramework distributions via GitHub releases

## Using the XCFramework

### Option 1: Direct Dependency

Add this to your `Package.swift`:

```swift
// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "YourPackage",
    platforms: [
        .macOS(.v12),
        .iOS(.v14),
        .watchOS(.v4), 
        .tvOS(.v14),
        .visionOS(.v1)
    ],
    products: [
        .library(name: "YourPackage", targets: ["YourPackage"]),
    ],
    dependencies: [
        .package(url: "https://github.com/ggml-org/llama.cpp.git", from: "b5689")
    ],
    targets: [
        .target(
            name: "YourPackage",
            dependencies: [
                .product(name: "llama", package: "llama.cpp")
            ]
        )
    ]
)
```

### Option 2: Binary Target (Recommended)

For more control, define the binary target directly:

```swift
// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "YourPackage", 
    platforms: [
        .macOS(.v12),
        .iOS(.v14),
        .watchOS(.v4),
        .tvOS(.v14),
        .visionOS(.v1)
    ],
    products: [
        .library(name: "YourPackage", targets: ["YourPackage"]),
    ],
    targets: [
        .target(
            name: "YourPackage",
            dependencies: ["llama"]
        ),
        .binaryTarget(
            name: "llama",
            url: "https://github.com/ggml-org/llama.cpp/releases/download/b5689/llama-b5689-xcframework.zip",
            checksum: "593fff39ea2250ffe3ff5ac1c06d8aa8655a80d190a3fb8adc42d64d75affa25"
        )
    ]
)
```

## Updating to New Releases

To update to a newer version:

1. Check [latest releases](https://github.com/ggml-org/llama.cpp/releases)
2. Find the `llama-{version}-xcframework.zip` asset
3. Update the URL and checksum in your `Package.swift`

Example for a hypothetical version `b5700`:
```swift
.binaryTarget(
    name: "llama",
    url: "https://github.com/ggml-org/llama.cpp/releases/download/b5700/llama-b5700-xcframework.zip",
    checksum: "NEW_CHECKSUM_HERE"
)
```

## Getting the Checksum

You can find the checksum in the GitHub release page, or calculate it yourself:

```bash
curl -L -o framework.zip "https://github.com/ggml-org/llama.cpp/releases/download/b5689/llama-b5689-xcframework.zip"
swift package compute-checksum framework.zip
```

## Supported Platforms

The XCFramework includes binaries for:
- macOS (Intel and Apple Silicon)
- iOS (device and simulator)
- tvOS (device and simulator)  
- watchOS (device and simulator)
- visionOS (device and simulator)

## Usage in Swift Code

```swift
import llama

// Your llama.cpp code here - same API as before
// The framework provides the same C API, just precompiled
```

## Benefits of XCFramework Approach

- ✅ **Faster builds**: No C++ compilation required
- ✅ **Smaller Xcode projects**: No source files to index
- ✅ **Consistent builds**: Same binary across all environments
- ✅ **Better CI/CD**: Predictable build times
- ✅ **Multiple architectures**: Single framework supports all Apple platforms

## Migration from Source-Based SPM

If you were previously using the source-based Package.swift:

1. Update your dependency to use the new binary target approach
2. No code changes required - the C API remains the same
3. Clean your build folder to remove old compiled artifacts
4. Rebuild your project

## Troubleshooting

### "Binary target does not contain a binary artifact"

This error typically means:
- Wrong URL or checksum in Package.swift
- Network issues downloading the XCFramework
- Corrupted download cache

**Solution**: Clear SPM cache and retry:
```bash
rm -rf ~/Library/Caches/org.swift.swiftpm/
rm -rf ~/Library/Developer/Xcode/DerivedData/
```

### Version Compatibility

- Use XCFramework releases from `b5689` onwards
- Older releases may not include XCFramework assets
- Check the release assets list for `llama-{version}-xcframework.zip`

## Contributing

The XCFramework is built automatically from the main branch. For issues:
- XCFramework-specific problems: [llama.cpp issues](https://github.com/ggml-org/llama.cpp/issues)
- Swift integration help: [llama.cpp discussions](https://github.com/ggml-org/llama.cpp/discussions) 