# Network Device Scanner

**Version:** 1.0  
**Platform:** Windows 11  
**PowerShell:** 5.1 or higher

## Overview

The Network Device Scanner is a comprehensive PowerShell script designed to discover and identify devices on your local network. It automatically detects network-connected devices, classifies them by type (IOT hubs, IOT devices, security devices), and discovers exposed API endpoints.

## Key Features

### 🔍 Network Discovery
- **Multi-subnet scanning** with CIDR notation support
- **Automatic subnet detection** from local network adapters
- **ICMP ping sweep** for efficient host discovery
- **TCP port scanning** on configurable ports
- **HTTP/HTTPS endpoint probing** with SSL support

### 🏷️ Device Identification
- **Hostname resolution** via DNS
- **MAC address discovery** via ARP table
- **Manufacturer identification** using built-in OUI database (13 vendors)
- **Intelligent device classification** based on multiple signals

### 📊 Output & Reporting
- **Colored console output** with progress indicators
- **JSON export** with detailed device information
- **Structured results** organized by device type
- **Comprehensive device profiles** including all discovered data

## Device Types

The scanner automatically classifies devices into three categories:

### 1. IOT Hub Devices
Central control systems for smart home automation.

**Detected Systems:**
- Home Assistant
- OpenHAB
- Hubitat
- SmartThings

**Detection Criteria:**
- Ports: 8123, 8080, 443
- Keywords: homeassistant, hassio, openhab, hubitat, smartthings

### 2. IOT Devices
Smart home devices, sensors, and controllers.

**Detected Devices:**
- Shelly switches and sensors
- Tasmota firmware devices
- ESP8266/ESP32 devices
- Philips Hue lighting
- TP-Link smart devices

**Detection Criteria:**
- Ports: 80, 443
- Keywords: shelly, tasmota, sonoff, esp, arduino, wemo, philips, hue, lifx

### 3. Security Devices
Network security equipment and surveillance systems.

**Detected Systems:**
- Ubiquiti UniFi controllers
- Ajax security systems
- IP cameras (Hikvision, Dahua, AXIS)
- NVR/DVR systems

**Detection Criteria:**
- Ports: 443, 7443, 8443, 9443, 554
- Keywords: ubiquiti, unifi, ajax, hikvision, dahua, axis, nvr, dvr, camera

## Requirements

### System Requirements
- **Operating System:** Windows 11
- **PowerShell:** Version 5.1 or higher
- **.NET Framework:** 4.7.2 or higher (included with Windows 11)

### Permissions
- **Network access** to scan target subnets
- **Administrator privileges** may be required for:
  - Network adapter enumeration
  - ARP table access
  - ICMP ping (on some systems)

### Network Requirements
- Active network connection
- Firewall rules allowing:
  - ICMP (ping) outbound
  - TCP connections to target ports
  - DNS resolution

## Installation

No installation required! The script is standalone.

1. Download `NetworkDeviceScanner.ps1`
2. Place it in a convenient directory
3. Run from PowerShell

```powershell
# Navigate to script directory
cd C:\path\to\script

# Run the scanner
.\NetworkDeviceScanner.ps1
```

## Quick Start

### Basic Usage

Scan your local network with default settings:

```powershell
.\NetworkDeviceScanner.ps1
```

This will:
1. Auto-detect all local subnets
2. Scan default ports: 80, 443, 8080, 8443, 8123, 5000, 5001, 7443, 9443
3. Use 1000ms timeout for network operations
4. Display results in console with colors
5. Export results to `NetworkScan_YYYYMMDD_HHMMSS.json`

### Scan Specific Subnet

```powershell
.\NetworkDeviceScanner.ps1 -Subnets "192.168.1.0/24"
```

### Scan Multiple Subnets

```powershell
.\NetworkDeviceScanner.ps1 -Subnets "192.168.1.0/24","192.168.2.0/24"
```

### Custom Timeout for Fast Networks

```powershell
.\NetworkDeviceScanner.ps1 -Timeout 500
```

### Custom Port List

```powershell
.\NetworkDeviceScanner.ps1 -Ports 80,443,8080,8123
```

### Combined Parameters

```powershell
.\NetworkDeviceScanner.ps1 `
    -Subnets "192.168.1.0/24","192.168.2.0/24" `
    -Ports 80,443,8080,8443,8123 `
    -Timeout 500
```

## Parameters

### -Subnets
**Type:** `string[]`  
**Required:** No  
**Default:** Auto-detected from local network adapters

Array of subnet ranges in CIDR notation (e.g., "192.168.1.0/24").

**Examples:**
```powershell
-Subnets "192.168.1.0/24"
-Subnets "192.168.1.0/24","10.0.0.0/24"
-Subnets "172.16.0.0/16"
```

**Supported Subnet Sizes:**
- `/24` (254 hosts) - Recommended for typical home networks
- `/28` (14 hosts) - Small segments
- `/16` (65,536 hosts) - Large networks (automatically limited)

### -Ports
**Type:** `int[]`  
**Required:** No  
**Default:** `@(80, 443, 8080, 8443, 8123, 5000, 5001, 7443, 9443)`

Array of TCP ports to scan for API endpoints.

**Common Ports:**
- `80` - HTTP
- `443` - HTTPS
- `8080` - Alternative HTTP
- `8123` - Home Assistant
- `8443` - Alternative HTTPS
- `5000/5001` - Various APIs
- `7443` - UniFi Controller
- `9443` - UniFi alternative

### -Timeout
**Type:** `int`  
**Required:** No  
**Default:** `1000` (milliseconds)

Timeout in milliseconds for network operations (ping, TCP connect).

**Recommendations:**
- **Fast local network:** 500ms
- **Standard network:** 1000ms (default)
- **Slow/wireless network:** 2000-3000ms

**Impact on scan time:**
```
Total time ≈ (Number of IPs × Timeout) + (Reachable hosts × Ports × Timeout)
```

## Output Format

### Console Output

The scanner provides real-time colored output:

1. **Scan Configuration** - Shows parameters being used
2. **Phase 1: Ping Sweep** - Discovers reachable hosts
3. **Phase 2: Device Scan** - Detailed analysis of found devices
4. **Summary Report** - Organized by device type

**Color Coding:**
- 🟢 **Green** - Successfully found devices/information
- 🔵 **Cyan** - Section headers and progress
- 🟡 **Yellow** - Configuration and warnings
- ⚪ **White/Gray** - Device details

### JSON Export

Results are automatically exported to a timestamped JSON file:

**Filename:** `NetworkScan_YYYYMMDD_HHMMSS.json`

**Example:** `NetworkScan_20231215_143022.json`

**Structure:**
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
        "ContentLength": 1234,
        "Content": "..."
      }
    ],
    "ScanTime": "2023-12-15 14:30:22"
  }
]
```

## Scan Process

The scanner uses a two-phase approach for efficiency:

### Phase 1: Host Discovery (Ping Sweep)
1. Expands subnet CIDR notation to individual IP addresses
2. Sends ICMP ping to each IP (parallel-capable)
3. Collects list of reachable hosts
4. Shows progress indicator

**Optimization:** Only reachable hosts proceed to Phase 2.

### Phase 2: Detailed Device Scan
For each reachable host:

1. **Hostname Resolution** - DNS lookup
2. **MAC Address Discovery** - ARP table query
3. **Manufacturer Identification** - OUI database lookup
4. **Port Scanning** - Tests all specified ports
5. **HTTP Endpoint Probing** - Queries web services on open ports
6. **Device Classification** - Analyzes all collected data

## Device Classification Algorithm

The scanner uses a **scoring system** to classify devices:

### Scoring Factors

| Factor | Score | Category |
|--------|-------|----------|
| Keyword in hostname | +10 | Per match |
| Keyword in manufacturer | +15 | Per match |
| Matching port open | +3 | Per port |
| Keyword in HTTP content | +20 | Per match |

### Classification Logic

1. Calculates score for each category (IOTHub, IOTDevice, Security)
2. Selects category with highest score
3. Returns "Unknown" if all scores are 0

**Example:**
- Device with MAC from "Shelly" manufacturer: +15 to IOTDevice
- Port 80 open: +3 to IOTDevice (80 is in IOTDevice ports)
- HTTP content contains "Shelly": +20 to IOTDevice
- **Total:** 38 points → Classified as "IOTDevice"

## Manufacturer Database

Built-in OUI (Organizationally Unique Identifier) database for common IOT and security vendors:

| Manufacturer | OUI Prefixes | Device Types |
|--------------|--------------|--------------|
| **Ubiquiti Networks** | 00-0C-42, 00-27-22, F0-9F-C2, 74-AC-B9, 68-D7-9A | Network equipment, Security |
| **Shelly** | EC-08-6B, 84-CC-A8 | IOT switches, sensors |
| **Espressif (ESP)** | A0-20-A6, 24-0A-C4, 30-AE-A4 | ESP8266/ESP32 devices |
| **Philips Hue** | 00-17-88 | Smart lighting |
| **Ajax Systems** | 00-17-33 | Security systems |
| **Hikvision** | 00-12-12, 44-19-B6 | Security cameras, NVR |
| **TP-Link** | D0-73-D5 | Smart devices |

## Known Limitations

### Platform Limitations
- ✅ **Windows 11 required** - Uses Windows-specific cmdlets
- ❌ **Not compatible** with PowerShell Core on Linux/macOS
- ⚠️ **Administrator privileges** may be required for full functionality

### Network Limitations
- **MAC addresses** only visible on same subnet (Layer 2)
- **Hostname resolution** depends on DNS/NetBIOS configuration
- **Firewalls** may block ICMP or TCP connections
- **Stealth devices** may not respond to ping
- **Large subnets** (>/16) automatically limited to prevent excessive scanning

### Performance Considerations
- **Scan time** increases with subnet size and number of ports
- **Timeout settings** significantly impact total scan duration
- **Network congestion** may cause false negatives

**Example scan times (estimated):**
- /28 subnet (14 hosts): ~30 seconds
- /24 subnet (254 hosts): ~5-10 minutes
- /16 subnet (65,536 hosts): Limited for safety

### Security Considerations
- **SSL certificate validation** temporarily disabled for self-signed certificates
- **Certificate callback** always restored, even on errors
- **Read-only operations** - Script does not modify network devices
- **Local execution** - No data transmitted externally
- **Sensitive data** - JSON export contains network topology (protect accordingly)

## Troubleshooting

See [USER_GUIDE.md](USER_GUIDE.md#troubleshooting) for detailed troubleshooting steps.

**Common Issues:**
- No devices found → Check firewall settings
- Permission errors → Run as Administrator
- Slow scanning → Adjust timeout parameter
- SSL errors → Normal for self-signed certificates (handled automatically)

## Advanced Topics

For advanced usage, development information, and technical details:

- **[User Guide](USER_GUIDE.md)** - Step-by-step instructions and scenarios
- **[Technical Reference](TECHNICAL_REFERENCE.md)** - Function documentation and API details
- **[Examples](EXAMPLES.md)** - Real-world usage scenarios and integration

## Security Best Practices

1. **Scan authorization** - Only scan networks you own or have permission to scan
2. **Rate limiting** - Use appropriate timeout values to avoid network flooding
3. **Legal compliance** - Unauthorized network scanning may violate laws
4. **Data protection** - Treat JSON exports as sensitive (contains network topology)
5. **Firewall impact** - Scanning may trigger security alerts

## Version History

### Version 1.0 (Current)
- Initial release
- 13 isolated functions
- 3 device classification categories
- Multi-subnet scanning
- JSON export
- Comprehensive error handling
- SSL certificate handling
- Progress indicators

## Support

For issues, questions, or contributions:
- Review the [User Guide](USER_GUIDE.md)
- Check the [Technical Reference](TECHNICAL_REFERENCE.md)
- See [Examples](EXAMPLES.md) for common scenarios

## License

See [LICENSE](../LICENSE) file for details.
