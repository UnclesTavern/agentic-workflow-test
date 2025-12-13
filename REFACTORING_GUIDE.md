# Refactoring Guide for develop-agent

This guide provides specific, actionable refactoring steps to improve function isolation and maintainability.

---

## Priority 1: Get-DeviceClassification (REQUIRED)

### Current Issues
- 78 lines with 4 distinct responsibilities
- Scoring logic mixed together
- Difficult to test individual scoring algorithms

### Refactoring Steps

#### Step 1: Extract Get-KeywordScore
```powershell
<#
.SYNOPSIS
    Scores device categories based on hostname and manufacturer keywords.
#>
function Get-KeywordScore {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [string]$Hostname,
        
        [Parameter(Mandatory=$false)]
        [string]$Manufacturer,
        
        [Parameter(Mandatory=$true)]
        [hashtable]$DevicePatterns
    )
    
    $scores = @{ IOTHub = 0; IOTDevice = 0; Security = 0 }
    
    foreach ($category in $DevicePatterns.Keys) {
        $keywords = $DevicePatterns[$category].Keywords
        
        foreach ($keyword in $keywords) {
            if ($Hostname -like "*$keyword*") {
                $scores[$category] += 10
            }
            if ($Manufacturer -like "*$keyword*") {
                $scores[$category] += 15
            }
        }
    }
    
    return $scores
}
```

#### Step 2: Extract Get-PortScore
```powershell
<#
.SYNOPSIS
    Scores device categories based on open ports.
#>
function Get-PortScore {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [int[]]$OpenPorts,
        
        [Parameter(Mandatory=$true)]
        [hashtable]$DevicePatterns
    )
    
    $scores = @{ IOTHub = 0; IOTDevice = 0; Security = 0 }
    
    foreach ($category in $DevicePatterns.Keys) {
        $categoryPorts = $DevicePatterns[$category].Ports
        foreach ($port in $OpenPorts) {
            if ($categoryPorts -contains $port) {
                $scores[$category] += 3
            }
        }
    }
    
    return $scores
}
```

#### Step 3: Extract Get-ContentScore
```powershell
<#
.SYNOPSIS
    Scores device categories based on HTTP endpoint content.
#>
function Get-ContentScore {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [array]$EndpointData
    )
    
    $scores = @{ IOTHub = 0; IOTDevice = 0; Security = 0 }
    
    if ($EndpointData) {
        foreach ($endpoint in $EndpointData) {
            $content = $endpoint.Content + $endpoint.Server
            
            # IOT Hub patterns
            if ($content -match 'Home Assistant|hassio|homeassistant|openhab|hubitat') {
                $scores['IOTHub'] += 20
            }
            
            # IOT Device patterns
            if ($content -match 'Shelly|Tasmota|ESP8266|ESP32|sonoff') {
                $scores['IOTDevice'] += 20
            }
            
            # Security device patterns
            if ($content -match 'Ubiquiti|UniFi|NVR|AXIS|Hikvision|ajax') {
                $scores['Security'] += 20
            }
        }
    }
    
    return $scores
}
```

#### Step 4: Extract Get-BestScoringCategory
```powershell
<#
.SYNOPSIS
    Determines the best matching category from scores.
#>
function Get-BestScoringCategory {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [hashtable]$Scores
    )
    
    $maxScore = ($Scores.Values | Measure-Object -Maximum).Maximum
    
    if ($maxScore -eq 0) {
        return 'Unknown'
    }
    
    $bestMatch = $Scores.GetEnumerator() | Where-Object { $_.Value -eq $maxScore } | Select-Object -First 1
    return $bestMatch.Name
}
```

#### Step 5: Refactor Get-DeviceClassification
```powershell
<#
.SYNOPSIS
    Classifies a device based on hostname, manufacturer, and endpoint data.
#>
function Get-DeviceClassification {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [string]$Hostname,
        
        [Parameter(Mandatory=$false)]
        [string]$Manufacturer,
        
        [Parameter(Mandatory=$false)]
        [array]$EndpointData,
        
        [Parameter(Mandatory=$false)]
        [int[]]$OpenPorts
    )
    
    # Initialize scores
    $totalScores = @{ IOTHub = 0; IOTDevice = 0; Security = 0 }
    
    # Get scores from each classification method
    $keywordScores = Get-KeywordScore -Hostname $Hostname -Manufacturer $Manufacturer -DevicePatterns $script:DevicePatterns
    $portScores = Get-PortScore -OpenPorts $OpenPorts -DevicePatterns $script:DevicePatterns
    $contentScores = Get-ContentScore -EndpointData $EndpointData
    
    # Aggregate scores
    foreach ($category in $totalScores.Keys) {
        $totalScores[$category] = $keywordScores[$category] + $portScores[$category] + $contentScores[$category]
    }
    
    # Determine best match
    return Get-BestScoringCategory -Scores $totalScores
}
```

#### Placement in File
- Add helper functions at lines 461-540 (before Get-DeviceClassification)
- Replace Get-DeviceClassification with refactored version
- Keep in Region 4: Device Classification Functions

---

## Priority 2: Get-SubnetFromIP (REQUIRED)

### Current Issues
- Line 140 is 392 characters of complex inline calculation
- Binary conversion logic duplicated
- Nearly impossible to understand or debug

### Refactoring Steps

#### Step 1: Extract ConvertTo-PrefixLength
```powershell
<#
.SYNOPSIS
    Converts subnet mask bytes to CIDR prefix length.
#>
function ConvertTo-PrefixLength {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [byte[]]$MaskBytes
    )
    
    # Convert each byte to 8-bit binary string
    $binaryString = ($MaskBytes | ForEach-Object { 
        [Convert]::ToString($_, 2).PadLeft(8, '0') 
    }) -join ''
    
    # Count the number of '1' bits
    $prefixLength = ($binaryString.ToCharArray() | Where-Object { $_ -eq '1' }).Count
    
    return $prefixLength
}
```

#### Step 2: Extract Get-SubnetMaskBytes
```powershell
<#
.SYNOPSIS
    Calculates subnet mask bytes from prefix length.
#>
function Get-SubnetMaskBytes {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [int]$PrefixLength
    )
    
    $maskBytes = [byte[]]::new(4)
    $remainingBits = $PrefixLength
    
    for ($i = 0; $i -lt 4; $i++) {
        if ($remainingBits -ge 8) {
            $maskBytes[$i] = 255
            $remainingBits -= 8
        }
        elseif ($remainingBits -gt 0) {
            $maskBytes[$i] = [byte](256 - [Math]::Pow(2, 8 - $remainingBits))
            $remainingBits = 0
        }
        else {
            $maskBytes[$i] = 0
        }
    }
    
    return $maskBytes
}
```

#### Step 3: Extract Get-NetworkAddressBytes
```powershell
<#
.SYNOPSIS
    Calculates network address bytes from IP and mask.
#>
function Get-NetworkAddressBytes {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [byte[]]$IPBytes,
        
        [Parameter(Mandatory=$true)]
        [byte[]]$MaskBytes
    )
    
    $networkBytes = [byte[]]::new(4)
    for ($i = 0; $i -lt 4; $i++) {
        $networkBytes[$i] = $IPBytes[$i] -band $MaskBytes[$i]
    }
    
    return $networkBytes
}
```

#### Step 4: Refactor Get-SubnetFromIP
```powershell
<#
.SYNOPSIS
    Calculates subnet CIDR notation from IP address and prefix length.
#>
function Get-SubnetFromIP {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$IPAddress,
        
        [Parameter(Mandatory=$true)]
        [int]$PrefixLength
    )
    
    try {
        # Parse IP address
        $ipBytes = [System.Net.IPAddress]::Parse($IPAddress).GetAddressBytes()
        
        # Calculate mask and network address
        $maskBytes = Get-SubnetMaskBytes -PrefixLength $PrefixLength
        $networkBytes = Get-NetworkAddressBytes -IPBytes $ipBytes -MaskBytes $maskBytes
        
        # Convert to IP address
        $networkAddress = [System.Net.IPAddress]::new($networkBytes)
        
        # Calculate actual prefix length from mask
        $calculatedPrefix = ConvertTo-PrefixLength -MaskBytes $maskBytes
        
        # Return CIDR notation
        return "$($networkAddress.ToString())/$calculatedPrefix"
    }
    catch {
        Write-Verbose "Failed to calculate subnet for $IPAddress/$PrefixLength"
        return $null
    }
}
```

#### Placement in File
- Add helper functions at lines 102-145 (before Get-SubnetFromIP)
- Replace Get-SubnetFromIP with refactored version
- Keep in Region 1: Network Discovery Functions

---

## Priority 3: Start-NetworkScan (RECOMMENDED)

### Current Issues
- 78 lines mixing scanning logic with UI concerns
- Progress updates and status messages inline
- Difficult to test business logic independently

### Refactoring Steps

#### Step 1: Extract Invoke-PingSweep
```powershell
<#
.SYNOPSIS
    Performs ping sweep of IP list to discover reachable hosts.
#>
function Invoke-PingSweep {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$Subnet,
        
        [Parameter(Mandatory=$true)]
        [array]$IPList,
        
        [Parameter(Mandatory=$false)]
        [int]$Timeout = 1000
    )
    
    Write-Host "`nPhase 1: Discovering reachable hosts..." -ForegroundColor Cyan
    $reachableHosts = [System.Collections.ArrayList]::new()
    $current = 0
    
    foreach ($ip in $IPList) {
        $current++
        
        # Update progress every 10 IPs
        if ($current % 10 -eq 0 -or $current -eq $IPList.Count) {
            $percent = [Math]::Round(($current / $IPList.Count) * 100, 1)
            Write-Progress -Activity "Ping Sweep: $Subnet" -Status "Scanning $ip ($current/$($IPList.Count))" -PercentComplete $percent
        }
        
        if (Test-HostReachable -IPAddress $ip -Timeout $Timeout) {
            [void]$reachableHosts.Add($ip)
            Write-Host "  [+] Found: $ip" -ForegroundColor Green
        }
    }
    
    Write-Progress -Activity "Ping Sweep: $Subnet" -Completed
    Write-Host "`nFound $($reachableHosts.Count) reachable host(s) in $Subnet" -ForegroundColor Green
    
    return $reachableHosts
}
```

#### Step 2: Extract Invoke-DeviceScan
```powershell
<#
.SYNOPSIS
    Performs detailed scan of reachable hosts.
#>
function Invoke-DeviceScan {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$Subnet,
        
        [Parameter(Mandatory=$true)]
        [array]$Hosts,
        
        [Parameter(Mandatory=$true)]
        [int[]]$Ports,
        
        [Parameter(Mandatory=$false)]
        [int]$Timeout = 1000
    )
    
    Write-Host "`nPhase 2: Scanning devices for details..." -ForegroundColor Cyan
    $devices = [System.Collections.ArrayList]::new()
    $current = 0
    
    foreach ($ip in $Hosts) {
        $current++
        $percent = [Math]::Round(($current / $Hosts.Count) * 100, 1)
        Write-Progress -Activity "Device Scan: $Subnet" -Status "Analyzing $ip ($current/$($Hosts.Count))" -PercentComplete $percent
        
        $deviceInfo = Get-DeviceInfo -IPAddress $ip -Ports $Ports -Timeout $Timeout
        [void]$devices.Add($deviceInfo)
        
        Write-Host "  [*] $ip - $($deviceInfo.DeviceType)" -ForegroundColor Cyan
    }
    
    Write-Progress -Activity "Device Scan: $Subnet" -Completed
    
    return $devices
}
```

#### Step 3: Refactor Start-NetworkScan
```powershell
<#
.SYNOPSIS
    Main function to scan all subnets and discover devices.
#>
function Start-NetworkScan {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string[]]$Subnets,
        
        [Parameter(Mandatory=$true)]
        [int[]]$Ports,
        
        [Parameter(Mandatory=$false)]
        [int]$Timeout = 1000
    )
    
    # Display header
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "  Network Device Scanner" -ForegroundColor Cyan
    Write-Host "========================================`n" -ForegroundColor Cyan
    Write-Host "Subnets to scan: $($Subnets -join ', ')" -ForegroundColor Yellow
    Write-Host "Ports to check: $($Ports -join ', ')" -ForegroundColor Yellow
    Write-Host "Timeout: ${Timeout}ms`n" -ForegroundColor Yellow
    
    $allDevices = [System.Collections.ArrayList]::new()
    
    foreach ($subnet in $Subnets) {
        Write-Host "`nScanning subnet: $subnet" -ForegroundColor Green
        
        # Expand subnet to IP list
        $ipList = Expand-Subnet -Subnet $subnet
        Write-Host "Total IPs to scan: $($ipList.Count)" -ForegroundColor Gray
        
        # Phase 1: Ping sweep
        $reachableHosts = Invoke-PingSweep -Subnet $subnet -IPList $ipList -Timeout $Timeout
        
        # Phase 2: Detailed device scanning
        if ($reachableHosts.Count -gt 0) {
            $devices = Invoke-DeviceScan -Subnet $subnet -Hosts $reachableHosts -Ports $Ports -Timeout $Timeout
            
            foreach ($device in $devices) {
                [void]$allDevices.Add($device)
            }
        }
    }
    
    return $allDevices
}
```

#### Placement in File
- Add Invoke-PingSweep at line 605 (before Start-NetworkScan)
- Add Invoke-DeviceScan at line 650 (before Start-NetworkScan)
- Replace Start-NetworkScan with refactored version
- Keep in Region 5: Main Scanning Logic

---

## Quick Reference: Where to Place New Functions

```
NetworkDeviceScanner.ps1
├── Parameters (lines 34-43)
├── Global Variables (lines 46-62)
│
├── Region 1: Network Discovery Functions
│   ├── ConvertTo-PrefixLength (NEW)
│   ├── Get-SubnetMaskBytes (NEW)
│   ├── Get-NetworkAddressBytes (NEW)
│   ├── Get-LocalSubnets
│   ├── Get-SubnetFromIP (REFACTORED)
│   ├── Expand-Subnet
│   └── Test-HostReachable
│
├── Region 2: Device Identification Functions
│   ├── Get-HostnameFromIP
│   ├── Get-MACAddress
│   └── Get-ManufacturerFromMAC
│
├── Region 3: Port and API Scanning Functions
│   ├── Test-PortOpen
│   ├── Get-OpenPorts
│   └── Get-HTTPEndpointInfo
│
├── Region 4: Device Classification Functions
│   ├── Get-KeywordScore (NEW)
│   ├── Get-PortScore (NEW)
│   ├── Get-ContentScore (NEW)
│   ├── Get-BestScoringCategory (NEW)
│   ├── Get-DeviceClassification (REFACTORED)
│   └── Get-DeviceInfo
│
├── Region 5: Main Scanning Logic
│   ├── Invoke-PingSweep (NEW)
│   ├── Invoke-DeviceScan (NEW)
│   └── Start-NetworkScan (REFACTORED)
│
└── Region 6: Main Execution Block
```

---

## Testing After Refactoring

After refactoring, add tests for new helper functions:

```powershell
# Test ConvertTo-PrefixLength
Describe "ConvertTo-PrefixLength" {
    It "Correctly counts /24 mask bits" {
        $mask = @([byte]255, [byte]255, [byte]255, [byte]0)
        ConvertTo-PrefixLength -MaskBytes $mask | Should -Be 24
    }
}

# Test Get-KeywordScore
Describe "Get-KeywordScore" {
    It "Scores IOT Hub keywords correctly" {
        $scores = Get-KeywordScore -Hostname "homeassistant" -Manufacturer "Unknown" -DevicePatterns $script:DevicePatterns
        $scores['IOTHub'] | Should -BeGreaterThan 0
    }
}
```

---

## Summary

**Priority 1 (REQUIRED):**
- Refactor Get-DeviceClassification → +4 functions
- Refactor Get-SubnetFromIP → +3 functions
- **Total: +7 functions**

**Priority 2 (RECOMMENDED):**
- Refactor Start-NetworkScan → +2 functions
- Refactor Main Execution Block → +3 functions
- **Total: +5 functions**

**Result:** 13 → 25 functions (high priority) or 13 → 28 functions (all changes)

**Estimated Effort:**
- Priority 1: 2-3 hours
- Priority 1 + 2: 4-6 hours

---

**Good luck with the refactoring! Each change will make the code more maintainable and testable.**
