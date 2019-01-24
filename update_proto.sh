#!/bin/bash

curl -o Proto/LndRpc.proto -s https://raw.githubusercontent.com/lightningnetwork/lnd/master/lnrpc/rpc.proto
echo 'option objc_class_prefix = "LND";' >> Proto/LndRpc.proto

Pods/!ProtoCompiler/protoc \
    --plugin=protoc-gen-grpc="Pods/!ProtoCompiler-gRPCPlugin/grpc_objective_c_plugin" \
    --objc_out="Pods/LndRpc" \
    --grpc_out="Pods/LndRpc" \
    -I "Proto" \
    --proto_path=googleapis \
    -I "Pods/!ProtoCompiler" \
    Proto/*.proto

sed -i '' '/.*google\/api.*/s/^/\/\//g' Pods/LndRpc/LndRpc.*
sed -i '' '/.*GAPIAnnotationsRoot.*/s/^/\/\//g' Pods/LndRpc/LndRpc.pbobjc.m
