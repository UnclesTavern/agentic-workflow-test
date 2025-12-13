# Network Device Scanner

A comprehensive PowerShell script for discovering network devices and API endpoints across multiple subnets on Windows 11 systems.

## Overview

The Network Device Scanner is designed to help identify IoT devices, security equipment, and other network-connected devices on your local area network. It performs multi-subnet scanning, device type identification, and API endpoint detection with robust timeout handling.

## Features

- ✅ **Multi-Subnet Scanning**: Automatically detects and scans all local subnets or accepts custom subnet definitions
- ✅ **Parallel Processing**: Uses PowerShell jobs for efficient concurrent scanning
- ✅ **Device Type Identification**: Recognizes common IoT and network devices including:
  - Home Assistant hubs
  - Shelly smart devices
  - Ubiquiti UniFi equipment
  - Ajax security hubs with NVR
  - Synology NAS devices
  - IP cameras and RTSP streams
  - MQTT brokers
  - Generic web APIs
- ✅ **API Endpoint Detection**: Identifies and reports HTTP/HTTPS API endpoints
- ✅ **Graceful Timeout Handling**: Configurable timeouts for ping and port scanning operations
- ✅ **Multiple Output Formats**: Supports Table, List, JSON, and CSV output
- ✅ **Export Capabilities**: Save results to files in various formats
- ✅ **Detailed Reporting**: Provides comprehensive information about each discovered device

## Requirements

- **Operating System**: Windows 11 (also compatible with Windows 10, Windows Server 2016+)
- **PowerShell**: Version 5.1 or higher
- **Network Access**: Active network connection with appropriate permissions
- **Execution Policy**: May require `Set-ExecutionPolicy` to allow script execution

## Installation

1. Clone or download this repository
2. Navigate to the `scripts` directory
3. Ensure PowerShell execution policy allows script execution:

```powershell
# Check current execution policy
Get-ExecutionPolicy

# If needed, set execution policy (run as Administrator)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

## Usage

### Basic Usage

Run the script with default settings (auto-detects local subnets):

```powershell
.\NetworkDeviceScanner.ps1
```

### Common Scenarios

#### Scan Specific Subnets

```powershell
.\NetworkDeviceScanner.ps1 -Subnets @("192.168.1.0/24", "10.0.0.0/24")
```

#### Quick Scan (Common Ports Only)

```powershell
.\NetworkDeviceScanner.ps1 -CommonPortsOnly
```

#### Export Results to JSON

```powershell
.\NetworkDeviceScanner.ps1 -ExportPath "C:\scans\network-scan.json"
```

#### Comprehensive Scan with Custom Timeouts

```powershell
.\NetworkDeviceScanner.ps1 -ScanTimeout 1000 -PortTimeout 2000 -MaxConcurrentJobs 100
```

#### CSV Export for Spreadsheet Analysis

```powershell
.\NetworkDeviceScanner.ps1 -OutputFormat CSV -ExportPath "C:\scans\devices.csv"
```

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `-Subnets` | String[] | Auto-detect | Array of subnet addresses in CIDR notation (e.g., "192.168.1.0/24") |
| `-ScanTimeout` | Int | 500 | Timeout in milliseconds for ping operations |
| `-PortTimeout` | Int | 1000 | Timeout in milliseconds for port scanning operations |
| `-CommonPortsOnly` | Switch | False | Only scan common API ports instead of extended port list |
| `-MaxConcurrentJobs` | Int | 50 | Maximum number of concurrent scanning jobs |
| `-OutputFormat` | String | 'Table' | Output format: 'Table', 'List', 'JSON', or 'CSV' |
| `-ExportPath` | String | None | Optional path to export results (format auto-detected from extension) |

## Scanned Ports

### Common Ports Mode (Default with -CommonPortsOnly)
- HTTP/HTTPS: 80, 443, 8080, 8443
- Home Assistant: 8123
- Synology DSM: 5000, 5001
- UniFi Controller: 9443, 8880
- Ajax Security: 7080
- IP Cameras (RTSP): 554, 8554
- IoT/Discovery: 1900 (UPnP), 5353 (mDNS)
- MQTT: 1883, 8883
- Industrial IoT: 502 (Modbus)
- Container Management: 9000 (Portainer)

### Extended Ports Mode (Default)
Includes all common ports plus additional web service ports:
- 3000, 3001, 4443, 6443, 7443, 10443
- 8000, 8001, 8008, 8081, 8082, 8083, 8084, 8181, 8888
- 5555, 5556, 9090, 9091, 50000, 50001

## Output Information

For each discovered device, the scanner reports:

- **IP Address**: The IPv4 address of the device
- **Hostname**: Resolved DNS hostname (if available)
- **Status**: Online status
- **Open Ports**: List of all open ports found
- **Device Types**: Identified device types with confidence levels (High/Low)
- **API Endpoints**: Detected HTTP/HTTPS API endpoints
- **HTTP Services**: Ports with active HTTP/HTTPS services
- **Scan Time**: Timestamp of when the device was scanned

## Device Identification

The scanner uses multiple techniques to identify devices:

1. **Port Pattern Matching**: Identifies devices based on open port combinations
2. **HTTP Header Analysis**: Examines server headers and HTTP responses
3. **Content Inspection**: Searches for device-specific API paths and content patterns
4. **SSL/TLS Detection**: Identifies HTTPS services and handles self-signed certificates

### Supported Device Signatures

| Device Type | Key Ports | Identification Method |
|-------------|-----------|----------------------|
| Home Assistant | 8123 | Port + HTTP headers + API paths |
| Shelly Devices | 80 | HTTP headers + /shelly, /status paths |
| Ubiquiti UniFi | 8443, 9443, 8880 | Port patterns + HTTP headers |
| Ajax Security Hub | 7080, 80, 443 | Port + HTTP headers + API detection |
| Synology NAS | 5000, 5001 | Port + HTTP headers + /webapi path |
| IP Cameras | 554, 8554, 80 | RTSP ports + HTTP headers + /onvif path |
| MQTT Brokers | 1883, 8883 | Port detection |
| Generic Web APIs | Multiple | HTTP detection + API path patterns |

## Performance Considerations

### Scan Duration

Scan time depends on several factors:
- **Subnet Size**: Larger subnets (e.g., /23) take longer than smaller ones (/24)
- **Number of Ports**: Extended port scanning takes significantly longer
- **Timeout Settings**: Lower timeouts = faster scans but may miss slower devices
- **Concurrent Jobs**: More jobs = faster scanning (with higher CPU/network usage)

**Typical Scan Times**:
- Single /24 subnet (254 hosts), common ports: ~2-5 minutes
- Single /24 subnet (254 hosts), extended ports: ~5-15 minutes
- Multiple subnets: Multiply accordingly

### Optimization Tips

1. **Use CommonPortsOnly** for faster scans when you know your target devices
2. **Increase MaxConcurrentJobs** if you have a powerful system and fast network
3. **Adjust timeouts** - lower for known responsive networks, higher for slower IoT devices
4. **Target specific subnets** instead of scanning entire large networks

## Troubleshooting

### No Devices Found

If the scanner reports no devices:

1. **Firewall Issues**: Windows Firewall or network firewalls may block ICMP or port scans
   ```powershell
   # Temporarily disable Windows Firewall (testing only)
   Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
   ```

2. **Network Isolation**: Some networks use client isolation (common in guest WiFi)
   - Connect to a trusted network segment
   - Check router settings for AP isolation

3. **Insufficient Permissions**: Run PowerShell as Administrator
   ```powershell
   # Right-click PowerShell and select "Run as Administrator"
   ```

4. **Wrong Subnet**: Verify you're scanning the correct subnet
   ```powershell
   # Check your current network configuration
   Get-NetIPAddress -AddressFamily IPv4
   ```

### Slow Scanning

If scans are taking too long:

1. Reduce timeout values:
   ```powershell
   .\NetworkDeviceScanner.ps1 -ScanTimeout 300 -PortTimeout 500
   ```

2. Use common ports only:
   ```powershell
   .\NetworkDeviceScanner.ps1 -CommonPortsOnly
   ```

3. Increase concurrent jobs (if system allows):
   ```powershell
   .\NetworkDeviceScanner.ps1 -MaxConcurrentJobs 100
   ```

### SSL/Certificate Errors

The scanner automatically handles self-signed certificates (common in IoT devices) by disabling certificate validation for scanning purposes. This is normal and expected behavior.

### Memory Usage

For very large networks, PowerShell jobs may consume significant memory. If you encounter issues:

1. Reduce MaxConcurrentJobs
2. Scan smaller subnet ranges separately
3. Restart PowerShell between scans to clear memory

## Security Considerations

### Permissions

This script requires:
- Network access to target subnets
- Ability to send ICMP echo requests (ping)
- Ability to initiate TCP connections
- DNS resolution capabilities

### Ethical Use

This scanner should only be used on networks you own or have explicit permission to scan. Unauthorized network scanning may violate:
- Computer Fraud and Abuse Act (CFAA) in the United States
- Computer Misuse Act in the United Kingdom
- Similar laws in other jurisdictions

### Privacy

- The scanner does not collect, store, or transmit data outside your local system
- All scanning is performed locally on your Windows machine
- Export files contain network information - secure them appropriately
- Consider the sensitivity of discovered device information

## Examples

### Example 1: Home Network Scan

```powershell
# Scan home network and export to JSON
.\NetworkDeviceScanner.ps1 -ExportPath "C:\Users\YourName\Documents\home-network.json"
```

**Expected Output**:
```
=====================================
  Network Device Scanner v1.0.0
=====================================

[*] Auto-detecting local subnets...
    Found subnet: 192.168.1.100/24 on Ethernet

[*] Scanning 42 ports per host
[*] Total hosts to scan: 254
[*] Starting parallel scan with 50 concurrent jobs...

[+] Device found: 192.168.1.1 - Generic Web API (Low)
[+] Device found: 192.168.1.50 - Synology NAS (High)
[+] Device found: 192.168.1.100 - Home Assistant (High)

=====================================
  Scan Complete!
=====================================

Total devices found: 3
```

### Example 2: IoT Device Discovery

```powershell
# Focus on IoT-specific devices with common ports
.\NetworkDeviceScanner.ps1 -Subnets @("192.168.1.0/24") -CommonPortsOnly -OutputFormat Table
```

### Example 3: Security Audit

```powershell
# Comprehensive scan with detailed logging
.\NetworkDeviceScanner.ps1 `
    -ScanTimeout 1000 `
    -PortTimeout 2000 `
    -MaxConcurrentJobs 30 `
    -ExportPath "C:\Security\network-audit-$(Get-Date -Format 'yyyyMMdd-HHmmss').csv"
```

## Integration

### Scheduled Scans

Create a scheduled task to run regular network scans:

```powershell
$action = New-ScheduledTaskAction -Execute "PowerShell.exe" `
    -Argument "-File C:\Scripts\NetworkDeviceScanner.ps1 -ExportPath C:\Scans\daily-scan.json"

$trigger = New-ScheduledTaskTrigger -Daily -At 2am

Register-ScheduledTask -Action $action -Trigger $trigger `
    -TaskName "Daily Network Scan" -Description "Automated network device discovery"
```

### Programmatic Use

Use the scanner in your own PowerShell scripts:

```powershell
# Import and use the scanner
$results = & .\NetworkDeviceScanner.ps1 -Subnets @("192.168.1.0/24")

# Process results
$homeAssistant = $results | Where-Object { $_.DeviceTypes -like "*Home Assistant*" }
foreach ($device in $homeAssistant) {
    Write-Host "Found Home Assistant at $($device.IPAddress)"
    Write-Host "API: $($device.APIEndpoints)"
}
```

## Limitations

1. **Platform**: Windows-only (PowerShell 5.1+ required)
2. **Protocol Support**: Primarily TCP-based scanning (ICMP, TCP)
3. **Firewall Restrictions**: Effectiveness depends on network firewall configuration
4. **Device Recognition**: Limited to known device signatures
5. **Authentication**: Does not attempt to authenticate to discovered services
6. **IPv6**: Currently supports IPv4 only

## Future Enhancements

Potential improvements for future versions:
- IPv6 support
- Bluetooth/BLE device discovery
- SNMP enumeration
- Additional device signatures
- WMI/CIM integration for Windows devices
- Active Directory integration
- GUI interface
- Real-time monitoring mode
- Notification system for new devices

## Contributing

To add support for additional device types:

1. Add device signature to the `$Script:DeviceSignatures` hashtable
2. Include typical ports, HTTP headers, and API paths
3. Test against actual devices
4. Document the device type and identification method

## License

See the [LICENSE](../LICENSE) file in the repository root for license information.

## Support

For issues, questions, or contributions:
- Open an issue in the repository
- Review existing documentation
- Check troubleshooting section above

## Version History

### v1.0.0 (Current)
- Initial release
- Multi-subnet scanning support
- Device type identification for major IoT platforms
- API endpoint detection
- Multiple output formats
- Export capabilities
- Comprehensive documentation

---

**Author**: Development Agent  
**Repository**: agentic-workflow-test  
**Last Updated**: 2025-12-13
