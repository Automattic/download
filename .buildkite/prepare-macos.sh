#!/bin/bash -eu

echo "--- :ruby: Install Ruby gems"
install_gems

echo "--- :go: Install Go"
brew install go
