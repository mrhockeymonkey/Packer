<#

#>

Try {
	#NEED TO DISABLE AUTORESTART

	
	$ProgressPreference = 'SilentlyContinue'
	$Categories = $env:UpdateCategories -split ';'

	#Check that PSWindowsUpdates is present
	$PSWindowsUpdate = Get-Module -Name PSWindowsUpdate -ListAvailable
	If (-not $PSWindowsUpdate) {
		Write-Error "PSWindowsUpdate module not found" -ErrorAction Stop
	}

	#Import and install updates
	Write-Host "Importing $($PSWindowsUpdate.Name) ($($PSWindowsUpdate.Version))"
	Import-Module -Name $PSWindowsUpdate.Name -ErrorAction Stop
	Write-Host "Update Categories: $($Categories -join ', ')"
	Get-WUInstall -WindowsUpdate -AcceptAll -IgnoreReboot -Verbose
}
Catch {
	Write-Warning $_.Exception.Message
	Exit 1
}