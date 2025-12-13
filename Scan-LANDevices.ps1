<#
.SYNOPSIS
    LAN Device Scanner for Windows 11 - Discovers devices, identifies types, and finds API endpoints.

.DESCRIPTION
    This script searches the local LAN across multiple subnets to discover visible devices,
    identify their types (IoT hubs, IoT devices, security devices), and discover exposed API endpoints.
    
    Supported device types:
    - IoT Hubs: Home Assistant
    - IoT Devices: Shelly
    - Security Devices: Ubiquiti, Ajax Security Hub with NVR

.PARAMETER SubnetCIDR
    Optional array of subnet CIDR notations to scan. If not provided, scans local subnet.

.PARAMETER Timeout
    Timeout in milliseconds for ping operations. Default is 100ms.

.PARAMETER Threads
    Number of concurrent threads for scanning. Default is 50.

.EXAMPLE
    .\Scan-LANDevices.ps1
    Scans the local subnet for devices.

.EXAMPLE
    .\Scan-LANDevices.ps1 -SubnetCIDR @("192.168.1.0/24", "192.168.2.0/24") -Timeout 200
    Scans specified subnets with a 200ms timeout.

.NOTES
    Author: GitHub Copilot
    Version: 1.0
    Requires: Windows 11, PowerShell 5.1 or higher
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string[]]$SubnetCIDR,
    
    [Parameter(Mandatory=$false)]
    [int]$Timeout = 100,
    
    [Parameter(Mandatory=$false)]
    [int]$Threads = 50
)

#region Helper Functions

<#
.SYNOPSIS
    Converts CIDR notation to IP range.
#>
function ConvertFrom-CIDR {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$CIDR
    )
    
    try {
        $network, $prefixLength = $CIDR -split '/'
        $prefixLength = [int]$prefixLength
        
        $ipBytes = [System.Net.IPAddress]::Parse($network).GetAddressBytes()
        [Array]::Reverse($ipBytes)
        $ipInt = [BitConverter]::ToUInt32($ipBytes, 0)
        
        $hostBits = 32 - $prefixLength
        $networkMask = [UInt32]([Math]::Pow(2, 32) - [Math]::Pow(2, $hostBits))
        $networkInt = $ipInt -band $networkMask
        
        $broadcastInt = $networkInt + [Math]::Pow(2, $hostBits) - 1
        
        return @{
            NetworkAddress = $networkInt
            BroadcastAddress = $broadcastInt
            FirstUsable = $networkInt + 1
            LastUsable = $broadcastInt - 1
            TotalHosts = [Math]::Pow(2, $hostBits) - 2
        }
    }
    catch {
        Write-Error "Failed to parse CIDR notation: $_"
        return $null
    }
}

<#
.SYNOPSIS
    Converts integer to IP address string.
#>
function ConvertTo-IPAddress {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [UInt32]$IPInteger
    )
    
    try {
        $bytes = [BitConverter]::GetBytes($IPInteger)
        [Array]::Reverse($bytes)
        return [System.Net.IPAddress]::new($bytes).ToString()
    }
    catch {
        Write-Error "Failed to convert integer to IP address: $_"
        return $null
    }
}

<#
.SYNOPSIS
    Gets local network subnets from active network adapters.
#>
function Get-LocalSubnets {
    [CmdletBinding()]
    param()
    
    try {
        $adapters = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' }
        $subnets = @()
        
        foreach ($adapter in $adapters) {
            $ipConfig = Get-NetIPAddress -InterfaceIndex $adapter.InterfaceIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue
            
            foreach ($ip in $ipConfig) {
                if ($ip.IPAddress -notlike "169.254.*") {
                    $cidr = "$($ip.IPAddress)/$($ip.PrefixLength)"
                    $subnets += $cidr
                }
            }
        }
        
        return $subnets
    }
    catch {
        Write-Error "Failed to get local subnets: $_"
        return @()
    }
}

#endregion

#region Scanning Functions

<#
.SYNOPSIS
    Performs ping scan on a single IP address.
#>
function Test-HostAlive {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$IPAddress,
        
        [Parameter(Mandatory=$false)]
        [int]$Timeout = 100
    )
    
    try {
        $ping = New-Object System.Net.NetworkInformation.Ping
        $result = $ping.Send($IPAddress, $Timeout)
        
        return ($result.Status -eq 'Success')
    }
    catch {
        return $false
    }
    finally {
        if ($ping) {
            $ping.Dispose()
        }
    }
}

<#
.SYNOPSIS
    Scans subnet for alive hosts using parallel processing.
#>
function Invoke-SubnetScan {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$CIDR,
        
        [Parameter(Mandatory=$false)]
        [int]$Timeout = 100,
        
        [Parameter(Mandatory=$false)]
        [int]$Threads = 50
    )
    
    Write-Verbose "Scanning subnet: $CIDR"
    
    $range = ConvertFrom-CIDR -CIDR $CIDR
    if (-not $range) {
        return @()
    }
    
    $aliveHosts = [System.Collections.Concurrent.ConcurrentBag[string]]::new()
    $jobs = @()
    
    Write-Host "Scanning $($range.TotalHosts) hosts in subnet $CIDR..."
    
    # Create runspace pool for parallel execution
    $runspacePool = [RunspaceFactory]::CreateRunspacePool(1, $Threads)
    $runspacePool.Open()
    
    for ($i = $range.FirstUsable; $i -le $range.LastUsable; $i++) {
        $ip = ConvertTo-IPAddress -IPInteger $i
        
        $powershell = [PowerShell]::Create().AddScript({
            param($IPAddress, $Timeout)
            
            try {
                $ping = New-Object System.Net.NetworkInformation.Ping
                $result = $ping.Send($IPAddress, $Timeout)
                
                if ($result.Status -eq 'Success') {
                    return $IPAddress
                }
            }
            catch {
                return $null
            }
            finally {
                if ($ping) {
                    $ping.Dispose()
                }
            }
            
            return $null
        }).AddArgument($ip).AddArgument($Timeout)
        
        $powershell.RunspacePool = $runspacePool
        
        $jobs += @{
            Pipe = $powershell
            Status = $powershell.BeginInvoke()
        }
    }
    
    # Wait for all jobs to complete
    foreach ($job in $jobs) {
        $result = $job.Pipe.EndInvoke($job.Status)
        if ($result) {
            [void]$aliveHosts.Add($result)
        }
        $job.Pipe.Dispose()
    }
    
    $runspacePool.Close()
    $runspacePool.Dispose()
    
    Write-Host "Found $($aliveHosts.Count) alive hosts in subnet $CIDR"
    
    return $aliveHosts.ToArray()
}

#endregion

#region Device Discovery Functions

<#
.SYNOPSIS
    Attempts DNS resolution to get hostname.
#>
function Get-DeviceHostname {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$IPAddress
    )
    
    try {
        $hostname = [System.Net.Dns]::GetHostEntry($IPAddress).HostName
        return $hostname
    }
    catch {
        return $null
    }
}

<#
.SYNOPSIS
    Gets MAC address and vendor from ARP cache or network query.
#>
function Get-DeviceMACAddress {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$IPAddress
    )
    
    try {
        # Try ARP cache first
        $arpEntry = arp -a $IPAddress | Select-String "([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})"
        
        if ($arpEntry) {
            $macMatch = $arpEntry -match "([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})"
            if ($macMatch) {
                return $Matches[0]
            }
        }
        
        # Try using Get-NetNeighbor (Windows 8+)
        $neighbor = Get-NetNeighbor -IPAddress $IPAddress -ErrorAction SilentlyContinue
        if ($neighbor) {
            return $neighbor.LinkLayerAddress
        }
        
        return $null
    }
    catch {
        return $null
    }
}

<#
.SYNOPSIS
    Scans common ports to identify device type and services.
#>
function Get-OpenPorts {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$IPAddress,
        
        [Parameter(Mandatory=$false)]
        [int[]]$Ports = @(80, 443, 8080, 8123, 8443, 8081, 9000, 9443, 554, 8000, 3000),
        
        [Parameter(Mandatory=$false)]
        [int]$Timeout = 1000
    )
    
    $openPorts = @()
    
    foreach ($port in $Ports) {
        try {
            $tcpClient = New-Object System.Net.Sockets.TcpClient
            $connect = $tcpClient.BeginConnect($IPAddress, $port, $null, $null)
            $wait = $connect.AsyncWaitHandle.WaitOne($Timeout, $false)
            
            if ($wait -and $tcpClient.Connected) {
                $openPorts += $port
            }
            
            $tcpClient.Close()
        }
        catch {
            # Port is closed or filtered
        }
        finally {
            if ($tcpClient) {
                $tcpClient.Dispose()
            }
        }
    }
    
    return $openPorts
}

<#
.SYNOPSIS
    Performs basic HTTP/HTTPS probe to get device information.
#>
function Get-HTTPDeviceInfo {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$IPAddress,
        
        [Parameter(Mandatory=$true)]
        [int]$Port,
        
        [Parameter(Mandatory=$false)]
        [int]$Timeout = 5000
    )
    
    $result = @{
        Protocol = $null
        Server = $null
        Title = $null
        Headers = @{}
    }
    
    foreach ($protocol in @('http', 'https')) {
        try {
            $url = "${protocol}://${IPAddress}:${Port}/"
            
            # Skip certificate validation for HTTPS
            if ($protocol -eq 'https') {
                [System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
                [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
            }
            
            $request = [System.Net.HttpWebRequest]::Create($url)
            $request.Timeout = $Timeout
            $request.Method = "GET"
            $request.UserAgent = "PowerShell-DeviceScanner/1.0"
            
            $response = $request.GetResponse()
            $result.Protocol = $protocol
            
            # Get headers
            foreach ($header in $response.Headers.AllKeys) {
                $result.Headers[$header] = $response.Headers[$header]
            }
            
            $result.Server = $response.Headers["Server"]
            
            # Try to get page title
            $stream = $response.GetResponseStream()
            $reader = New-Object System.IO.StreamReader($stream)
            $content = $reader.ReadToEnd()
            
            if ($content -match '<title>([^<]+)</title>') {
                $result.Title = $Matches[1]
            }
            
            $reader.Close()
            $stream.Close()
            $response.Close()
            
            return $result
        }
        catch {
            # Try next protocol
            continue
        }
    }
    
    return $null
}

#endregion

#region Device Type Identification

<#
.SYNOPSIS
    Identifies if device is a Home Assistant instance.
#>
function Test-HomeAssistant {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$IPAddress,
        
        [Parameter(Mandatory=$true)]
        [int[]]$OpenPorts
    )
    
    $indicators = @{
        IsHomeAssistant = $false
        Confidence = 0
        Evidence = @()
    }
    
    # Home Assistant typically runs on port 8123
    if ($OpenPorts -contains 8123) {
        $indicators.Confidence += 30
        $indicators.Evidence += "Port 8123 is open (Home Assistant default)"
        
        $httpInfo = Get-HTTPDeviceInfo -IPAddress $IPAddress -Port 8123
        
        if ($httpInfo) {
            if ($httpInfo.Title -match 'Home Assistant' -or $httpInfo.Server -match 'Home Assistant') {
                $indicators.Confidence += 50
                $indicators.Evidence += "Home Assistant identified in HTTP response"
            }
            
            if ($httpInfo.Headers.ContainsKey('HA-') -or $httpInfo.Server -match 'aiohttp') {
                $indicators.Confidence += 20
                $indicators.Evidence += "Home Assistant headers detected"
            }
        }
    }
    
    $indicators.IsHomeAssistant = ($indicators.Confidence -ge 50)
    
    return $indicators
}

<#
.SYNOPSIS
    Identifies if device is a Shelly IoT device.
#>
function Test-ShellyDevice {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$IPAddress,
        
        [Parameter(Mandatory=$true)]
        [int[]]$OpenPorts
    )
    
    $indicators = @{
        IsShellyDevice = $false
        Confidence = 0
        Evidence = @()
    }
    
    # Shelly devices typically have web interface on port 80
    if ($OpenPorts -contains 80) {
        $httpInfo = Get-HTTPDeviceInfo -IPAddress $IPAddress -Port 80
        
        if ($httpInfo) {
            if ($httpInfo.Title -match 'Shelly' -or $httpInfo.Server -match 'Shelly') {
                $indicators.Confidence += 60
                $indicators.Evidence += "Shelly identified in HTTP response"
            }
        }
        
        # Try Shelly API endpoint
        try {
            $shellyUrl = "http://${IPAddress}/shelly"
            $response = Invoke-RestMethod -Uri $shellyUrl -TimeoutSec 3 -ErrorAction SilentlyContinue
            
            if ($response.type -or $response.mac) {
                $indicators.Confidence += 40
                $indicators.Evidence += "Shelly API endpoint responsive"
            }
        }
        catch {
            # Not a Shelly device
        }
    }
    
    $indicators.IsShellyDevice = ($indicators.Confidence -ge 50)
    
    return $indicators
}

<#
.SYNOPSIS
    Identifies if device is a Ubiquiti device.
#>
function Test-UbiquitiDevice {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$IPAddress,
        
        [Parameter(Mandatory=$true)]
        [int[]]$OpenPorts
    )
    
    $indicators = @{
        IsUbiquitiDevice = $false
        Confidence = 0
        Evidence = @()
        DeviceType = $null
    }
    
    # UniFi Controller runs on 8443
    if ($OpenPorts -contains 8443) {
        $httpInfo = Get-HTTPDeviceInfo -IPAddress $IPAddress -Port 8443
        
        if ($httpInfo) {
            if ($httpInfo.Title -match 'UniFi' -or $httpInfo.Server -match 'UniFi') {
                $indicators.Confidence += 50
                $indicators.Evidence += "UniFi Controller detected on port 8443"
                $indicators.DeviceType = "UniFi Controller"
            }
        }
    }
    
    # UniFi devices also may have web interface on 443 or 80
    foreach ($port in @(443, 80)) {
        if ($OpenPorts -contains $port) {
            $httpInfo = Get-HTTPDeviceInfo -IPAddress $IPAddress -Port $port
            
            if ($httpInfo) {
                if ($httpInfo.Server -match 'lighttpd' -and $httpInfo.Title -match 'UniFi|Ubiquiti') {
                    $indicators.Confidence += 40
                    $indicators.Evidence += "Ubiquiti device signature detected"
                }
            }
        }
    }
    
    $indicators.IsUbiquitiDevice = ($indicators.Confidence -ge 50)
    
    return $indicators
}

<#
.SYNOPSIS
    Identifies if device is an Ajax Security Hub.
#>
function Test-AjaxSecurityHub {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$IPAddress,
        
        [Parameter(Mandatory=$true)]
        [int[]]$OpenPorts
    )
    
    $indicators = @{
        IsAjaxHub = $false
        Confidence = 0
        Evidence = @()
    }
    
    # Ajax hubs typically have web interface on port 80 or 443
    foreach ($port in @(80, 443)) {
        if ($OpenPorts -contains $port) {
            $httpInfo = Get-HTTPDeviceInfo -IPAddress $IPAddress -Port $port
            
            if ($httpInfo) {
                if ($httpInfo.Title -match 'Ajax|Ajax Systems' -or $httpInfo.Server -match 'Ajax') {
                    $indicators.Confidence += 60
                    $indicators.Evidence += "Ajax Security Hub identified"
                }
            }
        }
    }
    
    $indicators.IsAjaxHub = ($indicators.Confidence -ge 50)
    
    return $indicators
}

<#
.SYNOPSIS
    Identifies generic device type based on open ports and HTTP info.
#>
function Get-DeviceType {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$IPAddress,
        
        [Parameter(Mandatory=$true)]
        [int[]]$OpenPorts
    )
    
    $deviceInfo = @{
        IPAddress = $IPAddress
        DeviceType = "Unknown"
        SubType = $null
        Confidence = 0
        Evidence = @()
        OpenPorts = $OpenPorts
    }
    
    # Test for Home Assistant
    $haTest = Test-HomeAssistant -IPAddress $IPAddress -OpenPorts $OpenPorts
    if ($haTest.IsHomeAssistant) {
        $deviceInfo.DeviceType = "IoT Hub"
        $deviceInfo.SubType = "Home Assistant"
        $deviceInfo.Confidence = $haTest.Confidence
        $deviceInfo.Evidence = $haTest.Evidence
        return $deviceInfo
    }
    
    # Test for Shelly
    $shellyTest = Test-ShellyDevice -IPAddress $IPAddress -OpenPorts $OpenPorts
    if ($shellyTest.IsShellyDevice) {
        $deviceInfo.DeviceType = "IoT Device"
        $deviceInfo.SubType = "Shelly"
        $deviceInfo.Confidence = $shellyTest.Confidence
        $deviceInfo.Evidence = $shellyTest.Evidence
        return $deviceInfo
    }
    
    # Test for Ubiquiti
    $ubiquitiTest = Test-UbiquitiDevice -IPAddress $IPAddress -OpenPorts $OpenPorts
    if ($ubiquitiTest.IsUbiquitiDevice) {
        $deviceInfo.DeviceType = "Security Device"
        $deviceInfo.SubType = if ($ubiquitiTest.DeviceType) { $ubiquitiTest.DeviceType } else { "Ubiquiti" }
        $deviceInfo.Confidence = $ubiquitiTest.Confidence
        $deviceInfo.Evidence = $ubiquitiTest.Evidence
        return $deviceInfo
    }
    
    # Test for Ajax
    $ajaxTest = Test-AjaxSecurityHub -IPAddress $IPAddress -OpenPorts $OpenPorts
    if ($ajaxTest.IsAjaxHub) {
        $deviceInfo.DeviceType = "Security Device"
        $deviceInfo.SubType = "Ajax Security Hub"
        $deviceInfo.Confidence = $ajaxTest.Confidence
        $deviceInfo.Evidence = $ajaxTest.Evidence
        return $deviceInfo
    }
    
    # Check for NVR/Camera (port 554 = RTSP)
    if ($OpenPorts -contains 554) {
        $deviceInfo.DeviceType = "Security Device"
        $deviceInfo.SubType = "NVR/Camera"
        $deviceInfo.Confidence = 40
        $deviceInfo.Evidence += "RTSP port 554 is open"
    }
    
    # Generic device type inference
    if ($deviceInfo.DeviceType -eq "Unknown") {
        if ($OpenPorts -contains 80 -or $OpenPorts -contains 443) {
            $deviceInfo.DeviceType = "Network Device"
            $deviceInfo.SubType = "Web Server"
            $deviceInfo.Confidence = 20
            $deviceInfo.Evidence += "HTTP/HTTPS service detected"
        }
    }
    
    return $deviceInfo
}

#endregion

#region API Endpoint Discovery

<#
.SYNOPSIS
    Discovers API endpoints on a device.
#>
function Find-APIEndpoints {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$IPAddress,
        
        [Parameter(Mandatory=$true)]
        [int[]]$OpenPorts,
        
        [Parameter(Mandatory=$false)]
        [string]$DeviceSubType
    )
    
    $endpoints = @()
    
    # Common API paths to probe
    $commonPaths = @(
        '/api',
        '/api/v1',
        '/api/v2',
        '/rest',
        '/rest/api',
        '/graphql',
        '/swagger',
        '/openapi.json',
        '/api-docs'
    )
    
    # Device-specific paths
    $deviceSpecificPaths = @{}
    $deviceSpecificPaths['Home Assistant'] = @('/api/', '/auth', '/api/config', '/api/states')
    $deviceSpecificPaths['Shelly'] = @('/shelly', '/status', '/settings', '/rpc')
    $deviceSpecificPaths['Ubiquiti'] = @('/api/auth', '/api/system', '/api/s/default')
    $deviceSpecificPaths['Ajax Security Hub'] = @('/api/panel', '/api/devices')
    
    foreach ($port in $OpenPorts) {
        if ($port -notin @(80, 443, 8080, 8123, 8443, 8081, 8000, 3000)) {
            continue
        }
        
        $pathsToTest = $commonPaths
        
        # Add device-specific paths if device type is known
        if ($DeviceSubType -and $deviceSpecificPaths.ContainsKey($DeviceSubType)) {
            $pathsToTest = $pathsToTest + $deviceSpecificPaths[$DeviceSubType]
        }
        
        foreach ($path in $pathsToTest) {
            foreach ($protocol in @('http', 'https')) {
                try {
                    $url = "${protocol}://${IPAddress}:${port}${path}"
                    
                    if ($protocol -eq 'https') {
                        [System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
                        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
                    }
                    
                    $request = [System.Net.HttpWebRequest]::Create($url)
                    $request.Timeout = 3000
                    $request.Method = "GET"
                    $request.AllowAutoRedirect = $false
                    
                    $response = $request.GetResponse()
                    $statusCode = [int]$response.StatusCode
                    
                    # Consider successful if not 404/403
                    if ($statusCode -ne 404 -and $statusCode -ne 403) {
                        $endpoints += @{
                            URL = $url
                            StatusCode = $statusCode
                            ContentType = $response.ContentType
                        }
                    }
                    
                    $response.Close()
                }
                catch [System.Net.WebException] {
                    $statusCode = [int]$_.Exception.Response.StatusCode
                    
                    # Some APIs return 401/405 which means the endpoint exists
                    if ($statusCode -in @(401, 405, 500)) {
                        $url = "${protocol}://${IPAddress}:${port}${path}"
                        $endpoints += @{
                            URL = $url
                            StatusCode = $statusCode
                            ContentType = $_.Exception.Response.ContentType
                        }
                    }
                }
                catch {
                    # Endpoint doesn't exist or connection failed
                    continue
                }
            }
        }
    }
    
    return $endpoints
}

#endregion

#region Main Scanning Orchestration

<#
.SYNOPSIS
    Performs complete device discovery on a host.
#>
function Get-DeviceInformation {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$IPAddress
    )
    
    Write-Verbose "Discovering device information for $IPAddress"
    
    $device = [PSCustomObject]@{
        IPAddress = $IPAddress
        Hostname = $null
        MACAddress = $null
        DeviceType = "Unknown"
        SubType = $null
        Confidence = 0
        Evidence = @()
        OpenPorts = @()
        APIEndpoints = @()
    }
    
    # Get hostname
    $device.Hostname = Get-DeviceHostname -IPAddress $IPAddress
    
    # Get MAC address
    $device.MACAddress = Get-DeviceMACAddress -IPAddress $IPAddress
    
    # Scan for open ports
    Write-Verbose "Scanning ports on $IPAddress"
    $device.OpenPorts = Get-OpenPorts -IPAddress $IPAddress
    
    if ($device.OpenPorts.Count -gt 0) {
        # Identify device type
        Write-Verbose "Identifying device type for $IPAddress"
        $typeInfo = Get-DeviceType -IPAddress $IPAddress -OpenPorts $device.OpenPorts
        
        $device.DeviceType = $typeInfo.DeviceType
        $device.SubType = $typeInfo.SubType
        $device.Confidence = $typeInfo.Confidence
        $device.Evidence = $typeInfo.Evidence
        
        # Discover API endpoints
        Write-Verbose "Discovering API endpoints for $IPAddress"
        $device.APIEndpoints = Find-APIEndpoints -IPAddress $IPAddress -OpenPorts $device.OpenPorts -DeviceSubType $device.SubType
    }
    
    return $device
}

<#
.SYNOPSIS
    Main function to scan LAN and discover all devices.
#>
function Start-LANDeviceScan {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [string[]]$SubnetCIDR,
        
        [Parameter(Mandatory=$false)]
        [int]$Timeout = 100,
        
        [Parameter(Mandatory=$false)]
        [int]$Threads = 50
    )
    
    Write-Host "`n=== LAN Device Scanner ===" -ForegroundColor Cyan
    Write-Host "Starting scan at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`n" -ForegroundColor Cyan
    
    # Determine subnets to scan
    if (-not $SubnetCIDR) {
        Write-Host "No subnets specified. Detecting local subnets..." -ForegroundColor Yellow
        $SubnetCIDR = Get-LocalSubnets
        
        if ($SubnetCIDR.Count -eq 0) {
            Write-Error "No active network adapters found with valid IP addresses."
            return @()
        }
        
        Write-Host "Detected subnets: $($SubnetCIDR -join ', ')" -ForegroundColor Green
    }
    
    # Scan all subnets for alive hosts
    $allHosts = @()
    
    foreach ($subnet in $SubnetCIDR) {
        $hosts = Invoke-SubnetScan -CIDR $subnet -Timeout $Timeout -Threads $Threads
        $allHosts += $hosts
    }
    
    if ($allHosts.Count -eq 0) {
        Write-Host "`nNo alive hosts found." -ForegroundColor Yellow
        return @()
    }
    
    Write-Host "`nTotal alive hosts found: $($allHosts.Count)" -ForegroundColor Green
    Write-Host "`nPerforming device discovery on all hosts...`n" -ForegroundColor Cyan
    
    # Discover device information for all hosts
    $devices = @()
    $counter = 0
    
    foreach ($host in $allHosts) {
        $counter++
        Write-Progress -Activity "Discovering devices" -Status "Processing $host ($counter of $($allHosts.Count))" -PercentComplete (($counter / $allHosts.Count) * 100)
        
        $deviceInfo = Get-DeviceInformation -IPAddress $host
        $devices += $deviceInfo
    }
    
    Write-Progress -Activity "Discovering devices" -Completed
    
    Write-Host "`n=== Scan Complete ===" -ForegroundColor Cyan
    Write-Host "Scan completed at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Cyan
    Write-Host "Total devices discovered: $($devices.Count)`n" -ForegroundColor Green
    
    return $devices
}

#endregion

#region Output Functions

<#
.SYNOPSIS
    Displays device scan results in a formatted table.
#>
function Show-DeviceScanResults {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [object[]]$Devices
    )
    
    Write-Host "`n=== Device Scan Results ===" -ForegroundColor Cyan
    
    # Group by device type
    $grouped = $Devices | Group-Object -Property DeviceType
    
    foreach ($group in $grouped) {
        Write-Host "`n--- $($group.Name) ($($group.Count) devices) ---" -ForegroundColor Yellow
        
        foreach ($device in $group.Group) {
            Write-Host "`nIP Address: $($device.IPAddress)" -ForegroundColor White
            
            if ($device.Hostname) {
                Write-Host "  Hostname: $($device.Hostname)" -ForegroundColor Gray
            }
            
            if ($device.MACAddress) {
                Write-Host "  MAC Address: $($device.MACAddress)" -ForegroundColor Gray
            }
            
            if ($device.SubType) {
                Write-Host "  Sub Type: $($device.SubType)" -ForegroundColor Cyan
            }
            
            if ($device.Confidence -gt 0) {
                Write-Host "  Confidence: $($device.Confidence)%" -ForegroundColor Gray
            }
            
            if ($device.OpenPorts.Count -gt 0) {
                Write-Host "  Open Ports: $($device.OpenPorts -join ', ')" -ForegroundColor Gray
            }
            
            if ($device.APIEndpoints.Count -gt 0) {
                Write-Host "  API Endpoints:" -ForegroundColor Green
                foreach ($endpoint in $device.APIEndpoints) {
                    Write-Host "    - $($endpoint.URL) (Status: $($endpoint.StatusCode))" -ForegroundColor Green
                }
            }
            
            if ($device.Evidence.Count -gt 0) {
                Write-Host "  Evidence:" -ForegroundColor Gray
                foreach ($evidence in $device.Evidence) {
                    Write-Host "    - $evidence" -ForegroundColor Gray
                }
            }
        }
    }
}

<#
.SYNOPSIS
    Exports device scan results to JSON file.
#>
function Export-DeviceScanResults {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [object[]]$Devices,
        
        [Parameter(Mandatory=$false)]
        [string]$OutputPath = ".\device-scan-results.json"
    )
    
    try {
        $Devices | ConvertTo-Json -Depth 10 | Out-File -FilePath $OutputPath -Encoding UTF8
        Write-Host "`nResults exported to: $OutputPath" -ForegroundColor Green
    }
    catch {
        Write-Error "Failed to export results: $_"
    }
}

#endregion

#region Script Execution

# Main script execution
if ($MyInvocation.InvocationName -ne '.') {
    try {
        # Run the scan
        $devices = Start-LANDeviceScan -SubnetCIDR $SubnetCIDR -Timeout $Timeout -Threads $Threads
        
        if ($devices.Count -gt 0) {
            # Display results
            Show-DeviceScanResults -Devices $devices
            
            # Export to JSON
            $timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
            $outputPath = ".\device-scan-results_$timestamp.json"
            Export-DeviceScanResults -Devices $devices -OutputPath $outputPath
            
            Write-Host "`n=== Summary ===" -ForegroundColor Cyan
            Write-Host "IoT Hubs: $(($devices | Where-Object {$_.DeviceType -eq 'IoT Hub'}).Count)" -ForegroundColor Green
            Write-Host "IoT Devices: $(($devices | Where-Object {$_.DeviceType -eq 'IoT Device'}).Count)" -ForegroundColor Green
            Write-Host "Security Devices: $(($devices | Where-Object {$_.DeviceType -eq 'Security Device'}).Count)" -ForegroundColor Green
            Write-Host "Other Devices: $(($devices | Where-Object {$_.DeviceType -notin @('IoT Hub', 'IoT Device', 'Security Device')}).Count)" -ForegroundColor Yellow
            
            $totalEndpoints = ($devices | ForEach-Object { $_.APIEndpoints.Count } | Measure-Object -Sum).Sum
            Write-Host "Total API Endpoints Found: $totalEndpoints" -ForegroundColor Green
        }
    }
    catch {
        Write-Error "An error occurred during scanning: $_"
        Write-Error $_.ScriptStackTrace
    }
}

#endregion
