<#
	.SYNOPSIS
	Converts a VMDK into a VHD

	.DESCRIPTION
	This script uses Microsoft Virtual Machine converter to convert vmdk file sinto vhd file which can be used to then capture windows images. 

	.EXAMPLE
	"post-processors": [
		{
			"type":"shell-local",
			"execute_command": "{{.Script}} -Artifact {{.Artifact}}",
			"script": "scripts/postprocessing/ConvertVirtualDisk.ps1"
		}

	.NOTES
	This assume you have copied powershell.exe to sh.exe to make shell-local useable on windows!
	Microsoft Virtual Machine Converter 3.0: https://www.microsoft.com/en-us/download/details.aspx?id=42497
#>

[CmdletBinding()]
Param (
	[Parameter (Mandatory = $true)]
	[String]$Manifest
)

$ErrorActionPreference = 'Stop'

Try {
	Import-Module "C:\Program Files\Microsoft Virtual Machine Converter\MvmcCmdlet.psd1"
	
	#Read manifest
	$ManifestData = Get-Content -Path $Manifest -Raw | ConvertFrom-Json
	$Vmdk = Get-Item -Path $($ManifestData.builds.files | Select-Object -Expand Name | Where-Object {$_ -like "*.vmdk"})
	$Dest = "$($Vmdk.Directory.FullName)"
	
	#Convert
	Write-Output "Converting $($Vmdk.FullName)"
	ConvertTo-MvmcVirtualHardDisk -SourceLiteralPath $Vmdk -DestinationLiteralPath $Dest -VhdType DynamicHardDisk -VhdFormat Vhd
}
Catch {
	Write-Warning $_.Exception.Message
	Exit 1
}