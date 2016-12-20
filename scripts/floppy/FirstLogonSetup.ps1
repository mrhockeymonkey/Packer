<#
	.DESCRIPTION
	This script runs straight after the oobe pass. It is run by the Autounattend answer file
#>

#Set execution policy to Unrestricted
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope LocalMachine -Force -ErrorAction Ignore

#As of Windows 10 you cannot use the Autounattend property "OOBE\NetworkLocation" to set
#your connection profile to private. So if major version is 10 we use powershell
If ([System.Environment]::OSVersion.Version.Major -eq 10) {
	Get-NetConnectionProfile | Set-NetConnectionProfile -NetworkCategory Private
}

#Enable WinRM
Enable-PSRemoting -SkipNetworkProfileCheck -Force
winrm set winrm/config/service/auth '@{Basic="true"}'
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
