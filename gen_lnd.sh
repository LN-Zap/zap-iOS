#!/bin/bash

# Follow the setup instructions to Generate protobuf definitions:
# https://github.com/lightningnetwork/lnd/blob/master/lnrpc/README.md#generate-protobuf-definitions
#
# Install swift-protobuf 1.5.0 (don't use brew): 
# https://github.com/apple/swift-protobuf
#
# Install protoc-gen-zap
# https://github.com/LN-Zap/protoc-gen-zap/
#
# Install falafel
# `go get github.com/halseth/falafel`

OUT=SwiftLnd/Generated

# Generate the protos.
protoc -I/usr/local/include -I.\
       -I$GOPATH/src/github.com/lightningnetwork/lnd/lnrpc \
       -I$GOPATH/src/github.com/grpc-ecosystem/grpc-gateway/third_party/googleapis \
       --swift_out=$OUT \
       --zap_out=$OUT \
       --swiftgrpc_out=Sync=false,Server=false:$OUT \
       $GOPATH/src/github.com/lightningnetwork/lnd/lnrpc/rpc.proto

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
FRAMEWORKDIR=$DIR/Frameworks
cd $GOPATH/src/github.com/lightningnetwork/lnd
git apply $DIR/patches/mainnet.patch
git apply $DIR/patches/user_agent_name.patch
git apply $DIR/patches/user_agent_version.patch

make rpc
make mobile-rpc
make tags="experimental" IOS_BUILD_DIR=$FRAMEWORKDIR ios

