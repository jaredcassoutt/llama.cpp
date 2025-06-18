#!/bin/bash

# Update llama.cpp XCFramework to Latest Release
# This script fetches the latest release info and updates Package.swift

set -e

echo "🔍 Fetching latest llama.cpp release info..."

# Get latest release info from GitHub API
LATEST_RELEASE=$(curl -s "https://api.github.com/repos/ggml-org/llama.cpp/releases/latest")

# Extract tag name and XCFramework asset info
TAG_NAME=$(echo "$LATEST_RELEASE" | grep '"tag_name":' | sed -E 's/.*"tag_name": "([^"]*)",?/\1/')
XCFRAMEWORK_ASSET=$(echo "$LATEST_RELEASE" | jq -r '.assets[] | select(.name | endswith("-xcframework.zip")) | {name, browser_download_url, digest}')

if [ -z "$XCFRAMEWORK_ASSET" ] || [ "$XCFRAMEWORK_ASSET" = "null" ]; then
    echo "❌ No XCFramework asset found in latest release $TAG_NAME"
    echo "   This release may not include XCFramework builds yet."
    exit 1
fi

# Extract asset details
ASSET_NAME=$(echo "$XCFRAMEWORK_ASSET" | jq -r '.name')
DOWNLOAD_URL=$(echo "$XCFRAMEWORK_ASSET" | jq -r '.browser_download_url')
CHECKSUM=$(echo "$XCFRAMEWORK_ASSET" | jq -r '.digest' | sed 's/sha256://')

echo "✅ Found latest release: $TAG_NAME"
echo "📦 XCFramework asset: $ASSET_NAME"
echo "🔗 Download URL: $DOWNLOAD_URL"
echo "🔐 Checksum: $CHECKSUM"

# Check if Package.swift exists
if [ ! -f "Package.swift" ]; then
    echo "❌ Package.swift not found in current directory"
    echo "   Please run this script from your package root directory"
    exit 1
fi

# Create backup
cp Package.swift Package.swift.backup
echo "💾 Created backup: Package.swift.backup"

# Update Package.swift
echo "📝 Updating Package.swift..."

# Use sed to update the URL and checksum in Package.swift
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS sed syntax
    sed -i '' "s|url: \"https://github.com/ggml-org/llama.cpp/releases/download/[^/]*/llama-[^\"]*\"|url: \"$DOWNLOAD_URL\"|" Package.swift
    sed -i '' "s|checksum: \"[^\"]*\"|checksum: \"$CHECKSUM\"|" Package.swift
else
    # GNU sed syntax (Linux)
    sed -i "s|url: \"https://github.com/ggml-org/llama.cpp/releases/download/[^/]*/llama-[^\"]*\"|url: \"$DOWNLOAD_URL\"|" Package.swift
    sed -i "s|checksum: \"[^\"]*\"|checksum: \"$CHECKSUM\"|" Package.swift
fi

echo "✅ Package.swift updated successfully!"
echo ""

# Verify the update worked
if grep -q "$TAG_NAME" Package.swift && grep -q "$CHECKSUM" Package.swift; then
    echo "🎉 Update completed successfully!"
    echo "   Version: $TAG_NAME"
    echo "   Checksum: $CHECKSUM"
    echo ""
    echo "📋 Next steps:"
    echo "   1. Review the changes: git diff Package.swift"
    echo "   2. Clear SPM cache: rm -rf ~/Library/Caches/org.swift.swiftpm/"
    echo "   3. Test your build: swift package resolve"
    echo "   4. Commit the changes: git add Package.swift && git commit -m 'Update llama.cpp to $TAG_NAME'"
else
    echo "⚠️  Update may have failed - please check Package.swift manually"
    echo "   You can restore from backup: mv Package.swift.backup Package.swift"
fi

echo ""
echo "📖 For more information, see: XCFRAMEWORK.md" 