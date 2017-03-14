<#
	.SYNOPSIS
	Psake build script for CI engine

	.DESCRIPTION
	This script is used as part of a CI job to invoke packer (in this case using Jenkins)
	To add this as a build step, add the powershell plugin and call this script using:
		Import-Module PSake
		Invoke-PSake -BuildFile "$env:Workspace\Build.ps1 -TaskList VBoxBuild -NoLogo
#>

Properties {
	$File       = "$PSScriptRoot\vbox_win_10.json"
	$Packer     = "$env:ProgramData\Packer\Packer.exe"
	$VBoxManage = "$env:ProgramFiles\Oracle\VirtualBox\VBoxManage.exe"
}

#Standard default task
Task -Name Default -Depends CheckPacker, Validate, Build

#Tasks for particular packer types (so far only vbox but other might include aws or azure)
Task -Name VBoxBuild -Depends CheckPacker, CheckVBox, Validate, Build

#Check to see packer.exe is present
Task -Name CheckPacker -Action {
	If (-not (Test-Path $Packer)) {
		throw "$Packer is missing, download from https://www.packer.io/downloads.html"
	}
	Else {
		$Version = & $Packer --version
		Write-Output "Packer version $Version is present"
	}
}

#Check to see VBox is present
Task -Name CheckVBox -Action {
	If (-not (Test-Path $VBoxManage)) {
		throw "$VBoxManage is missing, download from https://www.virtualbox.org/wiki/Downloads"
	}
	Else {
		$Version = & $VBoxManage --version
		Write-Output "VBox version $Version is present"
	}
}

#Validate using packer.exe validate <file>
Task -Name Validate -Depends CheckPacker -Action {
	$Validate = & $Packer validate $File
	If ($Validate -eq 'Template validated successfully.') {
		Write-Output $Validate
	}
	Else {
		throw $Validate
	}
}

#Build using packer.exe build <file>
Task -Name Build -Depends Validate -Action {
	& $Packer build $File

	If ($LASTEXITCODE -ne 0) {
		throw "packer build $File was not successful, check output above for failure"
	}
}