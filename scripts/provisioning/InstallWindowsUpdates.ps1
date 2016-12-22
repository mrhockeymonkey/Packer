<#
	.SYNOPSIS
	Install windows updates

	.DESCRIPTION
	Install windows updates using the PSWindowsUpdate module. You can optionally set
    the Server and TargetGroup using environment variables

	.EXAMPLE
    "provisioners": [
		{
			"type": "powershell",
			"script": "scripts/provisioning/InstallWindowsUpdates.ps1",
			"elevated_user": "user",
			"elevated_password": "password",
			"environment_vars":[
				"WUSERVER=https://localwsusserver:8531",
				"TARGETGROUP=Workstations"
			]
		}
	]
#>

Try {
	
	$ProgressPreference = 'SilentlyContinue'
	$AU = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"
    $WUServer = $env:WUSERVER
    $TargetGroup = $env:TARGETGROUP
	
	#Disable auto-restart
	If (!(Test-Path -Path $AU)){
		New-Item -Path $(Split-Path -Parent $AU) -Name $(Split-Path -Leaf $AU) -ItemType Directory -Force -ErrorAction Stop | Out-Null
	}
	Write-Host "Setting NoAutoRebootWithLoggedOnUser to 1"
	New-ItemProperty -Path $AU -Name 'NoAutoRebootWithLoggedOnUser' -Value 1 -PropertyType 'DWord' -Force -ErrorAction Stop | Out-Null
	Write-Host "Setting UseWUServer to 1"
	New-ItemProperty -Path $AU -Name 'UseWUServer' -Value 1 -PropertyType 'DWord' -Force -ErrorAction Stop | Out-Null
	Write-Host "Setting NoAutoUpdate to 1"
	New-ItemProperty -Path $AU -Name 'NoAutoUpdate' -Value 1 -PropertyType 'DWord' -Force -ErrorAction Stop | Out-Null
	
    #Optionally set WUServer and TargetGroup
    If ($WUServer){
        Write-Host "Setting WUServer to $WUServer"
        New-ItemProperty -Path $(Split-Path -Path $AU) -Name 'WUServer' -Value $WUServer -PropertyType 'String' -Force -ErrorAction Stop | Out-Null
        New-ItemProperty -Path $(Split-Path -Path $AU) -Name 'WUStatusServer' -Value $WUServer -PropertyType 'String' -Force -ErrorAction Stop | Out-Null
    }
    If ($TargetGroup){
        Write-Host "Setting TargetGroup to $TargetGroup"
        New-ItemProperty -Path $(Split-Path -Path $AU) -Name 'TargetGroup' -Value $TargetGroup -PropertyType 'String' -Force -ErrorAction Stop | Out-Null
        New-ItemProperty -Path $(Split-Path -Path $AU) -Name 'TargetGroupEnabled' -Value 1 -PropertyType 'DWord' -Force -ErrorAction Stop | Out-Null
    }
    
    #Force registry changes to take effect and restart service
    & gpupdate.exe /target:computer /force
    Get-Service -Name wuauserv -ErrorAction Stop | Restart-Service -ErrorAction Stop

	#Check that PSWindowsUpdates is present
	$PSWindowsUpdate = Get-Module -Name PSWindowsUpdate -ListAvailable
	If (-not $PSWindowsUpdate) {
		Write-Error "PSWindowsUpdate module not found" -ErrorAction Stop
	}

	#Import and install updates
	Write-Host "Importing $($PSWindowsUpdate.Name) ($($PSWindowsUpdate.Version))"
	Import-Module -Name $PSWindowsUpdate.Name -ErrorAction Stop
	
    Write-Host "Installing windows updates..."
    Get-WUInstall -WindowsUpdate -AcceptAll -IgnoreReboot -Verbose

}
Catch {
	Write-Warning $_.Exception.Message
	Exit 1
}
