# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0

[CmdletBinding()]
param (
    [Parameter(Mandatory=$false)]
    [string]$ServerAddresses
)

$ErrorActionPreference = "Stop"

& .\Prepare-Box.ps1
& .\Set-StaticIP.ps1 -ServerAddresses $ServerAddresses