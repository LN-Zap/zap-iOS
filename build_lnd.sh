#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )/Frameworks"
cd $GOPATH/src/github.com/lightningnetwork/lnd
make IOS_BUILD_DIR=$DIR ios

