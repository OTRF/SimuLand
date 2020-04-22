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

# ******************************************************
#             APT29 Evals Environment                  *   
#                                                      *
# Reference:                                           *
# https://attackevals.mitre.org/APT29/environment.html *
# ******************************************************

# *** WinRM is enabled for all Windows hosts ***
Write-host 'Enabling WinRM..'
winrm quickconfig -q

write-Host "Setting WinRM to start automatically.."
& sc.exe config WinRM start= auto

# *** Powershell execution policy is set to "Bypass" ***
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope LocalMachine -Force

# *** Registry modified to allow storage of wdigest credentials ***
Write-Host "Setting WDigest to use logoncredential.."
Set-ItemProperty -Force -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\WDigest" -Name "UseLogonCredential" -Value "1"

# *** Registry modified to disable Windows Defender ***
# *** # Group Policy modified to disable Windows Defender ***
# Reference: https://docs.microsoft.com/en-us/powershell/module/defender/set-mppreference?view=win10-ps
#
# Disable Archive Scanning
# Indicates whether to scan archive files, such as .zip and .cab files, for malicious and unwanted software.
set-MpPreference -DisableArchiveScanning $true
# Disable Behavior Monitoring
# Indicates whether to enable behavior monitoring.
Set-MpPreference -DisableBehaviorMonitoring $true
# Disable Block at First Seen
# Indicates whether to enable block at first seen.
Set-MpPreference -DisableBlockAtFirstSeen $true
# Disable Catchup Full Scan
# ndicates whether Windows Defender runs catch-up scans for scheduled full scans. A computer can miss a scheduled scan, usually because the computer is turned off at the scheduled time. 
Set-MpPreference -DisableCatchupFullScan $true
# Disable Catchup Quick Scan
# Indicates whether Windows Defender runs catch-up scans for scheduled quick scans. A computer can miss a scheduled scan, usually because the computer is off at the scheduled time. 
Set-MpPreference -DisableCatchupQuickScan $true
# Disable Email Scanning
# Indicates whether Windows Defender parses the mailbox and mail files, according to their specific format, in order to analyze mail bodies and attachments.
Set-MpPreference -DisableEmailScanning $true
# Disable IO AV Protection
# Indicates whether Windows Defender scans all downloaded files and attachments.
Set-MpPreference -DisableIOAVProtection $true
# Disable Intrusion Prevention System
# Indicates whether to configure network protection against exploitation of known vulnerabilities.
Set-MpPreference -DisableIntrusionPreventionSystem $true
# Disable Privacy Mode
# Indicates whether to disable privacy mode. Privacy mode prevents users, other than administrators, from displaying threat history. 
Set-MpPreference -DisablePrivacyMode $true
# Disable Realtime Monitoring
# Indicates whether to use real-time protection
set-MpPreference -DisableRealtimeMonitoring $true
# Disable Removable Drive Scanning
# Indicates whether to scan for malicious and unwanted software in removable drives, such as flash drives, during a full scan.
Set-MpPreference -DisableRemovableDriveScanning $true 
# Disable Restore Points
# Indicates whether to disable scanning of restore points.
Set-MpPreference -DisableRestorePoint $true 
# Disable Scanning Mapped Drives Full Scans
# Indicates whether to scan mapped network drives.
Set-MpPreference -DisableScanningMappedNetworkDrivesForFullScan $true 
# Disable Scanning Network Files
# Indicates whether to scan for network files. 
Set-MpPreference -DisableScanningNetworkFiles $true 
# Disable Script Scans
# Specifies whether to disable the scanning of scripts during malware scans.
Set-MpPreference -DisableScriptScanning $true

# Disable PUA Protection
Set-MpPreference -PUAProtection Disabled
# Never Submit Samples
Set-MpPreference -SubmitSamplesConsent Never 
# Ignore Unknown Threats 
Set-MpPreference -UnknownThreatDefaultAction NoAction
# Ignore Severe Threats
Set-MpPreference -SevereThreatDefaultAction NoAction
# Ignore High Threat 
Set-MpPreference -HighThreatDefaultAction NoAction
# Ignore Moderate Threats
Set-MpPreference -ModerateThreatDefaultAction NoAction
# Ignore Low Threat 
Set-MpPreference -LowThreatDefaultAction NoAction
# Disable MAPS Reporting
Set-MpPreference -MAPSReporting Disabled

# Configured firewall to allow SMB
Write-Host "Enable File and Printer Sharing"
& netsh advfirewall firewall set rule group="File and Printer Sharing" new enable=Yes

# Created an SMB share
# N/A

# Setting UAC level to Never Notify
Write-Host "Setting UAC level to Never Notify.."
Set-ItemProperty -Force -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Value 0

# RDP enabled for all Windows hosts
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -name "fDenyTSConnections" -value 0
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"