# Developer Guide - LAN Device Scanner

**Version**: 1.0  
**Last Updated**: 2025-12-13  
**Target Audience**: Developers and Contributors

---

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Code Structure](#code-structure)
3. [Function Reference](#function-reference)
4. [Extending the Script](#extending-the-script)
5. [Adding New Device Types](#adding-new-device-types)
6. [Testing](#testing)
7. [Code Quality](#code-quality)
8. [Contributing](#contributing)
9. [Development Workflow](#development-workflow)

---

## Architecture Overview

### Design Principles

The LAN Device Scanner is built on these core principles:

1. **Modular Design**: 19 isolated, independent functions
2. **Separation of Concerns**: Each function has a single responsibility
3. **No Circular Dependencies**: Functions can be imported independently
4. **Composable**: Functions can be chained for custom workflows
5. **Error-Tolerant**: Graceful handling of network failures

### Architectural Layers

```
┌─────────────────────────────────────────┐
│     Output Layer (Display/Export)       │
│  - Show-DeviceScanResults               │
│  - Export-DeviceScanResults             │
└─────────────────────────────────────────┘
                    ▲
┌─────────────────────────────────────────┐
│   Orchestration Layer (Workflows)       │
│  - Start-LANDeviceScan                  │
│  - Get-DeviceInformation                │
└─────────────────────────────────────────┘
                    ▲
┌─────────────────────────────────────────┐
│    Discovery Layer (Intelligence)       │
│  - Find-APIEndpoints                    │
│  - Get-DeviceType                       │
│  - Test-HomeAssistant                   │
│  - Test-ShellyDevice                    │
│  - Test-UbiquitiDevice                  │
│  - Test-AjaxSecurityHub                 │
└─────────────────────────────────────────┘
                    ▲
┌─────────────────────────────────────────┐
│  Information Gathering Layer            │
│  - Get-DeviceHostname                   │
│  - Get-DeviceMACAddress                 │
│  - Get-OpenPorts                        │
│  - Get-HTTPDeviceInfo                   │
└─────────────────────────────────────────┘
                    ▲
┌─────────────────────────────────────────┐
│     Scanning Layer (Network)            │
│  - Test-HostAlive                       │
│  - Invoke-SubnetScan                    │
└─────────────────────────────────────────┘
                    ▲
┌─────────────────────────────────────────┐
│      Utility Layer (Helpers)            │
│  - ConvertFrom-CIDR                     │
│  - ConvertTo-IPAddress                  │
│  - Get-LocalSubnets                     │
└─────────────────────────────────────────┘
```

### Data Flow

```
1. Subnet Detection/Input
   ↓
2. Ping Scan (Parallel)
   ↓
3. Alive Hosts List
   ↓
4. Device Information Gathering (Per Host)
   ├─ Hostname Resolution
   ├─ MAC Address Lookup
   ├─ Port Scanning
   └─ HTTP Probing
   ↓
5. Device Type Identification
   ├─ Pattern Matching
   ├─ Signature Detection
   └─ Confidence Scoring
   ↓
6. API Endpoint Discovery
   ├─ Common Paths
   └─ Device-Specific Paths
   ↓
7. Results Aggregation
   ↓
8. Output (Console + JSON)
```

---

## Code Structure

### File Organization

```
Scan-LANDevices.ps1 (1,069 lines)
├─ Script Parameters (Lines 1-50)
├─ Helper Functions (Lines 51-200)
│  ├─ ConvertFrom-CIDR
│  ├─ ConvertTo-IPAddress
│  └─ Get-LocalSubnets
├─ Scanning Functions (Lines 201-450)
│  ├─ Test-HostAlive
│  └─ Invoke-SubnetScan
├─ Device Discovery Functions (Lines 451-650)
│  ├─ Get-DeviceHostname
│  ├─ Get-DeviceMACAddress
│  ├─ Get-OpenPorts
│  └─ Get-HTTPDeviceInfo
├─ Device Type Functions (Lines 651-850)
│  ├─ Test-HomeAssistant
│  ├─ Test-ShellyDevice
│  ├─ Test-UbiquitiDevice
│  ├─ Test-AjaxSecurityHub
│  └─ Get-DeviceType
├─ API Discovery Functions (Lines 851-900)
│  └─ Find-APIEndpoints
├─ Orchestration Functions (Lines 901-1000)
│  ├─ Get-DeviceInformation
│  └─ Start-LANDeviceScan
└─ Output Functions (Lines 1001-1069)
   ├─ Show-DeviceScanResults
   └─ Export-DeviceScanResults
```

### Naming Conventions

| Pattern | Purpose | Examples |
|---------|---------|----------|
| `Get-*` | Retrieve information | Get-DeviceHostname, Get-OpenPorts |
| `Test-*` | Boolean checks/validation | Test-HostAlive, Test-HomeAssistant |
| `Invoke-*` | Execute operations | Invoke-SubnetScan |
| `ConvertFrom-*` | Parse/convert input | ConvertFrom-CIDR |
| `ConvertTo-*` | Format output | ConvertTo-IPAddress |
| `Show-*` | Display to console | Show-DeviceScanResults |
| `Export-*` | Save to file | Export-DeviceScanResults |
| `Find-*` | Search/discover | Find-APIEndpoints |
| `Start-*` | Initiate workflows | Start-LANDeviceScan |

---

## Function Reference

### Helper Functions

#### ConvertFrom-CIDR

**Purpose**: Convert CIDR notation to IP range and host count

**Parameters**:
```powershell
[Parameter(Mandatory=$true)]
[string]$CIDR  # e.g., "192.168.1.0/24"
```

**Returns**: 
```powershell
@{
    NetworkAddress = "192.168.1.0"
    BroadcastAddress = "192.168.1.255"
    FirstHost = "192.168.1.1"
    LastHost = "192.168.1.254"
    TotalHosts = 254
    Netmask = "255.255.255.0"
}
```

**Example**:
```powershell
$subnet = ConvertFrom-CIDR -CIDR "192.168.1.0/24"
Write-Host "Will scan $($subnet.TotalHosts) hosts"
```

---

#### ConvertTo-IPAddress

**Purpose**: Convert 32-bit integer to IP address string

**Parameters**:
```powershell
[Parameter(Mandatory=$true)]
[uint32]$Integer  # 0 to 4294967295
```

**Returns**: String (IP address)

**Example**:
```powershell
$ip = ConvertTo-IPAddress -Integer 3232235777
# Returns: "192.168.1.1"
```

---

#### Get-LocalSubnets

**Purpose**: Auto-detect local network subnets from active adapters

**Parameters**: None

**Returns**: Array of CIDR strings

**Platform**: Windows only (requires `Get-NetAdapter`)

**Example**:
```powershell
$subnets = Get-LocalSubnets
# Returns: @("192.168.1.0/24", "10.0.0.0/24")
```

---

### Scanning Functions

#### Test-HostAlive

**Purpose**: Perform ICMP ping test on single host

**Parameters**:
```powershell
[Parameter(Mandatory=$true)]
[string]$IPAddress

[Parameter(Mandatory=$false)]
[int]$Timeout = 100  # milliseconds
```

**Returns**: Boolean

**Example**:
```powershell
$isAlive = Test-HostAlive -IPAddress "192.168.1.100" -Timeout 200
if ($isAlive) { Write-Host "Host is online" }
```

---

#### Invoke-SubnetScan

**Purpose**: Parallel scan of subnet for alive hosts

**Parameters**:
```powershell
[Parameter(Mandatory=$true)]
[string]$CIDR

[Parameter(Mandatory=$false)]
[int]$Timeout = 100

[Parameter(Mandatory=$false)]
[int]$Threads = 50
```

**Returns**: Array of IP addresses (strings)

**Example**:
```powershell
$aliveHosts = Invoke-SubnetScan -CIDR "192.168.1.0/24" -Threads 100
Write-Host "Found $($aliveHosts.Count) alive hosts"
```

**Note**: Uses PowerShell runspaces for parallelization

---

### Device Discovery Functions

#### Get-DeviceHostname

**Purpose**: Resolve IP address to hostname via DNS

**Parameters**:
```powershell
[Parameter(Mandatory=$true)]
[string]$IPAddress
```

**Returns**: String (hostname) or `$null`

**⚠️ Known Issue**: Returns `$null` instead of fallback value

**Example**:
```powershell
$hostname = Get-DeviceHostname -IPAddress "192.168.1.100"
if ($hostname) {
    Write-Host "Hostname: $hostname"
} else {
    Write-Host "Hostname: Unknown"
}
```

---

#### Get-DeviceMACAddress

**Purpose**: Retrieve MAC address from ARP cache or network query

**Parameters**:
```powershell
[Parameter(Mandatory=$true)]
[string]$IPAddress
```

**Returns**: String (MAC address) or `$null`

**Platform**: Windows only (uses `arp` command)

**⚠️ Known Issue**: Returns `$null` instead of empty string

**Example**:
```powershell
$mac = Get-DeviceMACAddress -IPAddress "192.168.1.100"
if ($mac) {
    Write-Host "MAC: $mac"
}
```

---

#### Get-OpenPorts

**Purpose**: Scan common ports for connectivity

**Parameters**:
```powershell
[Parameter(Mandatory=$true)]
[string]$IPAddress

[Parameter(Mandatory=$false)]
[int]$Timeout = 1000  # milliseconds per port
```

**Returns**: Array of integers (port numbers) or `$null`

**Ports Scanned**: 80, 443, 554, 3000, 8000, 8080, 8081, 8123, 8443, 9000, 9443

**⚠️ Known Issue**: Returns `$null` instead of empty array `@()`

**Example**:
```powershell
$ports = Get-OpenPorts -IPAddress "192.168.1.100"
if ($ports) {
    Write-Host "Open ports: $($ports -join ', ')"
}
```

---

#### Get-HTTPDeviceInfo

**Purpose**: Probe HTTP/HTTPS for device information

**Parameters**:
```powershell
[Parameter(Mandatory=$true)]
[string]$IPAddress

[Parameter(Mandatory=$true)]
[int]$Port
```

**Returns**: Hashtable or `$null`

**Return Structure**:
```powershell
@{
    Title = "Device Title"
    Server = "nginx/1.18.0"
    StatusCode = 200
    ContentType = "text/html"
    Headers = @{...}
    Body = "HTML content..."
}
```

**⚠️ Known Issue**: Returns `$null` instead of empty hashtable

**Example**:
```powershell
$httpInfo = Get-HTTPDeviceInfo -IPAddress "192.168.1.100" -Port 80
if ($httpInfo) {
    Write-Host "Title: $($httpInfo.Title)"
    Write-Host "Server: $($httpInfo.Server)"
}
```

---

### Device Type Identification Functions

#### Test-HomeAssistant

**Purpose**: Detect Home Assistant instance

**Parameters**:
```powershell
[Parameter(Mandatory=$true)]
[string]$IPAddress

[Parameter(Mandatory=$true)]
[int[]]$OpenPorts
```

**Returns**: Hashtable

**Return Structure**:
```powershell
@{
    IsHomeAssistant = $true/$false
    Confidence = 0-100
    Evidence = @("Evidence string 1", "Evidence string 2")
}
```

**Detection Logic**:
- Port 8123 open: +50% confidence
- "Home Assistant" in HTTP title: +30% confidence
- Specific headers present: +20% confidence

**Example**:
```powershell
$result = Test-HomeAssistant -IPAddress "192.168.1.100" -OpenPorts @(8123, 80)
if ($result.IsHomeAssistant) {
    Write-Host "Home Assistant detected with $($result.Confidence)% confidence"
}
```

---

#### Test-ShellyDevice

**Purpose**: Detect Shelly IoT device

**Parameters**:
```powershell
[Parameter(Mandatory=$true)]
[string]$IPAddress

[Parameter(Mandatory=$true)]
[int[]]$OpenPorts
```

**Returns**: Hashtable (same structure as Test-HomeAssistant)

**Detection Logic**:
- "Shelly" in HTTP response: +60% confidence
- `/shelly` endpoint exists: +40% confidence

---

#### Test-UbiquitiDevice

**Purpose**: Detect Ubiquiti/UniFi device

**Parameters**:
```powershell
[Parameter(Mandatory=$true)]
[string]$IPAddress

[Parameter(Mandatory=$true)]
[int[]]$OpenPorts
```

**Returns**: Hashtable (same structure as Test-HomeAssistant)

**Detection Logic**:
- Port 8443 open: +40% confidence
- "UniFi" in HTTP response: +60% confidence

---

#### Test-AjaxSecurityHub

**Purpose**: Detect Ajax Security Hub

**Parameters**:
```powershell
[Parameter(Mandatory=$true)]
[string]$IPAddress

[Parameter(Mandatory=$true)]
[int[]]$OpenPorts
```

**Returns**: Hashtable (same structure as Test-HomeAssistant)

**Detection Logic**:
- "Ajax" in HTTP response: +70% confidence
- Specific headers/patterns: +30% confidence

---

#### Get-DeviceType

**Purpose**: Orchestrate device type identification

**Parameters**:
```powershell
[Parameter(Mandatory=$true)]
[string]$IPAddress

[Parameter(Mandatory=$true)]
[int[]]$OpenPorts

[Parameter(Mandatory=$false)]
[hashtable]$HTTPInfo = @{}
```

**Returns**: Hashtable

**Return Structure**:
```powershell
@{
    DeviceType = "IoT Hub" | "IoT Device" | "Security Device" | "Network Device"
    SubType = "Home Assistant" | "Shelly" | "Ubiquiti" | "Ajax" | "NVR/Camera" | "Unknown"
    Confidence = 0-100
    Evidence = @("Evidence strings...")
}
```

**Example**:
```powershell
$deviceType = Get-DeviceType -IPAddress "192.168.1.100" -OpenPorts @(8123, 80)
Write-Host "Device Type: $($deviceType.SubType) ($($deviceType.Confidence)%)"
```

---

### API Discovery Functions

#### Find-APIEndpoints

**Purpose**: Discover API endpoints on device

**Parameters**:
```powershell
[Parameter(Mandatory=$true)]
[string]$IPAddress

[Parameter(Mandatory=$true)]
[int[]]$OpenPorts

[Parameter(Mandatory=$false)]
[string]$DeviceType = "Unknown"
```

**Returns**: Array of hashtables or `$null`

**Return Structure**:
```powershell
@(
    @{
        URL = "http://192.168.1.100:8123/api/"
        StatusCode = 200
        ContentType = "application/json"
        RequiresAuth = $false
    }
)
```

**Probed Paths**:
- Common: `/api`, `/api/v1`, `/api/v2`, `/rest`, `/graphql`, `/swagger`
- Home Assistant: `/api/`, `/api/config`, `/api/states`, `/auth`
- Shelly: `/shelly`, `/status`, `/settings`, `/rpc`
- Ubiquiti: `/api/auth`, `/api/system`, `/api/s/default`
- Ajax: `/api/panel`, `/api/devices`

**⚠️ Known Issue**: Returns `$null` instead of empty array

**Example**:
```powershell
$apis = Find-APIEndpoints -IPAddress "192.168.1.100" -OpenPorts @(8123) -DeviceType "Home Assistant"
if ($apis) {
    foreach ($api in $apis) {
        Write-Host "$($api.URL) - Status: $($api.StatusCode)"
    }
}
```

---

### Orchestration Functions

#### Get-DeviceInformation

**Purpose**: Complete device discovery pipeline for single host

**Parameters**:
```powershell
[Parameter(Mandatory=$true)]
[string]$IPAddress
```

**Returns**: Hashtable with complete device information

**Return Structure**:
```powershell
@{
    IPAddress = "192.168.1.100"
    Hostname = "device.local"
    MACAddress = "AA:BB:CC:DD:EE:FF"
    DeviceType = "IoT Hub"
    SubType = "Home Assistant"
    Confidence = 80
    Evidence = @("Evidence...")
    OpenPorts = @(8123, 80, 443)
    APIEndpoints = @(...)
}
```

**Example**:
```powershell
$deviceInfo = Get-DeviceInformation -IPAddress "192.168.1.100"
Show-DeviceScanResults -Devices @($deviceInfo)
```

---

#### Start-LANDeviceScan

**Purpose**: Main scan orchestration workflow

**Parameters**:
```powershell
[Parameter(Mandatory=$false)]
[string[]]$SubnetCIDR = @()

[Parameter(Mandatory=$false)]
[int]$Timeout = 100

[Parameter(Mandatory=$false)]
[int]$Threads = 50
```

**Returns**: Array of device information hashtables

**🔴 Critical Bug**: Line 931 uses `$host` variable (reserved)

**Workflow**:
1. Detect or use provided subnets
2. Scan each subnet for alive hosts
3. Discover information for each host
4. Display and export results

**Example** (after bug fix):
```powershell
$devices = Start-LANDeviceScan -SubnetCIDR @("192.168.1.0/24") -Threads 50
```

---

### Output Functions

#### Show-DeviceScanResults

**Purpose**: Display results in formatted console output

**Parameters**:
```powershell
[Parameter(Mandatory=$true)]
[object[]]$Devices
```

**⚠️ Known Issue**: Cannot accept empty arrays

**Example**:
```powershell
if ($devices -and $devices.Count -gt 0) {
    Show-DeviceScanResults -Devices $devices
}
```

---

#### Export-DeviceScanResults

**Purpose**: Export results to timestamped JSON file

**Parameters**:
```powershell
[Parameter(Mandatory=$true)]
[object[]]$Devices
```

**Output**: `DeviceScan_YYYYMMDD_HHMMSS.json`

**⚠️ Known Issue**: `ScanDate` field is `$null`

**Example**:
```powershell
Export-DeviceScanResults -Devices $devices
```

---

## Extending the Script

### Adding New Device Types

Follow these steps to add support for a new device type:

#### Step 1: Create Detection Function

```powershell
function Test-MyNewDevice {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$IPAddress,
        
        [Parameter(Mandatory=$true)]
        [int[]]$OpenPorts
    )
    
    $indicators = @{
        IsMyNewDevice = $false
        Confidence = 0
        Evidence = @()
    }
    
    # Check for specific ports
    if (12345 -in $OpenPorts) {
        $indicators.Confidence += 40
        $indicators.Evidence += "Port 12345 is open (MyDevice default)"
    }
    
    # Check HTTP response
    if (80 -in $OpenPorts) {
        $httpInfo = Get-HTTPDeviceInfo -IPAddress $IPAddress -Port 80
        if ($httpInfo -and $httpInfo.Title -like "*MyDevice*") {
            $indicators.Confidence += 60
            $indicators.Evidence += "MyDevice identified in HTTP response"
        }
    }
    
    # Set detection flag if confidence threshold met
    $indicators.IsMyNewDevice = ($indicators.Confidence -ge 50)
    
    return $indicators
}
```

#### Step 2: Update Get-DeviceType Function

Add your detection function to the device type orchestrator:

```powershell
function Get-DeviceType {
    # ... existing code ...
    
    # Add your new device type check
    $myDevice = Test-MyNewDevice -IPAddress $IPAddress -OpenPorts $OpenPorts
    if ($myDevice.IsMyNewDevice) {
        return @{
            DeviceType = "Custom Device Category"
            SubType = "MyNewDevice"
            Confidence = $myDevice.Confidence
            Evidence = $myDevice.Evidence
        }
    }
    
    # ... rest of existing checks ...
}
```

#### Step 3: Add Device-Specific API Endpoints

Update `Find-APIEndpoints` function:

```powershell
function Find-APIEndpoints {
    # ... existing code ...
    
    # Add device-specific paths
    $deviceSpecificPaths['MyNewDevice'] = @(
        '/mydevice/api',
        '/mydevice/status',
        '/mydevice/config'
    )
    
    # ... rest of existing code ...
}
```

#### Step 4: Test Your Addition

```powershell
# Import functions
. .\Scan-LANDevices.ps1

# Test detection
$ports = Get-OpenPorts -IPAddress "192.168.1.100"
$result = Test-MyNewDevice -IPAddress "192.168.1.100" -OpenPorts $ports

Write-Host "Detection result: $($result.IsMyNewDevice)"
Write-Host "Confidence: $($result.Confidence)%"
Write-Host "Evidence:"
$result.Evidence | ForEach-Object { Write-Host "  - $_" }
```

---

### Adding Custom API Paths

To add custom API paths for discovery:

```powershell
# In Find-APIEndpoints function, add to $commonPaths array
$commonPaths = @(
    '/api',
    '/api/v1',
    '/api/v2',
    '/rest',
    '/graphql',
    '/swagger',
    '/your/custom/path',      # Add here
    '/another/custom/path'     # Add here
)
```

---

### Creating Custom Workflows

Combine functions for custom scanning workflows:

```powershell
# Custom workflow: Fast device discovery without API scanning
function Quick-DeviceScan {
    param(
        [string]$CIDR,
        [int]$Threads = 100
    )
    
    # Fast ping scan
    $aliveHosts = Invoke-SubnetScan -CIDR $CIDR -Threads $Threads -Timeout 50
    
    $devices = @()
    foreach ($ip in $aliveHosts) {
        # Quick info only (no API discovery)
        $device = @{
            IPAddress = $ip
            Hostname = Get-DeviceHostname -IPAddress $ip
            OpenPorts = Get-OpenPorts -IPAddress $ip
        }
        $devices += $device
    }
    
    return $devices
}

# Use custom workflow
$quickResults = Quick-DeviceScan -CIDR "192.168.1.0/24"
```

---

## Testing

### Test Framework

The script uses **Pester 5.7.1** for testing.

#### Install Pester

```powershell
Install-Module -Name Pester -Force -SkipPublisherCheck
```

#### Run Tests

```powershell
# Run all tests
Invoke-Pester -Path './Scan-LANDevices.Tests.ps1' -Output Detailed

# Run specific test category
Invoke-Pester -Path './Scan-LANDevices.Tests.ps1' -Output Detailed -Tag "SubnetDetection"
```

### Test Coverage

Current test coverage (56 tests):

| Category | Tests | Coverage |
|----------|-------|----------|
| Subnet Detection | 9 | All functions |
| Network Scanning | 5 | All functions |
| Device Discovery | 8 | All functions |
| Device Type ID | 9 | All device types |
| API Discovery | 5 | Core functionality |
| Output Functions | 4 | Display and export |
| Error Scenarios | 5 | Error handling |
| Performance | 3 | Speed benchmarks |
| Compatibility | 3 | PS version checks |
| Integration | 3 | End-to-end workflows |

### Writing New Tests

Follow Pester conventions:

```powershell
Describe "MyNewDevice Detection" {
    BeforeAll {
        # Import functions
        . ./Scan-LANDevices.ps1
    }
    
    Context "When device has signature port open" {
        It "Should detect MyNewDevice" {
            $result = Test-MyNewDevice -IPAddress "127.0.0.1" -OpenPorts @(12345)
            $result.IsMyNewDevice | Should -Be $true
        }
        
        It "Should have minimum confidence" {
            $result = Test-MyNewDevice -IPAddress "127.0.0.1" -OpenPorts @(12345)
            $result.Confidence | Should -BeGreaterOrEqual 50
        }
    }
    
    Context "When device does not match" {
        It "Should not detect MyNewDevice" {
            $result = Test-MyNewDevice -IPAddress "127.0.0.1" -OpenPorts @(80, 443)
            $result.IsMyNewDevice | Should -Be $false
        }
    }
}
```

---

## Code Quality

### Current Status

- **Functions**: 19 isolated, modular functions ✅
- **Test Coverage**: 66.1% pass rate
- **Known Issues**: 5 documented bugs
- **Code Style**: PowerShell best practices
- **Documentation**: Comprehensive inline comments

### Best Practices

1. **Use CmdletBinding**: All functions should support common parameters
   ```powershell
   function My-Function {
       [CmdletBinding()]
       param(...)
   }
   ```

2. **Parameter Validation**: Use parameter attributes
   ```powershell
   [Parameter(Mandatory=$true)]
   [ValidateNotNullOrEmpty()]
   [string]$IPAddress
   ```

3. **Error Handling**: Use try-catch for external calls
   ```powershell
   try {
       $result = Invoke-WebRequest -Uri $url -TimeoutSec 5
   } catch {
       Write-Verbose "HTTP request failed: $_"
       return $null
   }
   ```

4. **Return Consistent Types**: Always return the same type
   ```powershell
   # GOOD: Always returns array
   function Get-Items {
       $items = @()
       # ... populate ...
       return $items  # Returns @() if empty
   }
   
   # BAD: Returns null or array
   function Get-Items {
       $items = @()
       if ($items.Count -eq 0) {
           return $null  # Inconsistent!
       }
       return $items
   }
   ```

5. **Verbose Output**: Use Write-Verbose for diagnostic info
   ```powershell
   Write-Verbose "Scanning port $port on $IPAddress"
   ```

---

## Contributing

### Contribution Workflow

1. **Review Known Issues**: Check [KNOWN-ISSUES.md](KNOWN-ISSUES.md)
2. **Read Test Report**: Understand current behavior in [TEST-REPORT.md](TEST-REPORT.md)
3. **Make Changes**: Follow code style and conventions
4. **Add Tests**: Create or update Pester tests
5. **Run Tests**: Verify all tests pass
6. **Document**: Update relevant documentation files

### Code Style Guidelines

- **Indentation**: 4 spaces (no tabs)
- **Line Length**: Prefer <120 characters
- **Braces**: Opening brace on same line
  ```powershell
  if ($condition) {
      # code
  }
  ```
- **Naming**: Use PowerShell approved verbs (Get, Set, Test, Invoke, etc.)
- **Comments**: Use `#` for single-line, `<# #>` for multi-line
- **Variables**: Use `$camelCase` for local variables

### Testing Guidelines

- Write tests for new functions
- Test both positive and negative cases
- Include edge cases (empty input, null values, etc.)
- Mock external dependencies when possible
- Aim for >80% code coverage

---

## Development Workflow

### Setting Up Development Environment

```powershell
# Clone repository (if using version control)
# cd to project directory

# Install dependencies
Install-Module -Name Pester -Force -SkipPublisherCheck

# Verify PowerShell version
$PSVersionTable.PSVersion  # Should be 5.1 or higher
```

### Development Cycle

1. **Make Changes**: Edit `Scan-LANDevices.ps1`
2. **Test Changes**: Run relevant Pester tests
3. **Manual Testing**: Test with real devices if possible
4. **Update Documentation**: Keep docs in sync with code
5. **Review**: Check against known issues and best practices

### Debugging

```powershell
# Enable verbose output
$VerbosePreference = "Continue"

# Test individual functions
. .\Scan-LANDevices.ps1
$result = Test-HomeAssistant -IPAddress "192.168.1.100" -OpenPorts @(8123) -Verbose

# Check variable values
Write-Host "Result: $($result | ConvertTo-Json -Depth 10)"

# Disable verbose
$VerbosePreference = "SilentlyContinue"
```

### Performance Profiling

```powershell
# Measure function execution time
Measure-Command {
    $result = Invoke-SubnetScan -CIDR "192.168.1.0/30" -Threads 50
}

# Profile specific operations
$start = Get-Date
# ... code to profile ...
$duration = (Get-Date) - $start
Write-Host "Operation took $($duration.TotalSeconds) seconds"
```

---

## Advanced Topics

### Understanding Runspace Parallelization

The script uses PowerShell runspaces for parallel scanning:

```powershell
# Runspace pool creation
$runspacePool = [runspacefactory]::CreateRunspacePool(1, $Threads)
$runspacePool.Open()

# Job creation
$jobs = @()
foreach ($ip in $ipList) {
    $powerShell = [powershell]::Create()
    $powerShell.RunspacePool = $runspacePool
    [void]$powerShell.AddScript($scriptBlock).AddArgument($ip)
    
    $jobs += @{
        PowerShell = $powerShell
        Handle = $powerShell.BeginInvoke()
    }
}

# Wait for completion
foreach ($job in $jobs) {
    $result = $job.PowerShell.EndInvoke($job.Handle)
    $job.PowerShell.Dispose()
}

$runspacePool.Close()
$runspacePool.Dispose()
```

### Confidence Scoring Algorithm

Confidence is calculated additively:

```powershell
$confidence = 0

# Each indicator adds to confidence
if (Check-Indicator1) { $confidence += 30 }
if (Check-Indicator2) { $confidence += 40 }
if (Check-Indicator3) { $confidence += 30 }

# Threshold check
$isMatch = ($confidence -ge 50)  # 50% default threshold
```

**Design Guidelines**:
- Strongest indicators: 40-60% confidence
- Medium indicators: 20-40% confidence
- Weak indicators: 10-20% confidence
- Total possible: Should sum to 100%

---

## Troubleshooting Development Issues

### Common Development Problems

#### Issue: Tests Fail After Changes

**Check**:
1. Did you maintain function signatures?
2. Did you change return types?
3. Did you break backwards compatibility?

**Solution**: Review test expectations and update accordingly

---

#### Issue: Performance Degradation

**Check**:
1. Are you making synchronous calls in loops?
2. Are timeouts too long?
3. Is thread count appropriate?

**Solution**: Profile the code and optimize bottlenecks

---

#### Issue: Cross-Platform Compatibility

**Check**:
1. Are you using Windows-only cmdlets?
2. Are file paths platform-specific?
3. Are you using platform-specific tools (e.g., `arp`)?

**Solution**: Add platform detection and conditional logic

```powershell
if ($IsWindows) {
    # Windows-specific code
} else {
    # Cross-platform alternative
}
```

---

## Resources

### PowerShell Documentation

- [PowerShell Documentation](https://docs.microsoft.com/powershell)
- [Pester Documentation](https://pester.dev)
- [PowerShell Gallery](https://www.powershellgallery.com)

### Networking Resources

- CIDR Notation: [RFC 4632](https://tools.ietf.org/html/rfc4632)
- HTTP Status Codes: [RFC 7231](https://tools.ietf.org/html/rfc7231)
- ICMP: [RFC 792](https://tools.ietf.org/html/rfc792)

### Related Projects

- **nmap**: Network exploration tool
- **Angry IP Scanner**: GUI-based scanner
- **Advanced IP Scanner**: Windows network scanner

---

## Roadmap

### Short Term (Next Release)

- [ ] Fix critical `$host` variable bug
- [ ] Fix inconsistent return types
- [ ] Add timestamp to JSON export
- [ ] Improve error messages

### Medium Term

- [ ] Add more device types (NAS, printers, etc.)
- [ ] Cross-platform MAC address lookup
- [ ] Performance optimization for large networks
- [ ] Configuration file support

### Long Term

- [ ] GUI interface
- [ ] Continuous monitoring mode
- [ ] Device change detection
- [ ] Integration with network management systems
- [ ] Plugin architecture for custom device types

---

**Document Version**: 1.0  
**Last Updated**: 2025-12-13  
**Maintainer**: Development Team  
**Status**: Initial release

---

For questions or contributions, please refer to the project repository documentation.
