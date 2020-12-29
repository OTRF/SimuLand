# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0

[CmdletBinding()]
param (
    [Parameter(Mandatory=$false)]
    [string]$ServerAddresses,

    [Parameter(Mandatory)]
    [ValidateSet("DC","ADFS",'Endpoint')]
    [string]$SetupType,

    [Parameter(Mandatory=$false)]
    [ValidateSet('TrustedSigned','SelfSigned')]
    [string]$CertificateType,

    [Parameter(Mandatory=$false)]
    [string]$CertificateName
)

# Install DSC Modules
& .\Install-DSC-Modules.ps1 -SetupType $SetupType

if (($SetupType -eq 'DC') -or ($SetupType -eq 'ADFS'))
{
    if ($CertificateType -eq 'Trusted')
    {
        # Move trusted CA signed SSL certificate
        Move-Item $CertificateName C:\ProgramData\
    }
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