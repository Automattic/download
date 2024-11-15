# Stop script execution when a non-terminating error occurs
$ErrorActionPreference = "Stop"

& "prepare_windows_host_for_node.ps1"

# The exe is generated successfully, but even if we pass the certificate to `fyne package -release`
# Windows Defender still picks it up as a virus.
#
# Will this help?
Write-Host "--- :windows: Import code signing certificate"
Import-PfxCertificate \
  -FilePath (Convert-Path .\certificate.pfx) \
  -CertStoreLocation Cert:\LocalMachine\Root \
  -Password (ConvertTo-SecureString -String $env:WINDOWS_CODE_SIGNING_CERT_PASSWORD -AsPlainText -Force)

Write-Host "--- :windows: Installing make"
choco install make

Write-Host "--- :windows: Installing Go"
# The install process requires user confirmation, hence the -y option
# See https://buildkite.com/automattic/download/builds/64#01931dc8-2a8f-4d2b-8382-8b69964896c5/240-261
choco install go -y

refreshenv

Write-Host "--- :windows: Installing GCC"
# The install process requires user confirmation, hence the -y option
# See https://buildkite.com/automattic/download/builds/64#01931dc8-2a8f-4d2b-8382-8b69964896c5/240-261
choco install mingw -y

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

# Write-Host "--- :windows: Installing Docker"
# choco install docker-cli -y
# choco install docker-desktop -y

# Write-Host "--- :chocolate: Print logs"
# cat C:\ProgramData\chocolatey\logs\chocolatey.log

# refreshenv

# Write-Host "--- :bug: Print help"
# C:\ProgramData\chocolatey\lib\docker-cli --help

# This should avoid failures like
# > no matching manifest for windows/amd64 10.0.17763 in the manifest list entries
# See https://buildkite.com/automattic/download/builds/75#01931e2b-2bdf-40b3-8c4f-d8f2f7c6bd15/317-357
# Write-Host "--- :docker: Switch to Linux containers"
# Write-Host "+++ TODO"

& "$PSScriptRoot\install-windows-10-sdk.ps1"
If ($LastExitCode -ne 0) { Exit $LastExitCode }

make release-windows
if ($LastExitCode -ne 0) { Exit $LastExitCode }
