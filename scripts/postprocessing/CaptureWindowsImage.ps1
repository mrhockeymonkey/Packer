<#
	.SYNOPSIS
	Capture a windows image file
	
	.DESCRIPTION
	This script creates a windows image file (.wim) from a given virtual hard disk file (.vhd)
	It can be called via the 'shell-local' post-processor to convert a vhd artifact into a wim

	.EXAMPLE
	"post-processors": [
		{
			"type": "shell-local",
			"execute_command": "{{.Script}} -Artifact {{.Artifact}}",
			"script": "scripts/postprocessing/CaptureWindowsImage.ps1"
		}

	.NOTES
	This assume you have copied powershell.exe to sh.exe to make shell-local useable on windows!
	This also assumes you have already conveted any VMDKs in the manifest into in VHDs
#>

[CmdletBinding()]
Param (
	[Parameter (Mandatory = $true)]
	[String]$Manifest
)

$ErrorActionPreference = 'Stop'

Try {
	#Read manifest data
	$ManifestData = Get-Content -Path $Manifest -Raw | ConvertFrom-Json
	$Vmdk = Get-Item -Path $($ManifestData.builds.files | Select-Object -Expand Name | Where-Object {$_ -like "*.vmdk"})
	$Vhd = Get-Item -Path $($Vmdk.FullName -replace ".vmdk",".vhd")
	
	#Create a folder to mount to and define ImagePath
	$MountDir = New-Item -Path $Vhd.Directory.FullName -Name 'MountDir' -ItemType Directory -ErrorAction Stop
	$ImagePath = "$($Vhd.Directory.FullName)\$($Vhd.BaseName).wim"

	#Remove any old artifacts from previous runs
	If (Test-Path $ImagePath) {
		Write-Host "Removing old artifact..."
		Remove-Item -Path $ImagePath -Force -ErrorAction Stop
	}

	#Mount the virtual disk file
	Write-Host "Mounting $($Vhd.FullName)..."
	Mount-WindowsImage -ImagePath $Vhd.FullName -Path $MountDir.FullName -Index 1 -ErrorAction Stop | Out-Null

	#Create a new windows image file
	Write-Host "Capturing windows image. This may take some time..."
	New-WindowsImage -Name $Vhd.BaseName -ImagePath $ImagePath -CapturePath $MountDir.FullName -Verify -ErrorAction Stop
}
Catch {
	Write-Warning $_.Exception.Message
	Exit 1
}
Finally {
	#Dismount and remove directory
	Write-Host "Dismounting $($Vhd.FullName)"
	Dismount-WindowsImage -Path $MountDir.FullName -Discard -ErrorAction SilentlyContinue | Out-Null
	$MountDir | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
}