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

Write-Host "--- :gear: Running packaging script"
bash ".\.buildkite\release-mac-from-windows.sh"
if ($LastExitCode -ne 0) { Exit $LastExitCode }
