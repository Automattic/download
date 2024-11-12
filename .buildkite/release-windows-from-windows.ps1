# Stop script execution when a non-terminating error occurs
$ErrorActionPreference = "Stop"

& "prepare_windows_host_for_node.ps1"

Write-Host "--- :windows: Installing make"
choco install make

Write-Host "--- :windows: Installing Go"
# The install process requires user confirmation, hence the -y option
# See https://buildkite.com/automattic/download/builds/64#01931dc8-2a8f-4d2b-8382-8b69964896c5/240-261
choco install go -y

refreshenv

# # Using Podman instead of Docker because apparently installing Docker requires a restart
# # See https://community.chocolatey.org/packages/docker-desktop
# # TODO: Are there other options than docker-desktop?
# Write-Host "--- :windows: Installing Podman"
# # The install process requires user confirmation, hence the -y option
# # See https://buildkite.com/automattic/download/builds/64#01931dc8-2a8f-4d2b-8382-8b69964896c5/240-261
# choco install podman-cli -y

# refreshenv

# podman machine init
# podman machine start

Write-Host "--- :windows: Installing Docker"
choco install docker -y

refreshenv

# This should avoid failures like
# > no matching manifest for windows/amd64 10.0.17763 in the manifest list entries
# See https://buildkite.com/automattic/download/builds/75#01931e2b-2bdf-40b3-8c4f-d8f2f7c6bd15/317-357
Write-Host "--- :docker: Switch to Linux containers"
& $Env:ProgramFiles\Docker\Docker\DockerCli.exe -SwitchDaemon .

Write-Host "--- :gear: Running packaging script"
make release-windows
if ($LastExitCode -ne 0) { Exit $LastExitCode }
