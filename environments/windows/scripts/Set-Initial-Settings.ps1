# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0

[CmdletBinding()]
param (
    [Parameter(Mandatory=$false)]
    [string]$ServerAddresses,

    [Parameter(Mandatory=$false)]
    [switch]$SetDC
)

& .\Prepare-Box.ps1

# Windows Security Audit Categories
if ($SetDC){
    & .\Enable-WinAuditCategories.ps1 -SetDC
}
else{
    & .\Enable-WinAuditCategories.ps1
}

# PowerShell Logging
& .\Enable-PowerShell-Logging.ps1

# Installing Endpoint Agent
& .\Install-Endpoint-Agent.ps1 -EndpointAgent Sysmon

# Set SACLs
& .\Set-SACLs.ps1

# Setting static IP and DNS server IP
if ($ServerAddresses)
{
    & .\Set-StaticIP.ps1 -ServerAddresses $ServerAddresses
}

# *** Powershell execution policy is set to "Bypass" ***
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope LocalMachine -Force

# *** Registry modified to allow storage of wdigest credentials ***
Write-Host "Setting WDigest to use logoncredential.."
Set-ItemProperty -Force -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\WDigest" -Name "UseLogonCredential" -Value "1"

# Configured firewall to allow SMB
Write-Host "Enable File and Printer Sharing"
& netsh advfirewall firewall set rule group="File and Printer Sharing" new enable=Yes

# Setting UAC level to Never Notify
Write-Host "Setting UAC level to Never Notify.."
Set-ItemProperty -Force -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Value 0

# RDP enabled for all Windows hosts
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -name "fDenyTSConnections" -value 0
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"