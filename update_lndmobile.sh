#!/bin/bash

set -v

# write Lndmobile.framework checksums to .lndmobile.sha1 to verify framework version before upload
find Carthage/Build/iOS/Lndmobile.framework -type f \( ! -iname ".*" \) -print0 | sort -z | xargs -0 shasum > .lndmobile.sha1

# download genereated swift api
VERSION=v0.8.0-beta

curl -L https://github.com/LN-Zap/Lndmobile.framework/releases/download/$VERSION/swift-generated.zip --output swift-generated.zip
unzip -o swift-generated.zip -d SwiftLnd/Generated
rm swift-generated.zip

