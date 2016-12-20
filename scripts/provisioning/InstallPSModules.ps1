<#
	.SYNOPSIS
	Install powershell modules from PSGallery

	.DESCRIPTION
	This script installs the nuget provider and any requested modules from using PowerShellGet. 
	As we cant pass in arguments for provisioning scripts you will need to provide a ; seperated
	list of required modules

	.EXAMPLE
	"provisioners": [
		{
			"type":"powershell",
			"script": "scripts/provisioning/InstallPSModules.ps1",
			"environment_vars":[
				"RequiredProviders=Nuget;PowerShellGet",
				"RequiredModules=PSWindowsUpdate;Pester"
			]
		}
#>

Try {
	
	$Providers = $env:RequiredProviders -split ';' 
	$Modules   = $env:RequiredModules -split ';' 
	
	#Install required providers
	$Providers | ForEach-Object -Process {
		Write-Host "Installing PackageProvider: $_"
		Install-PackageProvider -Name $_ -ForceBootstrap -Force
	}

	#Install required modules
	$Modules | ForEach-Object -Process {
		Write-Host "Installing Module: $_"
		Install-Module -Name $_ -Force
	} 
}
Catch {
	Write-Warning $_.Exception.Message
	Exit 1
}