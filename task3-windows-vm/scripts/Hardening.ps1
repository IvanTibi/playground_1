$ErrorActionPreference = "Stop"

# Enable Windows Firewall on every profile.
Set-NetFirewallProfile -Profile Domain,Private,Public -Enabled True

# Ensure Microsoft Defender real-time protection is enabled.
Set-MpPreference -DisableRealtimeMonitoring $false

# Disable the legacy SMBv1 protocol.
Disable-WindowsOptionalFeature `
    -Online `
    -FeatureName SMB1Protocol `
    -NoRestart `
    -ErrorAction SilentlyContinue

# Disable Remote Desktop.
Set-ItemProperty `
    -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server" `
    -Name "fDenyTSConnections" `
    -Value 1

# Record the hardening actions.
$logDir = "C:\ProgramData\MalwareLab"
New-Item -ItemType Directory -Path $logDir -Force | Out-Null

@(
    "Hardening completed: $(Get-Date -Format o)"
    "Windows Firewall enabled on all profiles."
    "Microsoft Defender real-time protection requested."
    "SMBv1 disable attempted."
    "Remote Desktop disabled."
) | Set-Content -Path "$logDir\hardening.log" -Encoding UTF8
