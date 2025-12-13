# LAN Device Scanner - PowerShell Script

## ⚠️ CRITICAL WARNING - READ FIRST

**PRODUCTION READINESS**: ⚠️ **NOT PRODUCTION READY**

This script contains a **critical bug** that prevents full execution:
- **Bug**: Reserved variable name `$host` on line 931 blocks workflow
- **Impact**: Script cannot complete full network scans
- **Status**: Tested with 66.1% pass rate (37/56 tests passed)
- **Action Required**: See [KNOWN-ISSUES.md](KNOWN-ISSUES.md) for complete details and fixes

**IMPORTANT DOCUMENTATION**:
- 📖 [Known Issues](KNOWN-ISSUES.md) - **READ THIS FIRST** - Critical bugs and workarounds
- 📖 [User Guide](USER-GUIDE.md) - Comprehensive usage instructions
- 📖 [Prerequisites](PREREQUISITES.md) - Requirements and compatibility
- 📖 [Developer Guide](DEVELOPER-GUIDE.md) - Extending and contributing
- 📊 [Test Report](TEST-REPORT.md) - Detailed test results and analysis

---

## Overview

`Scan-LANDevices.ps1` is a comprehensive PowerShell script for Windows 11 that scans your local area network (LAN) to discover devices, identify their types, and discover exposed API endpoints.

**Current Status**: Requires bug fixes before production use. Individual functions work correctly and can be used independently.

## Features

- **Multi-Subnet Scanning**: Automatically detects and scans all local subnets or custom CIDR ranges
- **Parallel Processing**: Uses PowerShell runspaces for fast concurrent scanning
- **Device Type Identification**: Identifies specific device types including:
  - **IoT Hubs**: Home Assistant
  - **IoT Devices**: Shelly devices
  - **Security Devices**: Ubiquiti (UniFi), Ajax Security Hub, NVR/Cameras
- **API Endpoint Discovery**: Automatically discovers and probes common and device-specific API endpoints
- **Comprehensive Information**: Gathers hostname, MAC address, open ports, and confidence scores
- **Multiple Output Formats**: Console display and JSON export

## Requirements

⚠️ **See [PREREQUISITES.md](PREREQUISITES.md) for complete requirements**

**Essential Requirements**:
- **Operating System**: Windows 11 (or Windows 10 with PowerShell 5.1+)
- **PowerShell Version**: 5.1 or higher (tested on 7.4.13)
- **Permissions**: Run as Administrator for best results (ARP cache access, network operations)
- **Network**: Active network connection to LAN
- **Firewall**: ICMP (ping) enabled

**Platform Support**:
- ✅ Windows 11/10: Full support
- ⚠️ Linux/macOS: Partial support (use manual subnet specification)

## Installation

1. Download `Scan-LANDevices.ps1` to your local machine
2. Open PowerShell as Administrator
3. If this is your first time running PowerShell scripts, you may need to adjust execution policy:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

## Usage

⚠️ **IMPORTANT**: Due to critical bug #1, automatic scanning is currently non-functional. See [USER-GUIDE.md](USER-GUIDE.md) for detailed usage and workarounds.

### Basic Usage (Auto-detect local subnets)

⚠️ **Currently Broken** - Critical `$host` variable bug prevents execution

```powershell
# This will fail with current version - see KNOWN-ISSUES.md for fix
.\Scan-LANDevices.ps1
```

### Recommended Workaround

Use manual subnet specification or individual functions:

```powershell
# Manual subnet specification (works correctly)
.\Scan-LANDevices.ps1 -SubnetCIDR @("192.168.1.0/24")

# OR use individual functions
. .\Scan-LANDevices.ps1
$aliveHosts = Invoke-SubnetScan -CIDR "192.168.1.0/24"
foreach ($ip in $aliveHosts) {
    Get-DeviceInformation -IPAddress $ip
}
```

This will:
- Automatically detect your active network adapters and their subnets
- Scan all detected subnets for alive hosts
- Identify device types and discover API endpoints
- Display results in console
- Export results to JSON file with timestamp

### Advanced Usage

#### Scan Specific Subnets

```powershell
.\Scan-LANDevices.ps1 -SubnetCIDR @("192.168.1.0/24", "192.168.2.0/24")
```

#### Adjust Timeout and Threads

```powershell
.\Scan-LANDevices.ps1 -Timeout 200 -Threads 100
```

- **Timeout**: Milliseconds to wait for ping response (default: 100ms)
- **Threads**: Number of concurrent scanning threads (default: 50)

#### Verbose Output

```powershell
.\Scan-LANDevices.ps1 -Verbose
```

Shows detailed progress information during scanning.

### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `SubnetCIDR` | string[] | Auto-detect | Array of subnet CIDR notations to scan (e.g., "192.168.1.0/24") |
| `Timeout` | int | 100 | Timeout in milliseconds for ping operations |
| `Threads` | int | 50 | Number of concurrent threads for scanning |

## Architecture

### Modular Function Design

The script is organized into isolated, reusable functions grouped by functionality:

#### Helper Functions
- `ConvertFrom-CIDR`: Converts CIDR notation to IP range
- `ConvertTo-IPAddress`: Converts integer to IP address string
- `Get-LocalSubnets`: Gets local network subnets from active adapters

#### Scanning Functions
- `Test-HostAlive`: Performs ping scan on a single IP address
- `Invoke-SubnetScan`: Scans subnet for alive hosts using parallel processing

#### Device Discovery Functions
- `Get-DeviceHostname`: Attempts DNS resolution to get hostname
- `Get-DeviceMACAddress`: Gets MAC address from ARP cache or network query
- `Get-OpenPorts`: Scans common ports to identify device type and services
- `Get-HTTPDeviceInfo`: Performs HTTP/HTTPS probe to get device information

#### Device Type Identification Functions
- `Test-HomeAssistant`: Identifies Home Assistant instances
- `Test-ShellyDevice`: Identifies Shelly IoT devices
- `Test-UbiquitiDevice`: Identifies Ubiquiti devices
- `Test-AjaxSecurityHub`: Identifies Ajax Security Hub devices
- `Get-DeviceType`: Identifies generic device type based on open ports and HTTP info

#### API Endpoint Discovery Functions
- `Find-APIEndpoints`: Discovers API endpoints on a device

#### Main Orchestration Functions
- `Get-DeviceInformation`: Performs complete device discovery on a host
- `Start-LANDeviceScan`: Main function to scan LAN and discover all devices

#### Output Functions
- `Show-DeviceScanResults`: Displays device scan results in formatted table
- `Export-DeviceScanResults`: Exports device scan results to JSON file

## Device Detection Methods

### Home Assistant
- **Detection**: Port 8123 (default), HTTP title/headers containing "Home Assistant"
- **API Endpoints**: `/api/`, `/auth`, `/api/config`, `/api/states`
- **Confidence Threshold**: 50%

### Shelly Devices
- **Detection**: HTTP title/headers containing "Shelly", `/shelly` API endpoint
- **API Endpoints**: `/shelly`, `/status`, `/settings`, `/rpc`
- **Confidence Threshold**: 50%

### Ubiquiti Devices
- **Detection**: Port 8443 (UniFi Controller), UniFi signatures in HTTP responses
- **API Endpoints**: `/api/auth`, `/api/system`, `/api/s/default`
- **Confidence Threshold**: 50%

### Ajax Security Hub
- **Detection**: HTTP title/headers containing "Ajax" or "Ajax Systems"
- **API Endpoints**: `/api/panel`, `/api/devices`
- **Confidence Threshold**: 50%

### NVR/Camera Devices
- **Detection**: Port 554 (RTSP protocol)
- **Confidence Threshold**: 40%

## Output

### Console Output

The script displays results grouped by device type:

```
=== Device Scan Results ===

--- IoT Hub (1 devices) ---

IP Address: 192.168.1.100
  Hostname: homeassistant.local
  MAC Address: AA:BB:CC:DD:EE:FF
  Sub Type: Home Assistant
  Confidence: 80%
  Open Ports: 8123, 80, 443
  API Endpoints:
    - http://192.168.1.100:8123/api/ (Status: 200)
    - http://192.168.1.100:8123/api/config (Status: 401)
  Evidence:
    - Port 8123 is open (Home Assistant default)
    - Home Assistant identified in HTTP response
```

### JSON Export

Results are automatically exported to a timestamped JSON file:

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

## Ports Scanned

The script scans the following common ports by default:

- **80**: HTTP
- **443**: HTTPS
- **554**: RTSP (cameras/NVR)
- **3000**: Various web services
- **8000**: HTTP alternate
- **8080**: HTTP alternate
- **8081**: HTTP alternate
- **8123**: Home Assistant default
- **8443**: UniFi Controller, HTTPS alternate
- **9000**: Various services
- **9443**: HTTPS alternate

## Performance Considerations

- **Scan Time**: Depends on subnet size and number of alive hosts
  - Single /24 subnet (~254 hosts): 1-3 minutes for ping scan
  - Device discovery per host: 5-15 seconds
- **Threads**: Default 50 threads provides good balance between speed and system load
- **Network Load**: Generates significant network traffic during scan; avoid running during critical operations

## Error Handling

The script includes comprehensive error handling:
- Gracefully handles unreachable hosts
- Manages connection timeouts
- Handles SSL/TLS certificate validation for HTTPS
- Provides informative error messages

## Security Considerations

- **Certificate Validation**: Disabled for HTTPS connections to allow scanning of devices with self-signed certificates
- **Credentials**: Script does not attempt authentication (401/403 responses are noted but not bypassed)
- **Network Impact**: Scanning activity may be logged by security devices and firewalls
- **Run as Administrator**: Recommended for full functionality, especially ARP cache access

## Known Issues

⚠️ **See [KNOWN-ISSUES.md](KNOWN-ISSUES.md) for complete list**

### 🔴 CRITICAL: Reserved Variable Bug (Line 931)

**Error**: "Cannot overwrite variable Host because it is read-only or constant"

**Impact**: Blocks full workflow execution

**Required Fix**:
```powershell
# Change line 931 from:
foreach ($host in $allHosts) {

# To:
foreach ($hostIP in $allHosts) {
```

### 🟡 Functions May Return Null

Functions like `Get-DeviceHostname`, `Get-OpenPorts`, etc. may return `$null` instead of safe defaults. Always check for null:

```powershell
$hostname = Get-DeviceHostname -IPAddress $ip
if ($hostname) {
    Write-Host "Hostname: $hostname"
} else {
    Write-Host "Hostname: Unknown"
}
```

## Testing Status

- **Total Tests**: 56 test cases
- **Pass Rate**: 66.1% (37 passed, 19 failed)
- **Test Environment**: Linux with PowerShell 7.4.13
- **Test Limitations**: No real IoT devices tested
- **Function Isolation**: ✅ All 19 functions confirmed modular

See [TEST-REPORT.md](TEST-REPORT.md) and [TEST-SUMMARY.md](TEST-SUMMARY.md) for detailed results.

## Troubleshooting

⚠️ **See [USER-GUIDE.md](USER-GUIDE.md) for comprehensive troubleshooting**

### Critical Bug: "Cannot overwrite variable Host"
**Solution**: Apply fix from [KNOWN-ISSUES.md](KNOWN-ISSUES.md) or use individual functions

### No Devices Found
- Ensure you're on the correct network
- Check firewall settings (ICMP ping must be allowed)
- Try increasing the timeout: `-Timeout 500`
- Verify network connectivity: `Test-Connection -ComputerName 192.168.1.1`

### Slow Scanning
- Reduce the number of threads: `-Threads 25`
- Scan specific subnets instead of auto-detection
- Check for network congestion

### Permission Errors
- Run PowerShell as Administrator
- Check execution policy: `Get-ExecutionPolicy`

### Device Not Identified Correctly
- Device may not match known signatures
- Check the "Network Device" category for unidentified devices
- Review the Evidence field for clues
- API endpoints may still be discovered even if type is unknown

## Extending the Script

### Adding New Device Types

To add detection for new device types, create a new `Test-*` function following this pattern:

```powershell
function Test-NewDeviceType {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$IPAddress,
        
        [Parameter(Mandatory=$true)]
        [int[]]$OpenPorts
    )
    
    $indicators = @{
        IsNewDevice = $false
        Confidence = 0
        Evidence = @()
    }
    
    # Add detection logic here
    # Check ports, HTTP responses, etc.
    
    $indicators.IsNewDevice = ($indicators.Confidence -ge 50)
    return $indicators
}
```

Then add it to the `Get-DeviceType` function.

### Adding Custom API Endpoints

Modify the `$deviceSpecificPaths` hashtable in `Find-APIEndpoints`:

```powershell
$deviceSpecificPaths['New Device Type'] = @('/api/custom', '/custom/endpoint')
```

## Performance Expectations

Based on testing:

| Network Size | Expected Duration | Status |
|--------------|------------------|---------|
| /30 (2-4 hosts) | <5 seconds | ✅ Tested |
| /24 (254 hosts) | 2-3 minutes | Estimated |
| Per device discovery | 5-20 seconds | Tested |

See [USER-GUIDE.md](USER-GUIDE.md) for performance tuning recommendations.

## Documentation

### User Documentation
- 📖 **[USER-GUIDE.md](USER-GUIDE.md)** - Comprehensive user guide with examples
- 📖 **[PREREQUISITES.md](PREREQUISITES.md)** - Requirements and compatibility
- 📖 **[KNOWN-ISSUES.md](KNOWN-ISSUES.md)** - Critical bugs and workarounds

### Developer Documentation
- 📖 **[DEVELOPER-GUIDE.md](DEVELOPER-GUIDE.md)** - Extending and contributing
- 📖 **[TEST-REPORT.md](TEST-REPORT.md)** - Detailed test analysis
- 📖 **[TEST-SUMMARY.md](TEST-SUMMARY.md)** - Quick test reference

### Development Documentation
- 📖 **[DEVELOPMENT-SUMMARY.md](DEVELOPMENT-SUMMARY.md)** - Implementation notes
- 📖 **[TESTING-CHECKLIST.md](TESTING-CHECKLIST.md)** - Test coverage matrix

## Production Readiness Checklist

Before using in production:

- [ ] **Apply critical bug fix** from [KNOWN-ISSUES.md](KNOWN-ISSUES.md)
- [ ] **Test on Windows 11** (target platform)
- [ ] **Validate with real devices** in your environment
- [ ] **Review security considerations**
- [ ] **Notify network administrators** before scanning
- [ ] **Test at expected scale** (full subnet scan)
- [ ] **Implement null checking** for function returns

**Estimated Fix Time**: 4-8 hours for all critical issues

## Contributing

See [DEVELOPER-GUIDE.md](DEVELOPER-GUIDE.md) for:
- Architecture overview
- Function reference
- Adding new device types
- Testing guidelines
- Code quality standards

## License

See [LICENSE](LICENSE) file for details.

## Support

For issues, questions, or contributions:

1. **Review documentation** - Check guides above
2. **Check known issues** - See [KNOWN-ISSUES.md](KNOWN-ISSUES.md)
3. **Review test reports** - Understand current behavior
4. **Report new issues** - With full details and environment info

---

**Document Version**: 1.0  
**Last Updated**: 2025-12-13  
**Status**: Initial release - requires bug fixes before production use
