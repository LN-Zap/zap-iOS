#!/bin/bash

set -v

# setup submodules
git submodule update --init --recursive

# download Lndmobile.framework
VERSION=v0.8.0-beta

rm -rf Frameworks/Lndmobile.framework
curl -L https://github.com/LN-Zap/Lndmobile.framework/releases/download/$VERSION/Lndmobile.framework.zip --output Lndmobile.framework.zip
unzip Lndmobile.framework.zip -d Frameworks/
rm Lndmobile.framework.zip

# write Lndmobile.framework checksums to .lndmobile.sha1 to verify framework version before upload
find Frameworks/Lndmobile.framework -type f \( ! -iname ".*" \) -print0 | sort -z | xargs -0 shasum > .lndmobile.sha1

# download genereated swift api
curl -L https://github.com/LN-Zap/Lndmobile.framework/releases/download/$VERSION/swift-generated.zip --output swift-generated.zip
unzip -o swift-generated.zip -d SwiftLnd/Generated
rm swift-generated.zip
