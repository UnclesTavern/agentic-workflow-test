<#
.SYNOPSIS
    Network Device Scanner for LAN device discovery and API endpoint identification.

.DESCRIPTION
    Scans local LAN across multiple subnets to discover all reachable devices,
    identifies device types (IOT hubs, IOT devices, Security devices), and
    discovers exposed API endpoints.

.PARAMETER Subnets
    Array of subnet ranges to scan (e.g., "192.168.1.0/24", "10.0.0.0/24").
    If not specified, automatically detects local subnets.

.PARAMETER Ports
    Array of ports to scan for API endpoints. Defaults to common API ports.

.PARAMETER Timeout
    Timeout in milliseconds for network operations. Default is 1000ms.

.EXAMPLE
    .\NetworkDeviceScanner.ps1
    Scans all local subnets with default settings.

.EXAMPLE
    .\NetworkDeviceScanner.ps1 -Subnets "192.168.1.0/24","192.168.2.0/24" -Timeout 500
    Scans specific subnets with custom timeout.

.NOTES
    Requires Windows 11 and PowerShell 5.1 or higher.
    May require administrator privileges for some operations.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string[]]$Subnets,
    
    [Parameter(Mandatory=$false)]
    [int[]]$Ports = @(80, 443, 8080, 8443, 8123, 5000, 5001, 7443, 9443),
    
    [Parameter(Mandatory=$false)]
    [int]$Timeout = 1000
)

# Global variables for device patterns
$script:DevicePatterns = @{
    IOTHub = @{
        Keywords = @('homeassistant', 'home-assistant', 'hassio', 'openhab', 'hubitat', 'smartthings')
        Ports = @(8123, 8080, 443)
        Paths = @('/', '/api', '/api/states')
    }
    IOTDevice = @{
        Keywords = @('shelly', 'tasmota', 'sonoff', 'esp', 'arduino', 'wemo', 'philips', 'hue', 'lifx')
        Ports = @(80, 443)
        Paths = @('/', '/status', '/api', '/settings')
    }
    Security = @{
        Keywords = @('ubiquiti', 'unifi', 'ajax', 'hikvision', 'dahua', 'axis', 'nvr', 'dvr', 'camera')
        Ports = @(443, 7443, 8443, 9443, 554)
        Paths = @('/', '/api', '/api/auth')
    }
}

#region Network Discovery Functions

<#
.SYNOPSIS
    Gets all local network adapters and their subnet configurations.
#>
function Get-LocalSubnets {
    [CmdletBinding()]
    param()
    
    try {
        Write-Verbose "Enumerating local network adapters..."
        
        $adapters = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' }
        $subnets = [System.Collections.ArrayList]::new()
        
        foreach ($adapter in $adapters) {
            $ipConfig = Get-NetIPAddress -InterfaceIndex $adapter.ifIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue
            
            foreach ($ip in $ipConfig) {
                if ($ip.IPAddress -notlike '169.254.*') {  # Exclude APIPA addresses
                    $subnet = Get-SubnetFromIP -IPAddress $ip.IPAddress -PrefixLength $ip.PrefixLength
                    if ($subnet -and $subnets -notcontains $subnet) {
                        [void]$subnets.Add($subnet)
                    }
                }
            }
        }
        
        Write-Verbose "Found $($subnets.Count) local subnet(s): $($subnets -join ', ')"
        return $subnets
    }
    catch {
        Write-Error "Failed to enumerate local subnets: $_"
        return @()
    }
}

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
        $ipBytes = [System.Net.IPAddress]::Parse($IPAddress).GetAddressBytes()
        $maskBytes = [byte[]]::new(4)
        
        for ($i = 0; $i -lt 4; $i++) {
            if ($PrefixLength -ge 8) {
                $maskBytes[$i] = 255
                $PrefixLength -= 8
            }
            elseif ($PrefixLength -gt 0) {
                $maskBytes[$i] = [byte](256 - [Math]::Pow(2, 8 - $PrefixLength))
                $PrefixLength = 0
            }
            else {
                $maskBytes[$i] = 0
            }
        }
        
        $networkBytes = [byte[]]::new(4)
        for ($i = 0; $i -lt 4; $i++) {
            $networkBytes[$i] = $ipBytes[$i] -band $maskBytes[$i]
        }
        
        $networkAddress = [System.Net.IPAddress]::new($networkBytes)
        return "$($networkAddress.ToString())/$($PrefixLength + ($maskBytes | ForEach-Object { [Convert]::ToString($_, 2).PadLeft(8, '0') } | Out-String).Replace("`n", '').Replace("`r", '').Replace(' ', '').Replace('1', '').Length + 32 - (($maskBytes | ForEach-Object { [Convert]::ToString($_, 2).PadLeft(8, '0') } | Out-String).Replace("`n", '').Replace("`r", '').Replace(' ', '').Length))"
    }
    catch {
        Write-Verbose "Failed to calculate subnet for $IPAddress/$PrefixLength"
        return $null
    }
}

<#
.SYNOPSIS
    Expands a CIDR notation subnet into an array of IP addresses.
#>
function Expand-Subnet {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$Subnet
    )
    
    try {
        $parts = $Subnet -split '/'
        $networkIP = $parts[0]
        $prefixLength = [int]$parts[1]
        
        $ipBytes = [System.Net.IPAddress]::Parse($networkIP).GetAddressBytes()
        [Array]::Reverse($ipBytes)
        $ipNum = [BitConverter]::ToUInt32($ipBytes, 0)
        
        $hostBits = 32 - $prefixLength
        $numHosts = [Math]::Pow(2, $hostBits)
        
        # Limit to reasonable subnet sizes
        if ($numHosts -gt 65536) {
            Write-Warning "Subnet $Subnet is too large (${numHosts} hosts). Limiting to /16."
            $numHosts = 65536
        }
        
        $ips = [System.Collections.ArrayList]::new()
        
        # Skip network address (first) and broadcast (last) for /24 and smaller
        $start = if ($prefixLength -ge 24) { 1 } else { 0 }
        $end = if ($prefixLength -ge 24) { $numHosts - 1 } else { $numHosts }
        
        for ($i = $start; $i -lt $end; $i++) {
            $currentIP = $ipNum + $i
            $bytes = [BitConverter]::GetBytes($currentIP)
            [Array]::Reverse($bytes)
            $ip = [System.Net.IPAddress]::new($bytes)
            [void]$ips.Add($ip.ToString())
        }
        
        return $ips
    }
    catch {
        Write-Error "Failed to expand subnet ${Subnet}: $_"
        return @()
    }
}

<#
.SYNOPSIS
    Tests if a host is reachable via ICMP ping.
#>
function Test-HostReachable {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$IPAddress,
        
        [Parameter(Mandatory=$false)]
        [int]$Timeout = 1000
    )
    
    try {
        $ping = [System.Net.NetworkInformation.Ping]::new()
        $reply = $ping.Send($IPAddress, $Timeout)
        $ping.Dispose()
        
        return $reply.Status -eq 'Success'
    }
    catch {
        return $false
    }
}

#endregion

#region Device Identification Functions

<#
.SYNOPSIS
    Attempts to resolve hostname for an IP address.
#>
function Get-HostnameFromIP {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$IPAddress
    )
    
    try {
        $hostEntry = [System.Net.Dns]::GetHostEntry($IPAddress)
        return $hostEntry.HostName
    }
    catch {
        return $null
    }
}

<#
.SYNOPSIS
    Attempts to get MAC address and manufacturer for an IP.
#>
function Get-MACAddress {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$IPAddress
    )
    
    try {
        $arpTable = arp -a | Select-String -Pattern "^\s+$([regex]::Escape($IPAddress))\s+([0-9a-f]{2}-[0-9a-f]{2}-[0-9a-f]{2}-[0-9a-f]{2}-[0-9a-f]{2}-[0-9a-f]{2})"
        
        if ($arpTable) {
            $mac = $arpTable.Matches[0].Groups[1].Value
            return $mac
        }
        
        return $null
    }
    catch {
        return $null
    }
}

<#
.SYNOPSIS
    Identifies manufacturer from MAC address OUI.
#>
function Get-ManufacturerFromMAC {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$MACAddress
    )
    
    # Common IOT/Security device OUI prefixes
    $ouiDatabase = @{
        '00-0C-42' = 'Ubiquiti Networks'
        '00-27-22' = 'Ubiquiti Networks'
        'F0-9F-C2' = 'Ubiquiti Networks'
        '74-AC-B9' = 'Ubiquiti Networks'
        '68-D7-9A' = 'Ubiquiti Networks'
        'EC-08-6B' = 'Shelly'
        '84-CC-A8' = 'Shelly'
        'A0-20-A6' = 'Espressif (ESP8266/ESP32)'
        '24-0A-C4' = 'Espressif (ESP8266/ESP32)'
        '30-AE-A4' = 'Espressif (ESP8266/ESP32)'
        '00-17-88' = 'Philips Hue'
        '00-17-33' = 'Ajax Systems'
        '00-12-12' = 'Hikvision'
        '44-19-B6' = 'Hikvision'
        'D0-73-D5' = 'TP-Link (Tapo/Kasa)'
    }
    
    $oui = $MACAddress.Substring(0, 8).ToUpper()
    
    if ($ouiDatabase.ContainsKey($oui)) {
        return $ouiDatabase[$oui]
    }
    
    return 'Unknown'
}

#endregion

#region Port and API Scanning Functions

<#
.SYNOPSIS
    Tests if a TCP port is open on a host.
#>
function Test-PortOpen {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$IPAddress,
        
        [Parameter(Mandatory=$true)]
        [int]$Port,
        
        [Parameter(Mandatory=$false)]
        [int]$Timeout = 1000
    )
    
    try {
        $tcpClient = [System.Net.Sockets.TcpClient]::new()
        $connect = $tcpClient.BeginConnect($IPAddress, $Port, $null, $null)
        $wait = $connect.AsyncWaitHandle.WaitOne($Timeout, $false)
        
        if ($wait -and $tcpClient.Connected) {
            $tcpClient.EndConnect($connect)
            $tcpClient.Close()
            return $true
        }
        else {
            $tcpClient.Close()
            return $false
        }
    }
    catch {
        return $false
    }
}

<#
.SYNOPSIS
    Scans multiple ports on a host and returns open ports.
#>
function Get-OpenPorts {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$IPAddress,
        
        [Parameter(Mandatory=$true)]
        [int[]]$Ports,
        
        [Parameter(Mandatory=$false)]
        [int]$Timeout = 1000
    )
    
    $openPorts = [System.Collections.ArrayList]::new()
    
    foreach ($port in $Ports) {
        if (Test-PortOpen -IPAddress $IPAddress -Port $port -Timeout $Timeout) {
            [void]$openPorts.Add($port)
        }
    }
    
    return $openPorts
}

<#
.SYNOPSIS
    Attempts to probe HTTP/HTTPS endpoints and retrieve information.
#>
function Get-HTTPEndpointInfo {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$IPAddress,
        
        [Parameter(Mandatory=$true)]
        [int]$Port,
        
        [Parameter(Mandatory=$false)]
        [string[]]$Paths = @('/')
    )
    
    $results = [System.Collections.ArrayList]::new()
    $originalCallback = [System.Net.ServicePointManager]::ServerCertificateValidationCallback
    
    try {
        # Temporarily disable SSL validation for self-signed certificates
        [System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12 -bor [System.Net.SecurityProtocolType]::Tls13
        
        $protocols = @('https', 'http')
        
        foreach ($protocol in $protocols) {
            foreach ($path in $Paths) {
                try {
                    $url = "${protocol}://${IPAddress}:${Port}${path}"
                    
                    $request = [System.Net.HttpWebRequest]::Create($url)
                    $request.Timeout = 5000
                    $request.Method = 'GET'
                    $request.UserAgent = 'NetworkDeviceScanner/1.0'
                    
                    $response = $request.GetResponse()
                    $statusCode = [int]$response.StatusCode
                    $server = $response.Headers['Server']
                    
                    $stream = $response.GetResponseStream()
                    $reader = [System.IO.StreamReader]::new($stream)
                    $content = $reader.ReadToEnd()
                    $reader.Close()
                    $stream.Close()
                    $response.Close()
                    
                    [void]$results.Add(@{
                        URL = $url
                        StatusCode = $statusCode
                        Server = $server
                        ContentLength = $content.Length
                        Content = $content.Substring(0, [Math]::Min(1000, $content.Length))
                    })
                    
                    # If HTTPS works, don't try HTTP
                    if ($protocol -eq 'https') {
                        break
                    }
                }
                catch {
                    Write-Verbose "Failed to probe ${url}: $_"
                }
            }
        }
    }
    finally {
        # Always restore the original callback
        [System.Net.ServicePointManager]::ServerCertificateValidationCallback = $originalCallback
    }
    
    return $results
}

#endregion

#region Device Classification Functions

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
    
    $scores = @{
        IOTHub = 0
        IOTDevice = 0
        Security = 0
    }
    
    # Check hostname and manufacturer
    foreach ($category in $script:DevicePatterns.Keys) {
        $keywords = $script:DevicePatterns[$category].Keywords
        
        foreach ($keyword in $keywords) {
            if ($Hostname -like "*$keyword*") {
                $scores[$category] += 10
            }
            if ($Manufacturer -like "*$keyword*") {
                $scores[$category] += 15
            }
        }
    }
    
    # Check ports
    foreach ($category in $script:DevicePatterns.Keys) {
        $categoryPorts = $script:DevicePatterns[$category].Ports
        foreach ($port in $OpenPorts) {
            if ($categoryPorts -contains $port) {
                $scores[$category] += 3
            }
        }
    }
    
    # Check endpoint content
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
    
    # Determine best match
    $maxScore = ($scores.Values | Measure-Object -Maximum).Maximum
    
    if ($maxScore -eq 0) {
        return 'Unknown'
    }
    
    $bestMatch = $scores.GetEnumerator() | Where-Object { $_.Value -eq $maxScore } | Select-Object -First 1
    return $bestMatch.Name
}

<#
.SYNOPSIS
    Scans a single device and gathers all information.
#>
function Get-DeviceInfo {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$IPAddress,
        
        [Parameter(Mandatory=$true)]
        [int[]]$Ports,
        
        [Parameter(Mandatory=$false)]
        [int]$Timeout = 1000
    )
    
    Write-Verbose "Scanning device: $IPAddress"
    
    # Gather basic information
    $hostname = Get-HostnameFromIP -IPAddress $IPAddress
    $mac = Get-MACAddress -IPAddress $IPAddress
    $manufacturer = if ($mac) { Get-ManufacturerFromMAC -MACAddress $mac } else { 'Unknown' }
    
    # Scan ports
    $openPorts = Get-OpenPorts -IPAddress $IPAddress -Ports $Ports -Timeout $Timeout
    
    # Probe HTTP endpoints
    $endpoints = [System.Collections.ArrayList]::new()
    foreach ($port in $openPorts) {
        if ($port -in @(80, 443, 8080, 8123, 8443, 5000, 5001, 7443, 9443)) {
            $paths = @('/', '/api', '/status', '/api/states')
            $endpointInfo = Get-HTTPEndpointInfo -IPAddress $IPAddress -Port $port -Paths $paths
            
            foreach ($info in $endpointInfo) {
                [void]$endpoints.Add($info)
            }
        }
    }
    
    # Classify device
    $deviceType = Get-DeviceClassification -Hostname $hostname -Manufacturer $manufacturer -EndpointData $endpoints -OpenPorts $openPorts
    
    # Build result object
    $deviceInfo = [PSCustomObject]@{
        IPAddress = $IPAddress
        Hostname = $hostname
        MACAddress = $mac
        Manufacturer = $manufacturer
        DeviceType = $deviceType
        OpenPorts = $openPorts
        Endpoints = $endpoints
        ScanTime = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    }
    
    return $deviceInfo
}

#endregion

#region Main Scanning Logic

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
        $totalIPs = $ipList.Count
        Write-Host "Total IPs to scan: $totalIPs" -ForegroundColor Gray
        
        $current = 0
        $reachable = 0
        
        # Ping sweep first
        Write-Host "`nPhase 1: Discovering reachable hosts..." -ForegroundColor Cyan
        $reachableHosts = [System.Collections.ArrayList]::new()
        
        foreach ($ip in $ipList) {
            $current++
            
            if ($current % 10 -eq 0 -or $current -eq $totalIPs) {
                $percent = [Math]::Round(($current / $totalIPs) * 100, 1)
                Write-Progress -Activity "Ping Sweep: $subnet" -Status "Scanning $ip ($current/$totalIPs)" -PercentComplete $percent
            }
            
            if (Test-HostReachable -IPAddress $ip -Timeout $Timeout) {
                [void]$reachableHosts.Add($ip)
                $reachable++
                Write-Host "  [+] Found: $ip" -ForegroundColor Green
            }
        }
        
        Write-Progress -Activity "Ping Sweep: $subnet" -Completed
        Write-Host "`nFound $reachable reachable host(s) in $subnet" -ForegroundColor Green
        
        # Detailed scan of reachable hosts
        if ($reachable -gt 0) {
            Write-Host "`nPhase 2: Scanning devices for details..." -ForegroundColor Cyan
            
            $current = 0
            foreach ($ip in $reachableHosts) {
                $current++
                $percent = [Math]::Round(($current / $reachable) * 100, 1)
                Write-Progress -Activity "Device Scan: $subnet" -Status "Analyzing $ip ($current/$reachable)" -PercentComplete $percent
                
                $deviceInfo = Get-DeviceInfo -IPAddress $ip -Ports $Ports -Timeout $Timeout
                [void]$allDevices.Add($deviceInfo)
                
                Write-Host "  [*] $ip - $($deviceInfo.DeviceType)" -ForegroundColor Cyan
            }
            
            Write-Progress -Activity "Device Scan: $subnet" -Completed
        }
    }
    
    return $allDevices
}

#endregion

#region Main Execution

try {
    # Determine subnets to scan
    if (-not $Subnets) {
        Write-Host "No subnets specified. Auto-detecting local subnets..." -ForegroundColor Yellow
        $Subnets = Get-LocalSubnets
        
        if ($Subnets.Count -eq 0) {
            Write-Error "No local subnets found. Please specify subnets manually."
            exit 1
        }
    }
    
    # Start the scan
    $devices = Start-NetworkScan -Subnets $Subnets -Ports $Ports -Timeout $Timeout
    
    # Display results
    Write-Host "`n`n========================================" -ForegroundColor Cyan
    Write-Host "  Scan Complete - Summary" -ForegroundColor Cyan
    Write-Host "========================================`n" -ForegroundColor Cyan
    
    Write-Host "Total devices found: $($devices.Count)`n" -ForegroundColor Green
    
    # Group by device type
    $grouped = $devices | Group-Object -Property DeviceType
    
    foreach ($group in $grouped) {
        Write-Host "`n$($group.Name) Devices ($($group.Count)):" -ForegroundColor Yellow
        Write-Host ('-' * 60) -ForegroundColor Gray
        
        foreach ($device in $group.Group) {
            Write-Host "`nIP Address: $($device.IPAddress)" -ForegroundColor White
            if ($device.Hostname) {
                Write-Host "  Hostname: $($device.Hostname)" -ForegroundColor Gray
            }
            if ($device.MACAddress) {
                Write-Host "  MAC: $($device.MACAddress) ($($device.Manufacturer))" -ForegroundColor Gray
            }
            if ($device.OpenPorts.Count -gt 0) {
                Write-Host "  Open Ports: $($device.OpenPorts -join ', ')" -ForegroundColor Gray
            }
            if ($device.Endpoints.Count -gt 0) {
                Write-Host "  API Endpoints:" -ForegroundColor Gray
                foreach ($endpoint in $device.Endpoints) {
                    Write-Host "    - $($endpoint.URL) [Status: $($endpoint.StatusCode)]" -ForegroundColor Gray
                }
            }
        }
    }
    
    # Export to JSON
    $timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
    $outputFile = "NetworkScan_${timestamp}.json"
    $devices | ConvertTo-Json -Depth 10 | Out-File -FilePath $outputFile -Encoding UTF8
    
    Write-Host "`n`nResults exported to: $outputFile" -ForegroundColor Green
    Write-Host "`nScan completed successfully!`n" -ForegroundColor Green
}
catch {
    Write-Error "An error occurred during scanning: $_"
    exit 1
}

#endregion
