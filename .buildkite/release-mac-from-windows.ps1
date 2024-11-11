# Stop script execution when a non-terminating error occurs
$ErrorActionPreference = "Stop"

& "prepare_windows_host_for_node.ps1"

Write-Host "--- :windows: Installing make"
choco install make

Write-Host "--- :windows: Installing Go"
choco install go

refreshenv

Write-Host "--- :gear: Running packaging script"
bash ".\.buildkite\release-mac-from-windows.sh"
if ($LastExitCode -ne 0) { Exit $LastExitCode }
