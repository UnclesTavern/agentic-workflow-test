# Network Device Scanner - User Guide

Complete step-by-step guide for using the Network Device Scanner.

## Table of Contents

1. [Getting Started](#getting-started)
2. [Basic Usage](#basic-usage)
3. [Common Scenarios](#common-scenarios)
4. [Understanding Results](#understanding-results)
5. [Advanced Configuration](#advanced-configuration)
6. [Troubleshooting](#troubleshooting)
7. [FAQ](#faq)
8. [Best Practices](#best-practices)

---

## Getting Started

### Prerequisites Check

Before running the scanner, verify your system meets the requirements:

```powershell
# Check PowerShell version (need 5.1+)
$PSVersionTable.PSVersion

# Check Windows version (need Windows 11)
(Get-WmiObject -class Win32_OperatingSystem).Caption

# Check if running as Administrator (optional but recommended)
([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
```

### First Time Setup

1. **Download the script** to a convenient location:
   ```
   C:\Scripts\NetworkDeviceScanner.ps1
   ```

2. **Set execution policy** (if needed):
   ```powershell
   # Check current policy
   Get-ExecutionPolicy
   
   # If it's Restricted, change it (requires Administrator)
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

3. **Test the script** without execution:
   ```powershell
   # Navigate to script directory
   cd C:\Scripts
   
   # View help
   Get-Help .\NetworkDeviceScanner.ps1 -Full
   ```

---

## Basic Usage

### Scenario 1: Simple Home Network Scan

**Situation:** You want to see all devices on your home network.

```powershell
# Run with default settings
.\NetworkDeviceScanner.ps1
```

**What happens:**
1. Script auto-detects your local subnet (e.g., 192.168.1.0/24)
2. Scans all 254 possible IP addresses
3. Tests common API ports on found devices
4. Displays colored results in console
5. Exports to JSON file

**Expected output:**
```
No subnets specified. Auto-detecting local subnets...

========================================
  Network Device Scanner
========================================

Subnets to scan: 192.168.1.0/24
Ports to check: 80, 443, 8080, 8443, 8123, 5000, 5001, 7443, 9443
Timeout: 1000ms

Scanning subnet: 192.168.1.0/24
Total IPs to scan: 254

Phase 1: Discovering reachable hosts...
  [+] Found: 192.168.1.1
  [+] Found: 192.168.1.100
  [+] Found: 192.168.1.150

Found 3 reachable host(s) in 192.168.1.0/24

Phase 2: Scanning devices for details...
  [*] 192.168.1.1 - Unknown
  [*] 192.168.1.100 - IOTHub
  [*] 192.168.1.150 - IOTDevice
```

### Scenario 2: Scan Specific Subnet

**Situation:** You know the exact subnet to scan.

```powershell
.\NetworkDeviceScanner.ps1 -Subnets "192.168.1.0/24"
```

**Use cases:**
- Scanning guest network separate from main network
- Targeting specific VLAN
- Scanning smaller subnet for faster results

### Scenario 3: Multiple Subnets

**Situation:** Your network has multiple subnets (e.g., main network and IoT VLAN).

```powershell
.\NetworkDeviceScanner.ps1 -Subnets "192.168.1.0/24","192.168.2.0/24"
```

**Example setup:**
- 192.168.1.0/24 - Main network (computers, phones)
- 192.168.2.0/24 - IoT network (smart home devices)

---

## Common Scenarios

### Scenario 4: Fast Scan on Local Network

**Situation:** You're on a fast local network and want quick results.

```powershell
.\NetworkDeviceScanner.ps1 -Timeout 500
```

**Benefits:**
- Reduces scan time by 50%
- Good for wired networks
- Use when devices respond quickly

**Warning:** May miss devices on slower connections.

### Scenario 5: Slow or Wireless Network

**Situation:** Scanning over WiFi or slower network.

```powershell
.\NetworkDeviceScanner.ps1 -Timeout 2000
```

**Benefits:**
- More reliable device detection
- Better for wireless networks
- Reduces false negatives

**Trade-off:** Takes longer to complete scan.

### Scenario 6: Scan Only Web Services

**Situation:** Only interested in devices with web interfaces.

```powershell
.\NetworkDeviceScanner.ps1 -Ports 80,443,8080,8443
```

**Use cases:**
- Finding web-based admin panels
- Locating cameras with web interfaces
- Discovering web-enabled IoT devices

### Scenario 7: Find Home Assistant Instances

**Situation:** Looking for Home Assistant or similar IoT hubs.

```powershell
.\NetworkDeviceScanner.ps1 -Ports 8123,8080,443
```

**Targets:**
- Home Assistant (default port 8123)
- OpenHAB (typically 8080)
- Other smart home hubs

### Scenario 8: Scan Small Network Segment

**Situation:** Need to scan just a few addresses.

```powershell
# /28 subnet = only 14 usable addresses
.\NetworkDeviceScanner.ps1 -Subnets "192.168.1.16/28"
```

**Addresses in 192.168.1.16/28:**
- Range: 192.168.1.17 - 192.168.1.30 (14 hosts)
- Network: 192.168.1.16
- Broadcast: 192.168.1.31

**Benefits:**
- Very fast scan (seconds)
- Useful for specific segments
- Good for testing

---

## Understanding Results

### Console Output Explained

#### Section 1: Configuration
```
Subnets to scan: 192.168.1.0/24
Ports to check: 80, 443, 8080, 8443, 8123, 5000, 5001, 7443, 9443
Timeout: 1000ms
```

**Meaning:** Shows what the script will scan.

#### Section 2: Phase 1 - Host Discovery
```
Phase 1: Discovering reachable hosts...
  [+] Found: 192.168.1.100
```

**Meaning:** These devices responded to ping.

#### Section 3: Phase 2 - Device Details
```
Phase 2: Scanning devices for details...
  [*] 192.168.1.100 - IOTHub
```

**Meaning:** Detailed scan complete, device classified.

#### Section 4: Summary Report
```
IOT Hub Devices (1):
------------------------------------------------------------

IP Address: 192.168.1.100
  Hostname: homeassistant.local
  MAC: a0-20-a6-12-34-56 (Espressif ESP8266/ESP32)
  Open Ports: 80, 8123
  API Endpoints:
    - http://192.168.1.100:8123/ [Status: 200]
```

**What each field means:**

- **IP Address** - Network address of device
- **Hostname** - DNS name (if available)
- **MAC** - Hardware address (same subnet only)
- **Manufacturer** - Identified from MAC OUI
- **Open Ports** - TCP ports that accepted connections
- **API Endpoints** - HTTP/HTTPS URLs that responded

### JSON Output Explained

The script creates a file like `NetworkScan_20231215_143022.json`:

```json
[
  {
    "IPAddress": "192.168.1.100",
    "Hostname": "homeassistant.local",
    "MACAddress": "a0-20-a6-12-34-56",
    "Manufacturer": "Espressif (ESP8266/ESP32)",
    "DeviceType": "IOTHub",
    "OpenPorts": [80, 8123],
    "Endpoints": [
      {
        "URL": "http://192.168.1.100:8123/",
        "StatusCode": 200,
        "Server": "nginx",
        "ContentLength": 5432,
        "Content": "<!DOCTYPE html>..."
      }
    ],
    "ScanTime": "2023-12-15 14:30:22"
  }
]
```

**Field descriptions:**

| Field | Type | Description |
|-------|------|-------------|
| IPAddress | string | IP address of device |
| Hostname | string/null | DNS hostname if resolved |
| MACAddress | string/null | MAC address if on same subnet |
| Manufacturer | string | Vendor name from OUI database |
| DeviceType | string | IOTHub, IOTDevice, Security, or Unknown |
| OpenPorts | array | List of TCP ports that are open |
| Endpoints | array | HTTP/HTTPS responses from device |
| ScanTime | string | When this device was scanned |

**Endpoints object:**

| Field | Type | Description |
|-------|------|-------------|
| URL | string | Full URL tested |
| StatusCode | int | HTTP status code (200, 404, etc.) |
| Server | string | Server header from response |
| ContentLength | int | Size of content in bytes |
| Content | string | First 1000 characters of response |

---

## Advanced Configuration

### Combining Parameters

**All parameters together:**

```powershell
.\NetworkDeviceScanner.ps1 `
    -Subnets "192.168.1.0/24","192.168.2.0/24","10.0.0.0/24" `
    -Ports 80,443,8080,8443,8123,7443,9443 `
    -Timeout 1500
```

**Backtick (`) usage:** Allows breaking long commands across multiple lines.

### Understanding CIDR Notation

| CIDR | Subnet Mask | Usable Hosts | Scan Time (est.) |
|------|-------------|--------------|------------------|
| /30 | 255.255.255.252 | 2 | Seconds |
| /29 | 255.255.255.248 | 6 | Seconds |
| /28 | 255.255.255.240 | 14 | Seconds |
| /27 | 255.255.255.224 | 30 | ~30 seconds |
| /26 | 255.255.255.192 | 62 | ~1 minute |
| /25 | 255.255.255.128 | 126 | ~2 minutes |
| /24 | 255.255.255.0 | 254 | ~5 minutes |
| /16 | 255.255.0.0 | 65534 | Hours (limited) |

### Performance Tuning

**Calculate expected scan time:**

```
Phase 1 time ≈ Number of IPs × Timeout
Phase 2 time ≈ Reachable hosts × Number of ports × Timeout

Example (/24 network, 1000ms timeout, 9 ports):
Phase 1: 254 IPs × 1s = 254s (~4 minutes)
Phase 2 (10 devices): 10 × 9 ports × 1s = 90s (~1.5 minutes)
Total: ~5.5 minutes
```

**Optimization strategies:**

1. **Smaller subnets:** Use /28 or /27 for faster scans
2. **Lower timeout:** Use 500ms on fast networks
3. **Fewer ports:** Only scan ports you need
4. **Time of day:** Scan during low-traffic periods

---

## Troubleshooting

### Problem: "No local subnets found"

**Symptoms:**
```
No local subnets found. Please specify subnets manually.
```

**Solutions:**

1. **Check network adapter:**
   ```powershell
   Get-NetAdapter | Where-Object Status -eq 'Up'
   ```

2. **Check IP configuration:**
   ```powershell
   Get-NetIPAddress -AddressFamily IPv4
   ```

3. **Specify subnet manually:**
   ```powershell
   .\NetworkDeviceScanner.ps1 -Subnets "192.168.1.0/24"
   ```

### Problem: "No devices found"

**Possible causes:**

1. **Firewall blocking ICMP:**
   - Windows Firewall may block ping
   - Solution: Temporarily disable or add exception
   
   ```powershell
   # Check firewall rule (run as Administrator)
   Get-NetFirewallRule | Where-Object DisplayName -like '*ICMP*'
   ```

2. **Devices don't respond to ping:**
   - Some devices have ping disabled
   - Solution: They may still be detected in Phase 2 if you scan their ports

3. **Wrong subnet:**
   - Check your actual network subnet
   - Solution: Use `ipconfig` to verify

   ```powershell
   ipconfig /all
   ```

### Problem: "Access denied" or Permission Errors

**Error message:**
```
Failed to enumerate local subnets: Access denied
```

**Solutions:**

1. **Run as Administrator:**
   - Right-click PowerShell → "Run as Administrator"
   - Navigate to script directory
   - Run the script

2. **Check execution policy:**
   ```powershell
   Get-ExecutionPolicy
   Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

### Problem: Scan is Very Slow

**Symptoms:** Script takes much longer than expected.

**Solutions:**

1. **Reduce timeout:**
   ```powershell
   .\NetworkDeviceScanner.ps1 -Timeout 500
   ```

2. **Scan smaller subnet:**
   ```powershell
   # Instead of /24 (254 hosts), use /28 (14 hosts)
   .\NetworkDeviceScanner.ps1 -Subnets "192.168.1.0/28"
   ```

3. **Reduce ports:**
   ```powershell
   .\NetworkDeviceScanner.ps1 -Ports 80,443
   ```

### Problem: SSL/Certificate Errors

**Symptoms:** Errors about certificates or SSL validation.

**This is normal!** The script handles this automatically:
- Many IoT devices use self-signed certificates
- Script temporarily disables certificate validation
- Original settings are always restored

**No action needed** - errors are expected and handled.

### Problem: JSON File Not Created

**Possible causes:**

1. **Permission issue:**
   - Script runs in current directory
   - Solution: Run from directory where you have write access

2. **Script didn't complete:**
   - Check if any errors occurred
   - Solution: Review error messages

3. **File already exists:**
   - Unlikely (timestamp makes each file unique)
   - Solution: Check for existing files

   ```powershell
   Get-ChildItem -Filter "NetworkScan_*.json"
   ```

### Problem: MAC Address Shows as "Unknown"

**This is normal** in several cases:

1. **Device on different subnet:**
   - MAC addresses only visible on Layer 2 (same subnet)
   - This is a network limitation, not a script issue

2. **ARP cache not populated:**
   - Solution: Ping the device first
   
   ```powershell
   Test-Connection -ComputerName 192.168.1.100 -Count 1
   ```

3. **Wireless isolation:**
   - Some WiFi networks isolate clients
   - This is a network security feature

---

## FAQ

### Q: Is it safe to scan my network?

**A:** Yes, if it's your own network. The script only performs read-only operations:
- Ping (ICMP Echo)
- TCP connection attempts
- HTTP GET requests

It does **not** modify devices or send malicious traffic.

### Q: Is it legal to scan networks?

**A:** 
- ✅ **Your own network:** Yes
- ✅ **Networks you manage:** Yes
- ❌ **Other people's networks:** NO (requires permission)

Unauthorized network scanning may violate:
- Computer Fraud and Abuse Act (CFAA) in the US
- Computer Misuse Act in the UK
- Similar laws in other countries

### Q: Will this work on PowerShell Core / Linux / Mac?

**A:** No. The script uses Windows-specific cmdlets:
- `Get-NetAdapter`
- `Get-NetIPAddress`
- ARP table access via Windows commands

It requires **Windows 11** and **PowerShell 5.1+**.

### Q: How accurate is device classification?

**A:** Classification accuracy depends on available information:

- **High accuracy:** Devices with known manufacturers (Shelly, Ubiquiti, etc.)
- **Medium accuracy:** Devices with generic names or unknown manufacturers
- **Low accuracy:** Devices that don't respond to HTTP probes

Many devices will be classified as "Unknown" - this is normal.

### Q: Can I scan devices through a router?

**A:** Yes and no:

✅ **IP address and ports:** Can scan across subnets
❌ **MAC addresses:** Only visible on same subnet (Layer 2 limitation)

Example: If your PC is on 192.168.1.0/24 and you scan 192.168.2.0/24:
- Will find devices and open ports
- Won't get MAC addresses or manufacturers

### Q: How do I scan faster?

**A:** Multiple options:

1. **Reduce timeout:**
   ```powershell
   -Timeout 500
   ```

2. **Scan smaller subnet:**
   ```powershell
   -Subnets "192.168.1.0/27"  # Only 30 hosts instead of 254
   ```

3. **Fewer ports:**
   ```powershell
   -Ports 80,443,8080
   ```

### Q: Can I schedule automatic scans?

**A:** Yes! Use Windows Task Scheduler:

1. Open Task Scheduler
2. Create Basic Task
3. Set trigger (daily, weekly, etc.)
4. Action: Start a program
5. Program: `powershell.exe`
6. Arguments: `-File C:\Scripts\NetworkDeviceScanner.ps1`

Results will be saved to JSON files with timestamps.

### Q: How do I parse the JSON output?

**A:** Use PowerShell:

```powershell
# Read JSON file
$results = Get-Content "NetworkScan_20231215_143022.json" | ConvertFrom-Json

# Show all IOT devices
$results | Where-Object DeviceType -eq 'IOTDevice'

# Show devices with port 8123 open
$results | Where-Object { $_.OpenPorts -contains 8123 }

# Export to CSV
$results | Export-Csv -Path "scan_results.csv" -NoTypeInformation
```

### Q: Does this detect all devices?

**A:** Not always. Devices may be missed if:

- Firewall blocks ping/connections
- Device is in stealth mode
- Network has client isolation
- Timeout is too short
- Device is turned off or sleeping

For complete inventory, use multiple scans at different times.

---

## Best Practices

### Security Best Practices

1. **Own networks only:** Only scan networks you own or manage
2. **Inform users:** Let network users know scanning is occurring
3. **Off-peak hours:** Scan during low-traffic times
4. **Protect output:** JSON files contain network topology (sensitive data)
5. **Rate limiting:** Don't scan too frequently (avoid network congestion)

### Operational Best Practices

1. **Baseline scans:** Run regular scans to establish baseline
2. **Compare results:** Use JSON files to track network changes over time
3. **Document findings:** Keep notes about expected vs. unexpected devices
4. **Version control:** Save JSON files with meaningful names
5. **Regular updates:** Re-scan after network changes

### Performance Best Practices

1. **Right-sized timeouts:** Match timeout to network speed
2. **Appropriate subnets:** Don't scan larger subnets than needed
3. **Targeted ports:** Only scan ports relevant to your use case
4. **Scheduled scans:** Automate with Task Scheduler
5. **Result analysis:** Review JSON files instead of re-scanning

### Example Workflow

**Initial discovery:**
```powershell
.\NetworkDeviceScanner.ps1 -Timeout 2000
# Save output as: baseline_20231215.json
```

**Weekly checks:**
```powershell
.\NetworkDeviceScanner.ps1 -Timeout 1000
# Compare with baseline
```

**Targeted scan:**
```powershell
# Found new device at 192.168.1.150, scan its segment
.\NetworkDeviceScanner.ps1 -Subnets "192.168.1.144/28"
```

---

## Next Steps

- **[Technical Reference](TECHNICAL_REFERENCE.md)** - Function documentation and API details
- **[Examples](EXAMPLES.md)** - Real-world scenarios and integration examples
- **[Main Documentation](NetworkDeviceScanner.md)** - Overview and quick reference

---

## Getting Help

If you encounter issues not covered in this guide:

1. Review error messages carefully
2. Check Windows Event Viewer for system-level issues
3. Verify network connectivity with basic tools (ping, tracert)
4. Test with minimal parameters first
5. Try scanning a single known device

**Diagnostic commands:**
```powershell
# Test basic network connectivity
Test-Connection -ComputerName 192.168.1.1

# Check if port is open
Test-NetConnection -ComputerName 192.168.1.100 -Port 80

# View network routes
Get-NetRoute

# Check DNS resolution
Resolve-DnsName homeassistant.local
```
