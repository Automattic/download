#!/bin/bash -eu

echo "--- :go: Installing Go"
brew install go

echo "--- :package: Packaging for macOS"
make release-mac
