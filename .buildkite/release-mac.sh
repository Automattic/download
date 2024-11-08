#!/bin/bash -u

echo "~~~ Check Homebrew setup"
brew config

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
# --vm-type vz – an experiment taken from https://github.com/abiosoft/colima/issues/746#issuecomment-1692849926 – FAILED
#
# --arch x86_64 — to work around the hvf acceleration error experienced here
# https://buildkite.com/automattic/download/builds/30#0193097f-5aaf-402f-bb47-f75246faef06/483-499
# solution inspired from https://github.com/actions/runner-images/issues/9460
# ... – FAILED with "exec format error" because of incompatible archs
#
# --vz-rosetta is a different attempt to solve the same accelearation problem.
# In the meantime, I learned the the problem only occurs here in CI because of nested VM.
#
# --vz-rosetta alone did not help, but in reading the YMAL config that `colima start --edit` offerst, maybe one needs to run with --vm-type vz
#
# Unfortunately, even the vz + vz-rosetta combo fails:
# "Virtualization is not available on this hardware"
# See https://buildkite.com/automattic/download/builds/34#01930a7e-450f-41c6-8c54-7d219b5760de
#
# --arch aarch64 is the default value, but setting it here explicitly just for clarity / just in case
/opt/homebrew/opt/colima/bin/colima start \
  --runtime docker \
  --vm-type qemu \
  --arch aarch64
echo "~~~ Check colima status"
/opt/homebrew/opt/colima/bin/colima status
echo "~~~ Print logs from expected failure"
cat /Users/builder/.colima/_lima/colima/ha.stderr.log
echo "~~~ Check Docker version"
docker version
echo "~~~ List Docker containers"
docker container list

echo "--- :package: Packaging for macOS"
make release-mac
