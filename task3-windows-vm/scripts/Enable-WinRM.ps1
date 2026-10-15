$ErrorActionPreference = "Stop"

# Enable WinRM and configure its service.
Enable-PSRemoting -Force -SkipNetworkProfileCheck

Set-Service -Name WinRM -StartupType Automatic
Start-Service -Name WinRM

# Use Negotiate/NTLM authentication; don't enable Basic or unencrypted traffic.
Set-Item -Path WSMan:\localhost\Service\Auth\Basic -Value $false
Set-Item -Path WSMan:\localhost\Service\Auth\Negotiate -Value $true
Set-Item -Path WSMan:\localhost\Service\AllowUnencrypted -Value $false

# Disable the broad default WinRM firewall rules.
Get-NetFirewallRule -DisplayGroup "Windows Remote Management" `
    -ErrorAction SilentlyContinue |
    Disable-NetFirewallRule

# Permit WinRM only from the host-only adapter on the host.
New-NetFirewallRule `
    -DisplayName "Malware Lab WinRM from host only" `
    -Direction Inbound `
    -Protocol TCP `
    -LocalPort 5985 `
    -RemoteAddress 192.168.57.1 `
    -Action Allow `
    -Profile Any

# Record successful bootstrap.
New-Item -ItemType Directory -Path "C:\ProgramData\MalwareLab" -Force |
    Out-Null
"WinRM bootstrap completed: $(Get-Date -Format o)" |
    Set-Content "C:\ProgramData\MalwareLab\winrm-bootstrap.log"
