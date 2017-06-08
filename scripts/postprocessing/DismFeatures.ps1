<#
	.SYNOPSIS
	Use DISM module to service the image when it is a wim
	
	.DESCRIPTION
	This Script will attempt to install a windows feature that is only availiable via sxs. Created for Dotnet 3.5

	.EXAMPLE
	"post-processors": [
		{
			"type":"shell-local",
			"execute_command":" {{.Script}} -Manifest \"output-<buildname>/manifest.json\ -SxsFolder <path to SxsFolder> -Feature <Nameoffeature(dsim name)",
			"script": "scripts/postprocessing/EnableWindowsOptionalFeature.ps1"
		}
#>

[CmdletBinding()]
Param (
	[Parameter (Mandatory = $true)]
	[String]$Manifest,

	[Parameter (Mandatory = $true)]
	[String]$SxsFolder,

	[Parameter (Mandatory = $true)]
	[String[]]$Feature,

	[Parameter (Mandatory = $true)]
	[ValidateSet('Enable','Disable','Remove')]
	[String]$Operation
)

#We dont want to use the native dism becuase in the case of 2012R2 building a windows 10 box it will fail.
$Dism = "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\amd64\DISM\dism.exe"

Try {
	If (-not (Test-Path -Path $Dism)) {
		Write-Error "Cannot find $Dism. This is required for servicing windows 10 images" -ErrorAction Stop
	}

	#Read the manifest to find the artifact we need"
	$PackerRoot = Get-Item -Path "$PSScriptRoot\..\.."
	$ManifestContent = Get-Item -Path $( Join-Path $PackerRoot $Manifest) | Get-Content -Raw | ConvertFrom-Json
	$SourceFile = Get-Item -Path $(Join-Path $PackerRoot $($ManifestContent.builds.files.name[0] -replace ".vmdk",".wim")) -ErrorAction Stop

	$MountDir = New-Item -Path $SourceFile.Directory.FullName -Name 'MountDir' -ItemType Directory -ErrorAction Stop

	Write-Host "Mounting $($SourceFile.FullName)..."
	& $Dism /Mount-Image /ImageFile:$($SourceFile.FullName) /Index:1 /MountDir:$($MountDir.FullName)

	Switch ($Operation) {
		'Enable' {
			$Feature | ForEach-Object {
				Write-Host "Enabling Feature $_"
				& $Dism /Image:$($MountDir.FullName) /Enable-Feature /All /FeatureName:$_ /Source:$SxsFolder /LimitAccess
			}
		}

		'Disable' {
			$Feature | ForEach-Object {
				Write-Host "Disabling Feature $_"
				& $Dism /Image:$($MountDir.FullName) /Disable-Feature /FeatureName:$_
			}
		}

		'Remove' {
			$Feature | ForEach-Object {
				Write-Host "Removing Feature $_"
				& $Dism /Image:$($MountDir.FullName) /Disable-Feature /Remove /FeatureName:$_
			}
		}
	}

}
Catch {
	Write-Warning "Failed to enable optional windows features - $($_.Exception.Message)"
	Exit 1
}
Finally {
	#Dismount and remove directory
	Write-Host "Dismounting $($SourceFile.FullName)"
	& $Dism /Unmount-image /MountDir:$($MountDir.FullName) /Commit
	$MountDir | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
}
