#!/bin/bash -eu

#FIXME: This updates PATH, so needs to be sourced. Add check to enforce this.

echo "--- :ruby: Install Ruby gems"
install_gems

echo "--- :go: Install Go"
echo "~~~ Install"
brew install go
echo "~~~ Check version"
go version
echo "~~~ Export GOBIN in case it was empty"
GOBIN=$(go env GOPATH)/bin
export GOBIN
echo "~~~ Add to PATH"
echo "PATH before adding Go:"
echo "$PATH"
PATH=$PATH:$GOBIN
export PATH
echo "PATH after adding Go:"
echo "$PATH"
