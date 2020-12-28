# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0

[CmdletBinding()]
param (
    [Parameter(Mandatory=$false)]
    [string]$ServerAddresses,

    [Parameter(Mandatory=$false)]
    [ValidateSet("DC","ADFS",'Endpoint')]
    [string]$SetupType,

    [Parameter(Mandatory=$false)]
    [string]$trustedCertificateName
)

# Install DSC Modules
if ($SetupType -eq 'DC')
{
    & .\Install-AD-DSC-Modules.ps1
    # Move trusted CA signed SSL certificate
    Move-Item $trustedCertificateName C:\ProgramData\
}
elseif ($SetupType -eq 'ADFS')
{
    & .\Install-ADFS-DSC-Modules.ps1
    # Move trusted CA signed SSL certificate
    Move-Item $trustedCertificateName C:\ProgramData\
}
else 
{
    & .\Install-Endpoint-DSC-Modules.ps1
}

# Custom Settings applied
& .\Prepare-Box.ps1

# Windows Security Audit Categories
if ($SetupType -eq 'DC')
{
    & .\Enable-WinAuditCategories.ps1 -SetDC
}
else
{
    & .\Enable-WinAuditCategories.ps1
}

# PowerShell Logging
& .\Enable-PowerShell-Logging.ps1

# Set SACLs
& .\Set-SACLs.ps1

# Set Wallpaper
& .\Set-WallPaper.ps1