<#
	.SYNOPSIS
	Capture a windows image file
	
	.DESCRIPTION
	This script creates a windows image file (.wim) from a given virtual hard disk file (.vhd)
	It can be called via the 'shell-local' post-processor to convert a vhd artifact into a wim

	.EXAMPLE
	"post-processors": [
		{
			"type":"shell-local",
			"execute_command":"powershell.exe -noprofile -File {{.Script}} -Artifact {{.Artifact}}",
			"script": "scripts/CaptureWindowsImage.ps1"
		}
#>

[CmdletBinding()]
Param (
	[Parameter (Mandatory = $true)]
	[String]$Artifact
)

Try {
	#Get the artifact, create a folder to mount to and define ImagePath
	$SourceFile = Get-Item $Artifact -ErrorAction Stop
	$MountDir = New-Item -Path $SourceFile.Directory.FullName -Name 'MountDir' -ItemType Directory -ErrorAction Stop
	$ImagePath = "$($SourceFile.Directory.FullName)\$($SourceFile.BaseName).wim"

	#Remove any old artifacts from previous runs
	If (Test-Path $ImagePath) {
		Write-Host "Removing old artifact..."
		Remove-Item -Path $ImagePath -Force -ErrorAction Stop
	}

	#Mount the virtual disk file
	Write-Host "Mounting $($SourceFile.FullName)..."
	Mount-WindowsImage -ImagePath $Artifact -Path $MountDir.FullName -Index 1 -ErrorAction Stop | Out-Null

	#Create a new windows image file
	Write-Host "Capturing windows image. This may take some time..."
	New-WindowsImage -Name $SourceFile.BaseName -ImagePath $ImagePath -CapturePath $MountDir.FullName -Verify -ErrorAction Stop
}
Catch {
	Write-Warning $_.Exception.Message
	Exit 1
}
Finally {
	#Dismount and remove directory
	Write-Host "Dismounting $($SourceFile.FullName)"
	Dismount-WindowsImage -Path $MountDir.FullName -Discard -ErrorAction SilentlyContinue | Out-Null
	$MountDir | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
}