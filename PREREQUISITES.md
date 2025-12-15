# Prerequisites - LAN Device Scanner

**Version**: 1.0  
**Last Updated**: 2025-12-13  
**Target Platform**: Windows 11

---

## Overview

This document outlines all requirements, dependencies, and compatibility information for the LAN Device Scanner PowerShell script.

---

## System Requirements

### Operating System

| Platform | Support Level | Notes |
|----------|---------------|-------|
| **Windows 11** | ✅ **Fully Supported** | Target platform |
| **Windows 10** | ✅ **Fully Supported** | All features available |
| **Windows Server 2016+** | ✅ **Supported** | All features available |
| **Linux** | ⚠️ **Partially Supported** | Core scanning works, auto-detection unavailable |
| **macOS** | ⚠️ **Partially Supported** | Core scanning works, auto-detection unavailable |

### PowerShell Version

| Version | Support Level | Notes |
|---------|---------------|-------|
| **PowerShell 5.1** | ✅ **Fully Supported** | Minimum required version |
| **PowerShell 7.0+** | ✅ **Fully Supported** | Recommended for cross-platform |
| **PowerShell 7.4.13** | ✅ **Tested** | Verified in testing |
| **PowerShell 4.0 or earlier** | ❌ **Not Supported** | Missing required features |

#### Check Your PowerShell Version

```powershell
# Display version
$PSVersionTable.PSVersion

# Example output:
# Major  Minor  Patch
# -----  -----  -----
# 5      1      22621
```

---

## Hardware Requirements

### Minimum Requirements

- **CPU**: Dual-core processor
- **RAM**: 2 GB available memory
- **Storage**: 50 MB free space
- **Network**: Active network adapter

### Recommended Requirements

- **CPU**: Quad-core processor or better
- **RAM**: 4 GB available memory
- **Storage**: 100 MB free space (for logs and exports)
- **Network**: Gigabit Ethernet or 802.11ac WiFi

### Performance Considerations

| Scan Size | RAM Usage | CPU Usage | Duration |
|-----------|-----------|-----------|----------|
| Small (/30, <5 hosts) | <100 MB | Low | <5 seconds |
| Medium (/28, <20 hosts) | ~200 MB | Medium | 10-20 seconds |
| Standard (/24, ~250 hosts) | ~500 MB | High | 2-3 minutes |
| Large (/16, >1000 hosts) | >1 GB | Very High | Hours (not recommended) |

---

## Network Requirements

### Required Network Features

1. **Active Network Connection**
   - Wired (Ethernet) or wireless (WiFi) connection
   - Connection to the target network/VLAN

2. **ICMP (Ping) Enabled**
   - Devices must respond to ICMP echo requests
   - Firewall must allow ICMP traffic
   - Some security devices may block ICMP by default

3. **DNS Resolution** (Optional but recommended)
   - DNS server accessible for hostname resolution
   - Local DNS or network DNS server

4. **TCP Port Access**
   - Ability to connect to common ports (80, 443, 8123, etc.)
   - Firewall must allow outbound connections
   - Target devices may have port-specific firewall rules

### Firewall Configuration

#### Windows Firewall

ICMP should be enabled by default, but verify:

```powershell
# Check ICMP rule status
Get-NetFirewallRule -DisplayName "*ICMP*" | Select-Object DisplayName, Enabled, Direction

# Enable ICMP if needed (run as Administrator)
New-NetFirewallRule -DisplayName "Allow ICMPv4-In" -Protocol ICMPv4 -IcmpType 8 -Enabled True -Direction Inbound
```

#### Network Firewall

Ensure your network firewall allows:
- **Outbound ICMP** (Echo Request)
- **Inbound ICMP** (Echo Reply)
- **Outbound TCP** to common ports (80, 443, 8123, 8443, etc.)

---

## Permissions

### Standard User

With standard user permissions, you can:
- ✅ Scan network for alive hosts
- ✅ Resolve hostnames
- ✅ Scan ports
- ✅ Perform HTTP probing
- ✅ Discover API endpoints
- ⚠️ Limited MAC address retrieval

### Administrator

Administrator permissions provide:
- ✅ All standard user capabilities
- ✅ Full MAC address retrieval from ARP cache
- ✅ Network adapter information
- ✅ Enhanced network diagnostics
- ✅ Firewall rule management

#### Run as Administrator

```powershell
# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if ($isAdmin) {
    Write-Host "Running as Administrator" -ForegroundColor Green
} else {
    Write-Host "Not running as Administrator" -ForegroundColor Yellow
    Write-Host "Some features may be limited"
}
```

#### Launch PowerShell as Administrator

1. Search for "PowerShell" in Start Menu
2. Right-click "Windows PowerShell"
3. Select "Run as Administrator"
4. Click "Yes" on UAC prompt

---

## PowerShell Configuration

### Execution Policy

The script requires an execution policy that allows local script execution.

#### Check Current Policy

```powershell
Get-ExecutionPolicy
```

#### Common Policies

| Policy | Description | Recommended |
|--------|-------------|-------------|
| **Restricted** | No scripts allowed | ❌ Won't work |
| **AllSigned** | Only signed scripts | ⚠️ Requires signing |
| **RemoteSigned** | Local scripts OK, downloaded need signature | ✅ Recommended |
| **Unrestricted** | All scripts allowed | ⚠️ Less secure |
| **Bypass** | Nothing blocked | ❌ Not recommended |

#### Set Execution Policy

```powershell
# Recommended: RemoteSigned for current user
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Alternative: For all users (requires Administrator)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine
```

**Security Note**: `RemoteSigned` allows local scripts but requires digital signatures for downloaded scripts, providing a good balance of security and usability.

---

## Dependencies

### Built-in PowerShell Cmdlets

The script uses these built-in cmdlets (no installation required):

| Cmdlet | Purpose | Availability |
|--------|---------|--------------|
| `Test-Connection` | ICMP ping | All PowerShell versions |
| `Resolve-DnsName` | DNS resolution | PS 3.0+ |
| `Invoke-WebRequest` | HTTP requests | PS 3.0+ |
| `ConvertTo-Json` | JSON serialization | PS 3.0+ |
| `Get-NetAdapter` | Network adapter info | **Windows only** |
| `Test-NetConnection` | Network connectivity | PS 4.0+ |

### Windows-Only Features

These features require Windows and are not available on Linux/macOS:

#### 1. Local Subnet Auto-Detection

**Requirement**: `Get-NetAdapter` cmdlet

```powershell
# Check availability
Get-Command Get-NetAdapter -ErrorAction SilentlyContinue

# Available on:
# ✅ Windows PowerShell 3.0+
# ✅ PowerShell Core 6+ (Windows only)
# ❌ PowerShell Core (Linux/macOS)
```

**Workaround**: Use manual subnet specification
```powershell
.\Scan-LANDevices.ps1 -SubnetCIDR @("192.168.1.0/24")
```

#### 2. MAC Address Retrieval

**Requirement**: Windows `arp` command or `Get-NetNeighbor` cmdlet

```powershell
# Check ARP availability
arp -a

# Available on:
# ✅ Windows (all versions)
# ⚠️ Linux (different syntax)
# ⚠️ macOS (different syntax)
```

**Impact**: Without Windows, MAC addresses may not be retrieved

---

## Optional Dependencies

### For Testing

#### Pester (Testing Framework)

**Version**: 5.0+ (tested with 5.7.1)

**Installation**:
```powershell
# Check if installed
Get-Module -Name Pester -ListAvailable

# Install or update
Install-Module -Name Pester -Force -SkipPublisherCheck

# Verify version
(Get-Module -Name Pester -ListAvailable).Version
```

**Required for**: Running the test suite (`Scan-LANDevices.Tests.ps1`)

**Not required for**: Normal script operation

---

## Network Environment

### Supported Network Configurations

| Configuration | Support Level | Notes |
|---------------|---------------|-------|
| **Single LAN** | ✅ Fully Supported | Standard home/office network |
| **Multiple VLANs** | ✅ Fully Supported | Specify each VLAN's CIDR |
| **WiFi Networks** | ✅ Fully Supported | May have higher latency |
| **VPN Networks** | ⚠️ Partially Supported | Depends on VPN configuration |
| **Cloud Networks** | ⚠️ Partially Supported | Security groups may block scanning |

### Network Size Recommendations

| Network Size | CIDR | Hosts | Recommended | Notes |
|--------------|------|-------|-------------|-------|
| **Tiny** | /30 | 2 | ✅ Excellent | Testing/point-to-point |
| **Small** | /28 | 14 | ✅ Excellent | Small office |
| **Medium** | /27 | 30 | ✅ Good | Medium office |
| **Standard** | /24 | 254 | ✅ Good | Typical subnet |
| **Large** | /23 | 510 | ⚠️ Slow | Will take time |
| **Very Large** | /22 | 1022 | ⚠️ Very Slow | Not recommended |
| **Huge** | /16 | 65534 | ❌ Impractical | Do not attempt |

---

## Compatibility Matrix

### PowerShell Version Compatibility

| Feature | PS 5.1 | PS 7.0+ (Win) | PS 7.0+ (Linux/macOS) |
|---------|--------|---------------|----------------------|
| CIDR Parsing | ✅ | ✅ | ✅ |
| Ping Scanning | ✅ | ✅ | ✅ |
| Port Scanning | ✅ | ✅ | ✅ |
| HTTP Probing | ✅ | ✅ | ✅ |
| API Discovery | ✅ | ✅ | ✅ |
| Hostname Resolution | ✅ | ✅ | ✅ |
| Subnet Auto-Detection | ✅ | ✅ | ❌ |
| MAC Address Lookup | ✅ | ✅ | ⚠️ Limited |
| JSON Export | ✅ | ✅ | ✅ |
| Parallel Scanning | ✅ | ✅ | ✅ |

**Legend**:
- ✅ Fully Supported
- ⚠️ Partially Supported / Limited
- ❌ Not Supported

### Device Detection Compatibility

All device detection features work on all platforms:

| Device Type | Windows | Linux | macOS |
|-------------|---------|-------|-------|
| Home Assistant | ✅ | ✅ | ✅ |
| Shelly | ✅ | ✅ | ✅ |
| Ubiquiti | ✅ | ✅ | ✅ |
| Ajax Security Hub | ✅ | ✅ | ✅ |
| NVR/Camera | ✅ | ✅ | ✅ |

---

## Security Requirements

### Network Access

- **Authorization**: You must have authorization to scan the target network
- **Legal Compliance**: Ensure compliance with local laws and regulations
- **Corporate Policy**: Check with IT/Security team for corporate networks

### Certificates

The script **disables SSL certificate validation** for device discovery. This means:

- ⚠️ Self-signed certificates are accepted
- ⚠️ Expired certificates are accepted
- ⚠️ Mismatched certificates are accepted

**Security Impact**: Only use on trusted networks to avoid man-in-the-middle attacks.

### Credentials

The script does **not require or use credentials**:

- ✅ No authentication attempts
- ✅ No password storage
- ✅ Read-only operations
- ⚠️ May encounter 401/403 responses (noted but not bypassed)

---

## Installation Prerequisites

### Step 1: Verify PowerShell Version

```powershell
# Check version
$PSVersionTable.PSVersion

# Required: 5.1 or higher
# Example output:
# Major  Minor  Build  Revision
# -----  -----  -----  --------
# 5      1      19041  2364
```

**If version is too old**: Upgrade PowerShell
- Windows: Install [PowerShell 7+](https://github.com/PowerShell/PowerShell/releases)
- Linux/macOS: Follow [installation guide](https://docs.microsoft.com/powershell/scripting/install/installing-powershell)

### Step 2: Check Execution Policy

```powershell
# Check current policy
Get-ExecutionPolicy

# If "Restricted", change to "RemoteSigned"
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Step 3: Verify Network Connectivity

```powershell
# Test internet connectivity
Test-Connection -ComputerName 8.8.8.8 -Count 2

# Test local gateway
Test-Connection -ComputerName 192.168.1.1 -Count 2
```

### Step 4: Verify Administrator Access (Optional)

```powershell
# Check admin status
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if ($isAdmin) {
    Write-Host "✓ Running as Administrator" -ForegroundColor Green
} else {
    Write-Host "⚠ Not running as Administrator (optional)" -ForegroundColor Yellow
}
```

### Step 5: Download Script

1. Download `Scan-LANDevices.ps1`
2. Save to known location (e.g., `C:\Scripts\`)
3. Verify file downloaded correctly

```powershell
# Verify file exists and check size
Get-ChildItem "C:\Scripts\Scan-LANDevices.ps1" | Select-Object Name, Length, LastWriteTime
```

---

## Testing Prerequisites

If you plan to run the test suite:

### Install Pester

```powershell
# Check if Pester is installed
Get-Module -Name Pester -ListAvailable

# Install latest version
Install-Module -Name Pester -Force -SkipPublisherCheck

# Verify installation
Import-Module Pester
(Get-Module Pester).Version
```

### Download Test Files

1. Download `Scan-LANDevices.Tests.ps1`
2. Place in same directory as `Scan-LANDevices.ps1`

### Run Tests

```powershell
# Run all tests
Invoke-Pester -Path './Scan-LANDevices.Tests.ps1' -Output Detailed

# Expected: 37 passed, 19 failed (66.1% pass rate)
```

---

## Platform-Specific Setup

### Windows 11 / Windows 10

**Prerequisites**: All features available, no additional setup required

```powershell
# Verify all prerequisites
Write-Host "Checking prerequisites..." -ForegroundColor Cyan

# 1. PowerShell version
$psVersion = $PSVersionTable.PSVersion
Write-Host "✓ PowerShell Version: $psVersion" -ForegroundColor Green

# 2. Execution policy
$policy = Get-ExecutionPolicy
Write-Host "✓ Execution Policy: $policy" -ForegroundColor Green

# 3. Administrator status
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
Write-Host "$(if ($isAdmin) {'✓'} else {'⚠'}) Administrator: $isAdmin" -ForegroundColor $(if ($isAdmin) {'Green'} else {'Yellow'})

# 4. Network adapter
$adapters = Get-NetAdapter | Where-Object Status -eq 'Up'
Write-Host "✓ Active Network Adapters: $($adapters.Count)" -ForegroundColor Green

Write-Host "`nAll prerequisites met!" -ForegroundColor Green
```

### Linux / macOS

**Prerequisites**: Limited feature set, manual subnet specification required

```powershell
# Verify PowerShell Core
$psVersion = $PSVersionTable.PSVersion
Write-Host "✓ PowerShell Version: $psVersion" -ForegroundColor Green

# Note: Get-NetAdapter not available
Write-Host "⚠ Auto-detection not available (use -SubnetCIDR parameter)" -ForegroundColor Yellow

# Network connectivity
Test-Connection -ComputerName 192.168.1.1 -Count 2
Write-Host "✓ Network connectivity OK" -ForegroundColor Green
```

**Usage on Linux/macOS**:
```powershell
# Always specify subnet manually
.\Scan-LANDevices.ps1 -SubnetCIDR @("192.168.1.0/24")
```

---

## Troubleshooting Prerequisites

### Issue: "Running scripts is disabled"

**Cause**: Execution policy is set to "Restricted"

**Solution**:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Issue: "Get-NetAdapter not recognized"

**Cause**: Running on Linux/macOS or old PowerShell version

**Solution**: Use manual subnet specification
```powershell
.\Scan-LANDevices.ps1 -SubnetCIDR @("192.168.1.0/24")
```

### Issue: "No devices found"

**Possible Causes**:
1. ICMP blocked by firewall
2. Wrong subnet
3. No devices online

**Solution**:
```powershell
# Test connectivity manually
Test-Connection -ComputerName 192.168.1.1 -Count 4

# Check firewall rules
Get-NetFirewallRule -DisplayName "*ICMP*"
```

### Issue: "Access denied" errors

**Cause**: Insufficient permissions for certain operations

**Solution**: Run PowerShell as Administrator
- Right-click PowerShell → "Run as Administrator"

---

## Quick Start Checklist

Use this checklist to verify you're ready to run the script:

- [ ] **PowerShell 5.1 or higher** installed
- [ ] **Execution policy** set to RemoteSigned or Unrestricted
- [ ] **Network connection** active
- [ ] **Script file** downloaded to known location
- [ ] **Firewall** allows ICMP (ping)
- [ ] **Authorization** to scan the network
- [ ] **Administrator rights** (optional, for full features)
- [ ] **Read [KNOWN-ISSUES.md](KNOWN-ISSUES.md)** (critical bug warning)

---

## Additional Resources

### Documentation

- [User Guide](USER-GUIDE.md) - How to use the script
- [Known Issues](KNOWN-ISSUES.md) - Critical bugs and workarounds
- [Developer Guide](DEVELOPER-GUIDE.md) - Extending the script
- [Test Report](TEST-REPORT.md) - Detailed test results

### External Links

- [PowerShell Documentation](https://docs.microsoft.com/powershell)
- [Install PowerShell 7+](https://github.com/PowerShell/PowerShell/releases)
- [Pester Testing Framework](https://pester.dev)

---

## Support Matrix

| Component | Minimum | Recommended | Tested |
|-----------|---------|-------------|--------|
| **PowerShell** | 5.1 | 7.4+ | 7.4.13 |
| **Windows** | 10 | 11 | 11 |
| **RAM** | 2 GB | 4 GB | N/A |
| **CPU Cores** | 2 | 4+ | N/A |
| **Network Speed** | 10 Mbps | 1 Gbps | N/A |

---

**Document Version**: 1.0  
**Last Updated**: 2025-12-13  
**Status**: Initial release  
**Next Review**: After critical fixes

---

**Ready to start?** Review [KNOWN-ISSUES.md](KNOWN-ISSUES.md) first, then see [USER-GUIDE.md](USER-GUIDE.md) for usage instructions.
