<#
	.SYNOPSIS
	Install windows updates

	.DESCRIPTION
	Install windows updates using the PSWindowsUpdate module

	.EXAMPLE
#>

Try {
	
	$ProgressPreference = 'SilentlyContinue'
	$AU = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"
	
	#Disable auto-restart
	Write-Host "Disabling auto update"
	If (!(Test-Path -Path $AU)){
		New-Item -Path $(Split-Path -Parent $AU) -Name $(Split-Path -Leaf $AU) -ItemType Directory -Force -ErrorAction Stop
	}
	New-ItemProperty -Path $AU -Name 'NoAutoRebootWithLoggedOnUser' -Value 1 -Force -ErrorAction Stop
	& gpupdate.exe /target:computer /force

	#Check that PSWindowsUpdates is present
	$PSWindowsUpdate = Get-Module -Name PSWindowsUpdate -ListAvailable
	If (-not $PSWindowsUpdate) {
		Write-Error "PSWindowsUpdate module not found" -ErrorAction Stop
	}

	#Import and install updates
	Write-Host "Importing $($PSWindowsUpdate.Name) ($($PSWindowsUpdate.Version))"
	Import-Module -Name $PSWindowsUpdate.Name -ErrorAction Stop
	Get-WUInstall -WindowsUpdate -AcceptAll -IgnoreReboot -Verbose
}
Catch {
	Write-Warning $_.Exception.Message
	Exit 1
}