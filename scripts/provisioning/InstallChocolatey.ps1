<#
	.SYNOPSIS
	Install chocolatey

	.DESCRIPTION
	This script installs chocolatey using the recommended chocolatey install method. 
	It is called as part of provisioning and requires a reboot

	.EXAMPLE
	"provisioners": [
		{
			"type": "powershell",
			"script": "scripts/InstallChocolatey.ps1"
		},
		{
			"type":"windows-restart"
		}
#>

[CmdletBinding()]
Param ()

Try {
	#Install chocolatey
	Invoke-Expression ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))
}
Catch {
	Write-Warning $_.Exception.Message
	Exit 1
}