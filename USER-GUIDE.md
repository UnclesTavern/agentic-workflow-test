# User Guide - LAN Device Scanner

**Version**: 1.0  
**Last Updated**: 2025-12-13  
**Target Platform**: Windows 11  
**PowerShell Version**: 5.1+

---

## ⚠️ IMPORTANT: Read Before Using

**PRODUCTION READINESS**: This script contains a **critical bug** that prevents full execution. Please read the [Known Issues](KNOWN-ISSUES.md) document before use, particularly Issue #1 regarding the `$host` variable conflict.

**Current Status**: ⚠️ **NOT PRODUCTION READY** - Requires bug fixes  
**Test Coverage**: 66.1% pass rate (37/56 tests)  
**Recommended Action**: Apply fixes from [Known Issues](KNOWN-ISSUES.md) before production use

---

## Table of Contents

1. [Quick Start](#quick-start)
2. [Prerequisites](#prerequisites)
3. [Installation](#installation)
4. [Basic Usage](#basic-usage)
5. [Advanced Usage](#advanced-usage)
6. [Understanding Results](#understanding-results)
7. [Device Types Detected](#device-types-detected)
8. [Performance Tuning](#performance-tuning)
9. [Troubleshooting](#troubleshooting)
10. [Best Practices](#best-practices)
11. [Examples](#examples)
12. [FAQ](#faq)

---

## Quick Start

⚠️ **WARNING**: Due to the critical `$host` variable bug, full automatic scanning is currently not functional. Use individual functions or apply the fix first.

### Temporary Workaround (Until Bug is Fixed)

Use individual functions for specific tasks:

```powershell
# Import the script functions
. .\Scan-LANDevices.ps1

# Test if a host is alive
$isAlive = Test-HostAlive -IPAddress "192.168.1.100"

# Get device hostname
$hostname = Get-DeviceHostname -IPAddress "192.168.1.100"
if ($hostname) {
    Write-Host "Device: $hostname"
}

# Scan for open ports
$ports = Get-OpenPorts -IPAddress "192.168.1.100"
if ($ports) {
    Write-Host "Open ports: $($ports -join ', ')"
}
```

### Once Bug is Fixed

```powershell
# Simple scan with auto-detection
.\Scan-LANDevices.ps1

# Scan specific subnet
.\Scan-LANDevices.ps1 -SubnetCIDR @("192.168.1.0/24")
```

---

## Prerequisites

See [PREREQUISITES.md](PREREQUISITES.md) for detailed requirements.

### Essential Requirements

- ✅ **Operating System**: Windows 11 (or Windows 10)
- ✅ **PowerShell**: Version 5.1 or higher
- ✅ **Permissions**: Administrator rights (recommended)
- ✅ **Network**: Active LAN connection
- ✅ **Firewall**: ICMP (ping) enabled

### Optional Requirements

- Network security scanning permissions
- Access to device management interfaces
- Admin notification for network scanning

---

## Installation

### Step 1: Download the Script

Download `Scan-LANDevices.ps1` to your local machine (e.g., `C:\Scripts\`).

### Step 2: Set Execution Policy

If this is your first time running PowerShell scripts:

```powershell
# Check current policy
Get-ExecutionPolicy

# If needed, set policy (run PowerShell as Administrator)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**Explanation**:
- `RemoteSigned`: Allows local scripts, requires signature for downloaded scripts
- `CurrentUser`: Only affects your user account

### Step 3: Verify Installation

```powershell
# Navigate to script directory
cd C:\Scripts

# Test script loads without errors
Get-Help .\Scan-LANDevices.ps1
```

---

## Basic Usage

### Automatic Subnet Detection (Windows Only)

⚠️ **Currently Blocked by Bug #1** - See [Known Issues](KNOWN-ISSUES.md)

```powershell
# Auto-detect and scan local network
.\Scan-LANDevices.ps1
```

**What it does**:
1. Detects active network adapters
2. Identifies local subnets
3. Scans all subnets for alive hosts
4. Identifies device types
5. Discovers API endpoints
6. Exports results to JSON

### Manual Subnet Specification (Cross-Platform Compatible)

```powershell
# Scan specific subnet
.\Scan-LANDevices.ps1 -SubnetCIDR @("192.168.1.0/24")

# Scan multiple subnets
.\Scan-LANDevices.ps1 -SubnetCIDR @("192.168.1.0/24", "192.168.2.0/24", "10.0.0.0/24")
```

**Benefits**:
- ✅ Works on Windows, Linux, and macOS
- ✅ Avoids auto-detection issues
- ✅ More control over scan scope
- ✅ Faster (no detection overhead)

### Verbose Output

```powershell
# See detailed progress information
.\Scan-LANDevices.ps1 -SubnetCIDR @("192.168.1.0/24") -Verbose
```

---

## Advanced Usage

### Performance Tuning

#### Adjust Timeout

```powershell
# Fast network - reduce timeout
.\Scan-LANDevices.ps1 -SubnetCIDR @("192.168.1.0/24") -Timeout 50

# Slow network - increase timeout
.\Scan-LANDevices.ps1 -SubnetCIDR @("192.168.1.0/24") -Timeout 300
```

**Timeout Guidelines**:
- **Fast LAN** (Gigabit): 50-100ms
- **Standard LAN** (100Mbps): 100-200ms
- **WiFi**: 200-500ms
- **Slow/Remote**: 500-1000ms

#### Adjust Thread Count

```powershell
# More threads - faster scan (good hardware)
.\Scan-LANDevices.ps1 -SubnetCIDR @("192.168.1.0/24") -Threads 100

# Fewer threads - lower system load
.\Scan-LANDevices.ps1 -SubnetCIDR @("192.168.1.0/24") -Threads 25
```

**Thread Count Guidelines**:
- **Small network** (<50 hosts): 25-50 threads
- **Medium network** (50-500 hosts): 50-75 threads
- **Large network** (>500 hosts): 75-100 threads
- **Low-power device**: 10-25 threads

### Combining Parameters

```powershell
# Optimized for fast scan on gigabit network
.\Scan-LANDevices.ps1 `
    -SubnetCIDR @("192.168.1.0/24", "192.168.2.0/24") `
    -Timeout 50 `
    -Threads 100 `
    -Verbose
```

### Using Individual Functions

Import and use specific functions:

```powershell
# Import all functions
. .\Scan-LANDevices.ps1

# Use specific functions
$cidr = ConvertFrom-CIDR -CIDR "192.168.1.0/24"
Write-Host "Network will scan $($cidr.TotalHosts) hosts"

# Test connectivity
$devices = @("192.168.1.1", "192.168.1.100", "192.168.1.200")
foreach ($ip in $devices) {
    $alive = Test-HostAlive -IPAddress $ip -Timeout 100
    if ($alive) {
        Write-Host "✓ $ip is online" -ForegroundColor Green
        
        # Get additional info
        $hostname = Get-DeviceHostname -IPAddress $ip
        if ($hostname) {
            Write-Host "  Hostname: $hostname"
        }
    }
}
```

---

## Understanding Results

### Console Output

Results are organized by device type:

```
=== Device Scan Results ===

Scanned X subnets, found Y alive hosts, identified Z devices

--- IoT Hub (N devices) ---

IP Address: 192.168.1.100
  Hostname: homeassistant.local
  MAC Address: AA:BB:CC:DD:EE:FF
  Sub Type: Home Assistant
  Confidence: 80%
  Open Ports: 8123, 80, 443
  API Endpoints:
    - http://192.168.1.100:8123/api/ (Status: 200)
    - http://192.168.1.100:8123/auth (Status: 405)
  Evidence:
    - Port 8123 is open (Home Assistant default)
    - Home Assistant identified in HTTP response
```

### Output Fields Explained

| Field | Description | Example |
|-------|-------------|---------|
| **IP Address** | Device's IP address | 192.168.1.100 |
| **Hostname** | DNS hostname (if resolvable) | homeassistant.local |
| **MAC Address** | Hardware MAC address | AA:BB:CC:DD:EE:FF |
| **Device Type** | General device category | IoT Hub, Security Device |
| **Sub Type** | Specific device identification | Home Assistant, Shelly |
| **Confidence** | Detection confidence (%) | 80% |
| **Open Ports** | TCP ports responding | 80, 443, 8123 |
| **API Endpoints** | Discovered API URLs | /api/, /api/config |
| **Evidence** | Detection indicators | Port signatures, HTTP headers |

### Confidence Scoring

The script uses evidence-based confidence scoring:

| Confidence | Meaning | Reliability |
|------------|---------|-------------|
| **90-100%** | Very high confidence | Highly reliable |
| **70-89%** | High confidence | Reliable |
| **50-69%** | Medium confidence | Likely correct |
| **30-49%** | Low confidence | Uncertain |
| **<30%** | Very low | May be incorrect |

**Threshold**: Devices are only categorized if confidence ≥ 50% (except NVR: ≥ 40%)

### JSON Export

Results are automatically exported to: `DeviceScan_YYYYMMDD_HHMMSS.json`

```json
[
  {
    "IPAddress": "192.168.1.100",
    "Hostname": "homeassistant.local",
    "MACAddress": "AA:BB:CC:DD:EE:FF",
    "DeviceType": "IoT Hub",
    "SubType": "Home Assistant",
    "Confidence": 80,
    "Evidence": [
      "Port 8123 is open (Home Assistant default)",
      "Home Assistant identified in HTTP response"
    ],
    "OpenPorts": [8123, 80, 443],
    "APIEndpoints": [
      {
        "URL": "http://192.168.1.100:8123/api/",
        "StatusCode": 200,
        "ContentType": "application/json"
      }
    ]
  }
]
```

---

## Device Types Detected

### IoT Hubs

#### Home Assistant

**Detection Method**:
- Port 8123 open (default port)
- HTTP response contains "Home Assistant" in title/headers
- Specific API endpoints respond

**API Endpoints Discovered**:
- `/api/` - Main API endpoint
- `/api/config` - Configuration endpoint
- `/api/states` - State information
- `/auth` - Authentication endpoint

**Confidence Threshold**: 50%

**Example Evidence**:
- "Port 8123 is open (Home Assistant default)"
- "Home Assistant identified in HTTP response"

---

### IoT Devices

#### Shelly Devices

**Detection Method**:
- HTTP response contains "Shelly" in title/headers
- `/shelly` endpoint responds
- Specific API signatures

**API Endpoints Discovered**:
- `/shelly` - Device information
- `/status` - Device status
- `/settings` - Device settings
- `/rpc` - RPC interface (newer models)

**Confidence Threshold**: 50%

**Example Evidence**:
- "HTTP response contains 'Shelly'"
- "/shelly endpoint found"

---

### Security Devices

#### Ubiquiti (UniFi)

**Detection Method**:
- Port 8443 open (UniFi Controller)
- HTTP response contains UniFi signatures
- Specific API patterns

**API Endpoints Discovered**:
- `/api/auth` - Authentication
- `/api/system` - System information
- `/api/s/default` - Site configuration

**Confidence Threshold**: 50%

#### Ajax Security Hub

**Detection Method**:
- HTTP response contains "Ajax" or "Ajax Systems"
- Specific header patterns
- Device-specific signatures

**API Endpoints Discovered**:
- `/api/panel` - Panel information
- `/api/devices` - Connected devices

**Confidence Threshold**: 50%

#### NVR/Camera Devices

**Detection Method**:
- Port 554 open (RTSP protocol)
- Video streaming port signature

**Confidence Threshold**: 40% (lower due to generic port)

**Note**: May detect any RTSP-capable device, not just cameras

---

## Performance Tuning

### Scan Duration Expectations

Based on testing and estimates:

| Network Size | Host Count | Estimated Time | Notes |
|--------------|------------|----------------|-------|
| /30 subnet | 2 | <5 seconds | ✅ Tested |
| /28 subnet | 14 | 10-20 seconds | Estimated |
| /27 subnet | 30 | 20-40 seconds | Estimated |
| /24 subnet | 254 | 2-3 minutes | Estimated |
| /16 subnet | 65,534 | Hours | Not recommended |

**Per-Device Time**:
- Ping: 50-200ms
- Port scan: 1-3 seconds
- HTTP probe: 2-5 seconds
- API discovery: 5-15 seconds (if APIs present)
- **Total per device**: 5-20 seconds

### Optimization Tips

#### For Fast Scans

```powershell
# Optimize for speed
.\Scan-LANDevices.ps1 `
    -SubnetCIDR @("192.168.1.0/24") `
    -Timeout 50 `
    -Threads 100
```

**Best for**:
- Fast, modern networks (Gigabit+)
- Powerful hardware (multi-core CPU)
- Time-sensitive scans

#### For Reliable Scans

```powershell
# Optimize for reliability
.\Scan-LANDevices.ps1 `
    -SubnetCIDR @("192.168.1.0/24") `
    -Timeout 300 `
    -Threads 25
```

**Best for**:
- Slower networks (WiFi, legacy hardware)
- Unreliable connections
- Low-power devices
- Maximizing device discovery

#### For Resource-Constrained Systems

```powershell
# Minimize system impact
.\Scan-LANDevices.ps1 `
    -SubnetCIDR @("192.168.1.0/24") `
    -Timeout 200 `
    -Threads 10
```

**Best for**:
- Laptops on battery
- Older computers
- Systems running other tasks
- Minimal network impact

---

## Troubleshooting

### Common Issues and Solutions

#### Issue: "Cannot overwrite variable Host" Error

**Cause**: Critical bug #1 - `$host` variable conflict  
**Status**: Known issue, unfixed in current version  
**Solution**: Apply fix from [Known Issues](KNOWN-ISSUES.md) or use individual functions

```powershell
# WORKAROUND: Use individual functions
. .\Scan-LANDevices.ps1
$devices = Invoke-SubnetScan -CIDR "192.168.1.0/24"
foreach ($ip in $devices) {
    Get-DeviceInformation -IPAddress $ip
}
```

---

#### Issue: No Devices Found

**Possible Causes**:
1. Firewall blocking ICMP
2. Wrong subnet specified
3. Timeout too short
4. Devices configured to not respond to ping

**Solutions**:

```powershell
# 1. Check firewall allows ICMP
Test-Connection -ComputerName 192.168.1.1

# 2. Verify correct subnet
ipconfig /all  # Check your network configuration

# 3. Increase timeout
.\Scan-LANDevices.ps1 -SubnetCIDR @("192.168.1.0/24") -Timeout 500

# 4. Test specific device manually
Test-HostAlive -IPAddress "192.168.1.100" -Timeout 1000
```

---

#### Issue: Function Returns Null

**Cause**: Known issue #2 - Functions return null instead of empty values  
**Status**: Known issue, workaround required  
**Solution**: Always check for null before using results

```powershell
# SAFE: Check for null
$hostname = Get-DeviceHostname -IPAddress "192.168.1.100"
if ($hostname) {
    Write-Host "Hostname: $hostname"
} else {
    Write-Host "Hostname: Unknown"
}

# SAFE: Provide defaults
$ports = Get-OpenPorts -IPAddress "192.168.1.100"
if (-not $ports) { $ports = @() }
```

---

#### Issue: Scan is Very Slow

**Possible Causes**:
1. Too many threads
2. Network congestion
3. Slow devices
4. HTTP timeouts on unreachable devices

**Solutions**:

```powershell
# Reduce threads for slower networks
.\Scan-LANDevices.ps1 -SubnetCIDR @("192.168.1.0/24") -Threads 25

# Reduce timeout for faster failure detection
.\Scan-LANDevices.ps1 -SubnetCIDR @("192.168.1.0/24") -Timeout 50

# Scan smaller subnet ranges
.\Scan-LANDevices.ps1 -SubnetCIDR @("192.168.1.0/25")  # Only 126 hosts
```

---

#### Issue: Permission Errors

**Cause**: Insufficient privileges for network operations  
**Solution**: Run PowerShell as Administrator

```powershell
# Check if running as admin
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "Please run PowerShell as Administrator" -ForegroundColor Red
}
```

---

#### Issue: Device Not Identified Correctly

**Possible Causes**:
1. Device has custom configuration
2. Firmware version differs from tested
3. Device uses non-standard ports
4. Confidence threshold not met

**Solutions**:

```powershell
# Check what evidence was collected
# Look in console output under "Evidence" section

# Manual verification
$ports = Get-OpenPorts -IPAddress "192.168.1.100"
$httpInfo = Get-HTTPDeviceInfo -IPAddress "192.168.1.100" -Port 80

# Check raw HTTP response
Invoke-WebRequest -Uri "http://192.168.1.100" -TimeoutSec 5
```

**Note**: Unknown devices are still listed under "Network Device" category

---

#### Issue: Auto-Detection Not Working (Linux/macOS)

**Cause**: `Get-NetAdapter` is Windows-only  
**Status**: Expected behavior  
**Solution**: Use manual subnet specification

```powershell
# Manually specify subnets (works everywhere)
.\Scan-LANDevices.ps1 -SubnetCIDR @("192.168.1.0/24")
```

---

## Best Practices

### Before Scanning

1. **✅ Notify network administrators** - Scanning may trigger security alerts
2. **✅ Choose appropriate time** - Avoid business-critical hours
3. **✅ Test on small subnet first** - Validate configuration
4. **✅ Check firewall rules** - Ensure ICMP is allowed
5. **✅ Review known issues** - See [KNOWN-ISSUES.md](KNOWN-ISSUES.md)

### During Scanning

1. **✅ Monitor system resources** - Watch CPU and network usage
2. **✅ Check progress output** - Ensure scan is progressing
3. **✅ Be patient** - Large networks take time
4. **✅ Avoid other network-intensive tasks** - May affect scan accuracy

### After Scanning

1. **✅ Review results carefully** - Check confidence scores
2. **✅ Validate critical devices** - Manually verify important identifications
3. **✅ Save JSON export** - Archive for comparison
4. **✅ Document unexpected results** - Note for future scans
5. **✅ Report issues** - Help improve the script

### Security Best Practices

1. **✅ Use on trusted networks only** - Don't scan unknown networks
2. **✅ Understand legal implications** - Ensure authorization
3. **✅ Review certificate warnings** - Script bypasses SSL validation
4. **✅ Don't store sensitive data** - JSON export may contain network topology
5. **✅ Secure scan results** - Protect exported files appropriately

---

## Examples

### Example 1: Basic Home Network Scan

```powershell
# Scan typical home network
.\Scan-LANDevices.ps1 -SubnetCIDR @("192.168.1.0/24") -Verbose
```

**Expected output**: Discover router, smart devices, computers, phones, etc.

---

### Example 2: Multi-Subnet Office Scan

```powershell
# Scan multiple office VLANs
.\Scan-LANDevices.ps1 -SubnetCIDR @(
    "192.168.10.0/24",  # Management VLAN
    "192.168.20.0/24",  # IoT VLAN
    "192.168.30.0/24"   # Guest VLAN
) -Threads 75 -Verbose
```

---

### Example 3: Fast Discovery Scan

```powershell
# Quick scan to find alive hosts only
$aliveHosts = Invoke-SubnetScan -CIDR "192.168.1.0/24" -Timeout 50 -Threads 100
Write-Host "Found $($aliveHosts.Count) alive hosts"
$aliveHosts | ForEach-Object { Write-Host "  - $_" }
```

---

### Example 4: Targeted Device Investigation

```powershell
# Import functions
. .\Scan-LANDevices.ps1

# Investigate specific device
$ip = "192.168.1.100"
Write-Host "`nInvestigating $ip..." -ForegroundColor Cyan

$hostname = Get-DeviceHostname -IPAddress $ip
Write-Host "Hostname: $(if ($hostname) {$hostname} else {'Unknown'})"

$mac = Get-DeviceMACAddress -IPAddress $ip
Write-Host "MAC: $(if ($mac) {$mac} else {'Unknown'})"

$ports = Get-OpenPorts -IPAddress $ip
if ($ports) {
    Write-Host "Open Ports: $($ports -join ', ')"
}

$apis = Find-APIEndpoints -IPAddress $ip -OpenPorts $ports
if ($apis) {
    Write-Host "`nAPI Endpoints:"
    $apis | ForEach-Object { Write-Host "  - $($_.URL) [$($_.StatusCode)]" }
}
```

---

### Example 5: Monitoring Scan Progress

```powershell
# Scan with detailed progress tracking
Write-Host "Starting scan at $(Get-Date -Format 'HH:mm:ss')" -ForegroundColor Green

.\Scan-LANDevices.ps1 `
    -SubnetCIDR @("192.168.1.0/24") `
    -Timeout 100 `
    -Threads 50 `
    -Verbose

Write-Host "`nScan completed at $(Get-Date -Format 'HH:mm:ss')" -ForegroundColor Green
Write-Host "Check JSON export for detailed results"
```

---

### Example 6: Scheduled Regular Scans

```powershell
# Script for scheduled task (e.g., daily network inventory)
$outputPath = "C:\NetworkScans\$(Get-Date -Format 'yyyyMMdd')_scan.json"

# Run scan
.\Scan-LANDevices.ps1 -SubnetCIDR @("192.168.1.0/24") -Threads 50

# Move JSON to archive location
Move-Item -Path "DeviceScan_*.json" -Destination $outputPath

# Optional: Send email notification
# Send-MailMessage -To "admin@example.com" -Subject "Network Scan Complete" -Body "Scan results: $outputPath" -SmtpServer "smtp.example.com"
```

---

## FAQ

### Q: Can I use this on non-Windows systems?

**A**: Partially. Core scanning works on Linux/macOS, but auto-detection and MAC address lookup require Windows. Use manual subnet specification:

```powershell
.\Scan-LANDevices.ps1 -SubnetCIDR @("192.168.1.0/24")
```

---

### Q: Why is my scan taking so long?

**A**: Large networks with many devices take time. Factors:
- Network size (254 hosts in /24 can take 2-3 minutes)
- Per-device discovery (5-20 seconds each)
- HTTP timeouts on unresponsive devices
- Thread count (default 50)

**Solution**: Increase threads or reduce timeout for faster scans.

---

### Q: How accurate is device identification?

**A**: Depends on confidence score:
- **High (70%+)**: Very reliable, multiple indicators matched
- **Medium (50-69%)**: Likely correct, some indicators matched
- **Low (<50%)**: Not categorized, listed as "Network Device"

Always verify critical device identifications manually.

---

### Q: Can I add support for new device types?

**A**: Yes! See [DEVELOPER-GUIDE.md](DEVELOPER-GUIDE.md) for instructions on extending the script with new device types.

---

### Q: Will this scan trigger security alerts?

**A**: Possibly. Network scanning may be logged by:
- Intrusion Detection Systems (IDS)
- Firewall logs
- Security Information and Event Management (SIEM) systems

**Recommendation**: Notify network/security teams before scanning.

---

### Q: Is this safe to use?

**A**: With caveats:
- ✅ Script only performs read-only operations (no configuration changes)
- ✅ No brute-force authentication attempts
- ⚠️ Bypasses SSL certificate validation (for device discovery)
- ⚠️ Generates significant network traffic
- ⚠️ Should only be used on networks you have authorization to scan

**Never scan networks without proper authorization.**

---

### Q: What's the difference between this and nmap?

**A**: 
- **nmap**: General-purpose, comprehensive, complex
- **This script**: Specialized for IoT/home devices, simpler, Windows-friendly
- **Use case**: This script is optimized for discovering and identifying specific smart home/IoT devices with API endpoint discovery

---

### Q: Can I run this continuously/as a service?

**A**: Yes, but not recommended in current state due to bugs. After fixes:
- Use Windows Task Scheduler for periodic scans
- Export results for comparison
- Monitor for new devices

---

### Q: Why do some functions return null?

**A**: Known issue #2. Functions return null when they can't retrieve data. Always check for null:

```powershell
$result = Get-DeviceHostname -IPAddress $ip
if ($result) {
    # Use result
} else {
    # Handle null case
}
```

---

### Q: How can I contribute or report bugs?

**A**: 
1. Check [KNOWN-ISSUES.md](KNOWN-ISSUES.md) first
2. Review [TEST-REPORT.md](TEST-REPORT.md) for known behaviors
3. Report through repository issues with details
4. See [DEVELOPER-GUIDE.md](DEVELOPER-GUIDE.md) for contribution guidelines

---

## Next Steps

- **Read**: [KNOWN-ISSUES.md](KNOWN-ISSUES.md) - Understand current limitations
- **Read**: [PREREQUISITES.md](PREREQUISITES.md) - Verify system requirements
- **Read**: [DEVELOPER-GUIDE.md](DEVELOPER-GUIDE.md) - Extend functionality
- **Review**: [TEST-REPORT.md](TEST-REPORT.md) - Detailed test results

---

**Document Version**: 1.0  
**Last Updated**: 2025-12-13  
**Status**: Initial release documentation  
**Next Review**: After critical bug fixes

---

**Need Help?** Check the [Troubleshooting](#troubleshooting) section or review the test reports for detailed behavior analysis.
