# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0

[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [string]$ServerAddresses
)

& .\Prepare-Box.ps1

# Set Wallpaper
& .\Set-WallPaper.ps1

& .\Set-StaticIP.ps1 -ServerAddresses $ServerAddresses
