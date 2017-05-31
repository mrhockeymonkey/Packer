<#
	.SYNOPSIS
	Removes Appx Package (Windows Store Apps)

	.DESCRIPTION
	This script can be used to remove all unwanted Appx packages before sysprepping.
	It removes all installed apps for all users AND provisioned apps (akin to disabling and removing in DISM)

	.EXAMPLE
	"provisioners": [
		{
			"type": "powershell",
			"Script": "scripts/provisioning/RemoveAppxPackages.ps1"
		}
	]

	.NOTES
	See https://support.microsoft.com/en-us/help/2769827/sysprep-fails-after-you-remove-or-update-windows-store-apps-that-include-built-in-windows-images
#>

$AppsToKeep = @(
	'Microsoft.MicrosoftStickyNotes'
	'Microsoft.WindowsCalculator'
)

Try {
	#Determine which provisioned apps you want to remove
	$AppsToRemove = Get-AppxProvisionedPackage -Online | Where-Object {$_.DisplayName -notin $AppsToKeep}
	
	#For any provisioned apps you want to unprovision you first need to uninstall the instance of that app for all users
	#(8wekyb3d8bbwe is Microsofts publishedId)
	Write-Host "Removing any installed windows apps..."
	Get-AppxPackage -AllUsers | Where-Object {$_.PublisherId -eq '8wekyb3d8bbwe' -and $_.Name -in $AppsToRemove.DisplayName} | Remove-AppxPackage

	#Now unprovision the apps
	Write-Host "Unprovisioning appx package $($_.PackageName)"
	$AppsToRemove | Remove-AppxProvisionedPackage -Online -ErrorVariable Stop
}
Catch {
	Write-Warning "Failed to remove appx packages - $($_.Exception.Message)"
	Exit 1
}
