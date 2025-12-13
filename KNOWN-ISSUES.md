# Known Issues - LAN Device Scanner

**Last Updated**: 2025-12-13  
**Version**: 1.0 (Initial Release)  
**Status**: ⚠️ **NOT PRODUCTION READY - CRITICAL ISSUES PRESENT**

---

## ⚠️ IMPORTANT NOTICE

This script has undergone comprehensive testing (56 test cases, 66.1% pass rate) and contains **one critical bug** that prevents full workflow execution. Additional issues affect return value consistency. Please review all issues below before using this script.

---

## 🔴 CRITICAL ISSUES (MUST FIX BEFORE PRODUCTION)

### Issue #1: Reserved Variable Name Conflict - `$host`

**Severity**: 🔴 **CRITICAL** - Blocks execution  
**Location**: `Scan-LANDevices.ps1`, Line 931  
**Discovered**: 2025-12-13 by test-agent  
**Status**: ❌ **UNFIXED**

#### Problem Description

The main scan orchestration function `Start-LANDeviceScan` uses `$host` as a loop variable, which conflicts with PowerShell's built-in `$Host` automatic variable (read-only). This prevents the script from executing the full device scanning workflow.

#### Affected Code

```powershell
# Line 931-936 in Start-LANDeviceScan function
foreach ($host in $allHosts) {
    $counter++
    Write-Progress -Activity "Discovering devices" -Status "Processing $host ($counter of $($allHosts.Count))" -PercentComplete (($counter / $allHosts.Count) * 100)
    
    $deviceInfo = Get-DeviceInformation -IPAddress $host
    $devices += $deviceInfo
}
```

#### Error Message

```
RuntimeException: Cannot overwrite variable Host because it is read-only or constant.
```

#### Impact

- ❌ **Complete workflow failure** - Script cannot complete device discovery
- ❌ **All integration tests fail**
- ❌ **No workaround available** without code modification

#### Required Fix

Replace the variable name `$host` with `$hostIP` or any other non-reserved name:

```powershell
# CORRECTED CODE - Apply this fix
foreach ($hostIP in $allHosts) {
    $counter++
    Write-Progress -Activity "Discovering devices" -Status "Processing $hostIP ($counter of $($allHosts.Count))" -PercentComplete (($counter / $allHosts.Count) * 100)
    
    $deviceInfo = Get-DeviceInformation -IPAddress $hostIP
    $devices += $deviceInfo
}
```

#### Recommended Actions

1. **DO NOT USE** the script in its current state for production
2. Apply the fix above before attempting full network scans
3. Test the fixed version thoroughly in your environment
4. Individual functions work correctly and can be imported separately

#### Estimated Fix Time

- **Simple fix**: 5 minutes (find and replace)
- **Testing**: 15-30 minutes
- **Total**: ~30 minutes

---

## 🟡 HIGH PRIORITY ISSUES

### Issue #2: Inconsistent Return Types - Functions Return `$null`

**Severity**: 🟡 **HIGH** - May cause runtime errors  
**Impact**: Multiple functions  
**Status**: ⚠️ **NEEDS FIX**

#### Problem Description

Several functions return `$null` when they fail to retrieve data, instead of returning safe default values (empty strings, empty arrays, or empty hashtables). This requires extensive null checking in caller code and may cause unexpected errors.

#### Affected Functions

| Function | Current Behavior | Recommended Behavior |
|----------|------------------|---------------------|
| `Get-DeviceHostname` | Returns `$null` | Should return IP address or "Unknown" |
| `Get-DeviceMACAddress` | Returns `$null` | Should return empty string `""` |
| `Get-OpenPorts` | Returns `$null` | Should return empty array `@()` |
| `Get-HTTPDeviceInfo` | Returns `$null` | Should return empty hashtable `@{}` |
| `Find-APIEndpoints` | Returns `$null` | Should return empty array `@()` |
| `Invoke-SubnetScan` | Returns single string | Should always return array `@()` |

#### Example Issues

```powershell
# This will fail if hostname lookup fails
$hostname = Get-DeviceHostname -IPAddress "192.168.1.100"
Write-Host "Device: $hostname"  # Error if $hostname is $null

# This will fail if no ports are open
$ports = Get-OpenPorts -IPAddress "192.168.1.100"
foreach ($port in $ports) {  # Error: cannot iterate $null
    Write-Host "Port: $port"
}
```

#### Required Workaround (Until Fixed)

Always check for `$null` before using function results:

```powershell
# SAFE: Check for null before use
$hostname = Get-DeviceHostname -IPAddress "192.168.1.100"
if ($hostname) {
    Write-Host "Device: $hostname"
} else {
    Write-Host "Device: Unknown"
}

# SAFE: Check for null and use safe defaults
$ports = Get-OpenPorts -IPAddress "192.168.1.100"
if (-not $ports) {
    $ports = @()  # Use empty array
}
foreach ($port in $ports) {
    Write-Host "Port: $port"
}

# ALTERNATIVE: Use ErrorAction parameter
$hostname = Get-DeviceHostname -IPAddress "192.168.1.100" -ErrorAction SilentlyContinue
$hostname = if ($hostname) { $hostname } else { "Unknown" }
```

#### Impact on Users

- ⚠️ Requires defensive programming with null checks
- ⚠️ May cause `NullReferenceException` errors
- ⚠️ Complicates script usage for end users
- ⚠️ Reduces code readability

#### Estimated Fix Time

- **Per function**: 30-60 minutes
- **All 6 functions**: 2-4 hours
- **Testing**: 1-2 hours
- **Total**: 3-6 hours

---

### Issue #3: Empty Array Parameter Validation

**Severity**: 🟡 **MEDIUM** - Affects error handling  
**Location**: `Show-DeviceScanResults` function  
**Status**: ⚠️ **NEEDS FIX**

#### Problem Description

The `Show-DeviceScanResults` function has parameter validation that prevents passing empty arrays, which is a valid scenario when no devices are found.

#### Error Message

```
Cannot bind argument to parameter 'Devices' because it is an empty array.
```

#### Required Workaround

Check array length before calling the function:

```powershell
# WORKAROUND: Check before calling
if ($devices -and $devices.Count -gt 0) {
    Show-DeviceScanResults -Devices $devices
} else {
    Write-Host "No devices found." -ForegroundColor Yellow
}
```

#### Recommended Fix

Remove or modify the parameter validation:

```powershell
# Current (problematic)
[Parameter(Mandatory=$true)]
[object[]]$Devices

# Recommended fix option 1: Allow empty
[Parameter(Mandatory=$false)]
[object[]]$Devices = @()

# Recommended fix option 2: Handle in function body
[Parameter(Mandatory=$true)]
[AllowEmptyCollection()]
[object[]]$Devices
```

---

### Issue #4: Missing Timestamp in JSON Export

**Severity**: 🟡 **MEDIUM** - Documentation issue  
**Location**: `Export-DeviceScanResults` function  
**Status**: ⚠️ **NEEDS FIX**

#### Problem Description

The exported JSON file includes a `ScanDate` field, but it's set to `$null` instead of the actual scan timestamp.

#### Example Output

```json
{
  "ScanDate": null,
  "Devices": [...]
}
```

#### Impact

- ⚠️ Cannot track when scan was performed
- ⚠️ Difficult to compare historical scans
- ⚠️ Reduces audit trail capability

#### Recommended Fix

Ensure timestamp is properly captured and exported:

```powershell
# Add to Export-DeviceScanResults function
$exportData = @{
    ScanDate = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
    Devices = $Devices
}
```

---

## 🟢 LOW PRIORITY ISSUES

### Issue #5: Get-DeviceType Parameter Signature Unclear

**Severity**: 🟢 **LOW** - Documentation/usability  
**Location**: `Get-DeviceType` function  
**Status**: ⚠️ **MINOR**

#### Problem Description

The `Get-DeviceType` function parameter signature is not clearly documented in tests, leading to test failures. Function appears to work but needs clearer documentation.

#### Recommendation

- Add comprehensive parameter documentation
- Add usage examples in function comments
- Clarify expected input types

---

## 🔵 PLATFORM-SPECIFIC LIMITATIONS

### Windows-Only Features

**Severity**: 🔵 **INFORMATIONAL** - By design  
**Impact**: Cross-platform usage  
**Status**: ✅ **EXPECTED BEHAVIOR**

#### Affected Features

1. **Local Subnet Auto-Detection** (`Get-LocalSubnets`)
   - **Requires**: `Get-NetAdapter` cmdlet (Windows only)
   - **Availability**: Windows PowerShell 3.0+, PowerShell Core 6+ on Windows
   - **Linux/macOS**: Not available

2. **MAC Address Retrieval** (`Get-DeviceMACAddress`)
   - **Requires**: ARP cache access (Windows commands)
   - **Availability**: Windows only
   - **Linux/macOS**: Limited functionality

#### Workaround

Use manual subnet specification (works cross-platform):

```powershell
# Works on Windows, Linux, and macOS
.\Scan-LANDevices.ps1 -SubnetCIDR @("192.168.1.0/24", "192.168.2.0/24")
```

#### Impact

- ✅ Core scanning functionality works cross-platform
- ⚠️ Auto-detection requires Windows
- ⚠️ MAC address lookup requires Windows

---

## 📊 TESTING LIMITATIONS

### What Was NOT Tested

**Severity**: 🔵 **INFORMATIONAL**  
**Status**: ⚠️ **USER VALIDATION REQUIRED**

#### Environment Constraints

The script was tested under the following limitations:

1. **No Real IoT Devices**
   - ❌ No actual Home Assistant instances tested
   - ❌ No actual Shelly devices tested
   - ❌ No actual Ubiquiti/UniFi devices tested
   - ❌ No actual Ajax Security Hubs tested
   - ❌ No actual NVR/Camera devices tested

2. **Linux Test Environment**
   - ❌ Not tested on Windows 11 (target platform)
   - ❌ Windows-specific features not validated
   - ❌ MAC address retrieval not tested
   - ✅ Tested on PowerShell Core 7.4.13 (Linux)

3. **Scale Limitations**
   - ❌ Full /24 subnet scans not performed (time constraints)
   - ❌ Multi-subnet scanning at scale not tested
   - ✅ Small subnet performance validated (<5 hosts)

#### Recommendations

Users should validate in their own environment:

1. **Test with your actual devices** - Device detection signatures may vary
2. **Test on Windows 11** - Target platform validation required
3. **Test at expected scale** - Performance may vary with network size
4. **Verify API endpoints** - Device firmware versions may differ

#### Test Results Summary

- **56 test cases** executed
- **37 passed** (66.1%)
- **19 failed** (33.9%)
- **All 19 functions** validated for isolation and modularity ✅
- **Performance targets** met for tested scenarios ✅

---

## 🔒 SECURITY CONSIDERATIONS

### Known Security Trade-offs

1. **Certificate Validation Disabled**
   - **Why**: To allow scanning devices with self-signed certificates
   - **Risk**: Susceptible to MITM attacks during scanning
   - **Recommendation**: Use only on trusted networks

2. **Network Scanning Activity**
   - **Impact**: May trigger security alerts/IDS systems
   - **Recommendation**: Notify network administrators before scanning
   - **Consideration**: Scanning may be logged by security devices

3. **Administrator Privileges**
   - **Why**: Required for ARP cache access and some network operations
   - **Risk**: Running with elevated privileges
   - **Recommendation**: Review code before running as admin

---

## 📈 PERFORMANCE CHARACTERISTICS

### Expected Performance

Based on testing and estimates:

| Scenario | Expected Duration | Notes |
|----------|------------------|-------|
| Small subnet (/30, 2-4 hosts) | <5 seconds | ✅ Tested |
| Medium subnet (/28, 16 hosts) | 10-20 seconds | Estimated |
| Standard subnet (/24, 254 hosts) | 2-3 minutes | Estimated |
| Multiple /24 subnets | 2-3 min per subnet | Estimated |

### Performance Issues

1. **HTTP Timeout Delays**
   - Unreachable HTTP devices: 10-20 seconds per device
   - API endpoint discovery: 60-80 seconds per device with no APIs
   - **Recommendation**: Adjust timeout parameters for your network

2. **Thread Count Tuning**
   - Default: 50 threads
   - **Fast network**: Increase to 100 threads
   - **Slow network/low resources**: Decrease to 25 threads

### Performance Tuning

```powershell
# Faster scan (good network, modern hardware)
.\Scan-LANDevices.ps1 -Timeout 50 -Threads 100

# Slower scan (slower network, limited resources)
.\Scan-LANDevices.ps1 -Timeout 200 -Threads 25
```

---

## 🛠️ WORKAROUND SUMMARY

### Quick Reference for Current Issues

```powershell
# WORKAROUND 1: Don't run full scan (use individual functions)
# Import functions individually
. .\Scan-LANDevices.ps1

# Use specific functions that work
$cidr = ConvertFrom-CIDR -CIDR "192.168.1.0/24"
$aliveHost = Test-HostAlive -IPAddress "192.168.1.100"
$hostname = Get-DeviceHostname -IPAddress "192.168.1.100"

# WORKAROUND 2: Always check for null
$result = Get-DeviceHostname -IPAddress $ip
if ($result) {
    # Use result
} else {
    # Handle null
}

# WORKAROUND 3: Manual subnet specification (cross-platform)
.\Scan-LANDevices.ps1 -SubnetCIDR @("192.168.1.0/24")
```

---

## 📋 FIX PRIORITY ROADMAP

### Immediate (Before Any Production Use)
1. 🔴 **Fix `$host` variable conflict** (Line 931)
2. 🟡 **Document null return behavior** clearly

### Short Term (Next Release)
1. 🟡 **Fix inconsistent return types** (all functions)
2. 🟡 **Fix empty array validation** (`Show-DeviceScanResults`)
3. 🟡 **Add timestamp to JSON export**

### Medium Term (Future Enhancement)
1. 🟢 **Improve Get-DeviceType documentation**
2. 🟢 **Add real device testing with multiple device types**
3. 🟢 **Windows 11 validation testing**
4. 🟢 **Performance optimization for large networks**

### Long Term (Nice to Have)
1. 🔵 **Cross-platform MAC address retrieval**
2. 🔵 **Linux/macOS subnet auto-detection**
3. 🔵 **Additional device type support**

---

## 🤝 REPORTING NEW ISSUES

If you discover additional issues:

1. **Check this document** - Your issue may already be known
2. **Document the error** - Include full error messages and context
3. **Provide reproduction steps** - Help others reproduce the issue
4. **Include your environment** - OS, PowerShell version, device types
5. **Report through repository issues** - Follow the project's issue template

---

## 📚 RELATED DOCUMENTATION

- [User Guide](USER-GUIDE.md) - How to use the script
- [Developer Guide](DEVELOPER-GUIDE.md) - How to extend the script
- [Prerequisites](PREREQUISITES.md) - Requirements and compatibility
- [Test Report](TEST-REPORT.md) - Detailed test results
- [Test Summary](TEST-SUMMARY.md) - Quick test overview

---

**Last Updated**: 2025-12-13  
**Document Version**: 1.0  
**Next Review**: After critical bug fixes are applied
