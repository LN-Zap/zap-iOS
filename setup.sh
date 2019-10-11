#!/bin/bash

set -v

# setup submodules
git submodule update --init --recursive

# download Lndmobile.framework
VERSION=v0.8.0-beta-rc2

curl -L https://github.com/LN-Zap/Lndmobile.framework/releases/download/$VERSION/Lndmobile.framework.zip --output Lndmobile.framework.zip
unzip Lndmobile.framework.zip -d Frameworks/
rm Lndmobile.framework.zip

curl -L https://github.com/LN-Zap/Lndmobile.framework/releases/download/$VERSION/swift-generated.zip --output swift-generated.zip
unzip -o swift-generated.zip -d SwiftLnd/Generated
rm swift-generated.zip
