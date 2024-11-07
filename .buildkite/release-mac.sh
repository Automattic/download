#!/bin/bash -eu

echo "--- :go: Installing Go"
echo "~~~ Install Go"
brew install go
echo "~~~ Add Go to PATH"
echo "PATH before: $PATH"
PATH=$PATH:$(go env GOPATH)/bin
export PATH
echo "PATH after: $PATH"

echo "--- :docker: Installing Docker"
echo "~~~ Install Docker"
brew install docker
echo "~~~ Install colima"
brew install colima
echo "~~~ Start colima"
# HOMEBREW_PREFIX results unbound in CI
# https://buildkite.com/automattic/download/builds/17#0193060c-6559-4a6c-a5c0-4074a2ec7686/470-471
# "$HOMEBREW_PREFIX/opt/colima/bin/colima" start --runtime docker
# When can hardcode the Apple Silicon path, however, because we know our CI at this time only runs on Apple Silicon
/opt/homebrew/opt/colima/bin/colima start --runtime docker
echo "~~~ Verify Docker setup"
docker version
docker ps

echo "--- :package: Packaging for macOS"
make release-mac
