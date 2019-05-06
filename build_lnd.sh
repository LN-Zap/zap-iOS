#!/bin/bash

# Follow the setup instructions to Generate protobuf definitions:
# https://github.com/lightningnetwork/lnd/blob/master/lnrpc/README.md#generate-protobuf-definitions
#
# Install swift-protobuf 1.5.0 (don't use brew): 
# https://github.com/apple/swift-protobuf
#
# Install promobile
# `go get github.com/halseth/promobile`

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
FRAMEWORKDIR=$DIR/Frameworks

cd $GOPATH/src/github.com/lightningnetwork/lnd

make clean
export GO111MODULE=on
go mod vendor
export GO111MODULE=off
make rpc
make IOS_BUILD_DIR=$FRAMEWORKDIR ios

cp lnrpc/rpc.pb.swift $DIR/SwiftLnd/Generated
cp lnrpc/rpc.grpc.swift $DIR/SwiftLnd/Generated

