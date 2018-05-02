#!/bin/bash

curl -o rpc.proto -s https://raw.githubusercontent.com/lightningnetwork/lnd/master/lnrpc/rpc.proto

protoc rpc.proto \
	--swiftgrpc_out=Proto \
	--swift_out=Proto \
	--proto_path=googleapis \
	--proto_path=. \
	--plugin=protoc-gen-swift=protoc-gen-swift \
	--plugin=protoc-gen-swiftgrpc=protoc-gen-swiftgrpc
