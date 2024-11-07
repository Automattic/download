#!/bin/bash -eu

echo "--- :go: Installing Go"
brew install go

echo "--- :bug: Print debug info"
which go

echo "--- :bug: Print debug info"
echo "$PATH"

echo "--- :wrench: Add go to path (just in case)"
PATH=$PATH:$(go env GOPATH)/bin
export PATH

echo "--- :package: Packaging for macOS"
make release-mac
