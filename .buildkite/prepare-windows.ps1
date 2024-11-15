# Stop script execution when a non-terminating error occurs
$ErrorActionPreference = "Stop"

& "prepare_windows_host_for_node.ps1"

# The exe is generated successfully, but even if we pass the certificate to `fyne package -release`
# Windows Defender still picks it up as a virus.
#
# Will this help?
Write-Host "--- :windows: Import code signing certificate"
$certPath = (Convert-Path .\certificate.pfx)
If (Test-Path $certPath) {
    Write-Host "PFX certificate found at expected path $certPath. Adding it to the cert store..."
} else {
    Write-Host "[!] Certificate file does not exist at given path $certPath."
    Exit 1
}
Import-PfxCertificate -FilePath $certPath -CertStoreLocation Cert:\LocalMachine\Root -Password (ConvertTo-SecureString -String $env:WINDOWS_CODE_SIGNING_CERT_PASSWORD -AsPlainText -Force)

Write-Host "--- :hammer: Install tools"
Write-Host "~~~ :windows: Installing make"
choco install make

Write-Host "~~~ :windows: Installing Go"
# The install process requires user confirmation, hence the -y option
# See https://buildkite.com/automattic/download/builds/64#01931dc8-2a8f-4d2b-8382-8b69964896c5/240-261
choco install go -y

Write-Host "~~~ :windows: Installing GCC"
choco install mingw -y

Write-Host "~~~ :chocolate_bar: Refresh env after tools setup"
refreshenv

& "$PSScriptRoot\install-windows-10-sdk.ps1"
If ($LastExitCode -ne 0) { Exit $LastExitCode }
