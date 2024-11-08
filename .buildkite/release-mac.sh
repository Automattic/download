#!/bin/bash -u

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
echo "~~~ [Workaround attempt] Delete colima settings"
# HOMEBREW_PREFIX results unbound in CI
# https://buildkite.com/automattic/download/builds/17#0193060c-6559-4a6c-a5c0-4074a2ec7686/470-471
# "$HOMEBREW_PREFIX/opt/colima/bin/colima" start --runtime docker
# When can hardcode the Apple Silicon path, however, because we know our CI at this time only runs on Apple Silicon
#
# See failure at
# https://buildkite.com/automattic/download/builds/18#01930613-abac-4673-bee5-51d94d1c31fd
#
# And see https://buildkite.com/automattic/download/builds/18#01930613-abac-4673-bee5-51d94d1c31fd for why we call delete first
/opt/homebrew/opt/colima/bin/colima delete --force
echo "~~~ Start colima"
# --vm-type vz – an experiment taken from https://github.com/abiosoft/colima/issues/746#issuecomment-1692849926
/opt/homebrew/opt/colima/bin/colima start --runtime docker --vm-type vz
echo "~~~ Print logs from expected failure"
cat /Users/builder/.colima/_lima/colima/ha.stderr.log
echo "~~~ Verify Docker setup"
docker version
docker ps

echo "--- :package: Packaging for macOS"
make release-mac
