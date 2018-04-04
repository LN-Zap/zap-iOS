# Zap

[![Build Status](https://travis-ci.org/LN-Zap/zap-iOS.svg?branch=master)](https://travis-ci.org/LN-Zap/zap-iOS)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://github.com/LN-Zap/zap-iOS/blob/master/LICENSE)

A native iOS lightning wallet. Based on [lnd](https://github.com/lightningnetwork/lnd).

## Install Git LFS

To download the compiled iOS lnd framework you have to setup [Git LFS](https://git-lfs.github.com). You only have to set up Git LFS once.

```
brew install git-lfs
git lfs install
git lfs pull
```

## Compile the lnd proto file

To compile the lnd proto file you have to clone `googleapis` repo first.

```
git clone https://github.com/googleapis/googleapis.git
curl -o rpc.proto -s https://raw.githubusercontent.com/lightningnetwork/lnd/master/lnrpc/rpc.proto
pod install
```
