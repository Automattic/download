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
echo "~~~ Start"
colima start --runtime docker
echo "~~~ Verify setup"
docker version
docker ps

echo "--- :package: Packaging for macOS"
make release-mac
