#!/bin/bash -u

echo "~~~ Check Homebrew setup"
brew config

echo "--- :mag: Filesystem debug info"
set -x
ls -ld /opt/ci/builds/builder/automattic/download
id -u
set +x

echo "--- :go: Installing Go"
echo "~~~ Install Go"
brew install go
echo "~~~ Add Go to PATH"
echo "PATH before: $PATH"
PATH=$PATH:$(go env GOPATH)/bin
export PATH
echo "PATH after: $PATH"

# echo "--- :docker: Installing Docker"
# echo "~~~ Install Docker"
# brew install docker
# echo "~~~ Install colima"
# brew install colima
# HOMEBREW_PREFIX results unbound in CI
# https://buildkite.com/automattic/download/builds/17#0193060c-6559-4a6c-a5c0-4074a2ec7686/470-471
# "$HOMEBREW_PREFIX/opt/colima/bin/colima" start --runtime docker
# When can hardcode the Apple Silicon path, however, because we know our CI at this time only runs on Apple Silicon
#
# See failure at
# https://buildkite.com/automattic/download/builds/18#01930613-abac-4673-bee5-51d94d1c31fd
#
# And see https://buildkite.com/automattic/download/builds/18#01930613-abac-4673-bee5-51d94d1c31fd for why we call delete first

# Disable the colima delete workaround because it doesn't seem to help at all.
# And after all, we're on a clean install of colima so what is there to delete?
# echo "~~~ [Workaround attempt] Delete colima settings"
# /opt/homebrew/opt/colima/bin/colima delete --force

echo "~~~ Hack lima to not use hardware acceleretation"
# See https://github.com/abiosoft/colima/issues/970
# in particular https://github.com/abiosoft/colima/issues/970#issuecomment-2298154164
LIMACTL_PATH=$(brew --prefix)/bin/limactl
sudo curl -L -o "$LIMACTL_PATH" https://github.com/mikekazakov/lima-nohvf/raw/master/limactl
sudo chmod +x "$LIMACTL_PATH"

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
#
# The lima workaround above is what solved the root of all the issues documented so far.
# Unfortunately, it only resulted in a new issue, later in the flow when running Docker.
#
# Update: Bypassing Colima because it seems unnecessary when using Podman as the engine (see how Makefile calls fyne-cross)
# /opt/homebrew/opt/colima/bin/colima start \
#   --runtime docker \
#   --vm-type qemu \
#   --arch aarch64
# echo "~~~ Check colima status"
# /opt/homebrew/opt/colima/bin/colima status
# echo "~~~ Print logs from expected failure"
# cat /Users/builder/.colima/_lima/colima/ha.stderr.log
# echo "~~~ Check Docker version"
# docker version
# echo "~~~ List Docker containers"
# docker container list

echo "--- Set up Podman"
echo "~~~ Install Podman"
brew install podman
echo "~~~ Init Podman"
"$(brew --prefix)/opt/podman/bin/podman" machine init
echo "~~~ Start Podman"
"$(brew --prefix)/opt/podman/bin/podman" machine start

echo "--- :package: Packaging for macOS"
make release-mac
