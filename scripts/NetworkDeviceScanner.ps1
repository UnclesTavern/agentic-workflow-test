<#
.SYNOPSIS
    Network Device Scanner for Windows 11 - Discovers devices and API endpoints across multiple subnets

.DESCRIPTION
    This PowerShell script performs comprehensive network scanning to discover devices across multiple
    subnets on a local LAN. It identifies device types, detects API endpoints, and provides detailed
    information about discovered network devices including IoT hubs, smart devices, and security equipment.

.PARAMETER Subnets
    Array of subnet addresses to scan (e.g., @("192.168.1.0/24", "192.168.2.0/24"))
    If not specified, auto-detects local subnets from network adapters

.PARAMETER ScanTimeout
    Timeout in milliseconds for ping operations (default: 500ms)

.PARAMETER PortTimeout
    Timeout in milliseconds for port scanning operations (default: 1000ms)

.PARAMETER CommonPortsOnly
    If specified, only scans common API ports. Otherwise performs comprehensive port scan

.PARAMETER MaxConcurrentJobs
    Maximum number of concurrent scanning jobs (default: 50)

.PARAMETER OutputFormat
    Output format: 'Table', 'List', 'JSON', or 'CSV' (default: 'Table')

.PARAMETER ExportPath
    Optional path to export results (automatically determines format from extension)

.EXAMPLE
    .\NetworkDeviceScanner.ps1
    Scans all local subnets with default settings

.EXAMPLE
    .\NetworkDeviceScanner.ps1 -Subnets @("192.168.1.0/24") -CommonPortsOnly
    Scans specific subnet with common ports only

.EXAMPLE
    .\NetworkDeviceScanner.ps1 -OutputFormat JSON -ExportPath "C:\scan-results.json"
    Scans network and exports results to JSON file

.NOTES
    Author: Development Agent
    Version: 1.0.0
    Requires: PowerShell 5.1 or higher, Windows 11
    
    Target Device Types:
    - Home Assistant (IoT Hub)
    - Shelly devices (Smart switches/sensors)
    - Ubiquiti UniFi (Network equipment)
    - Ajax Security Hub with NVR
    - Generic IoT devices
    - Network-attached storage (NAS)
    - IP Cameras
    - Smart home bridges
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string[]]$Subnets,
    
    [Parameter(Mandatory=$false)]
    [int]$ScanTimeout = 500,
    
    [Parameter(Mandatory=$false)]
    [int]$PortTimeout = 1000,
    
    [Parameter(Mandatory=$false)]
    [switch]$CommonPortsOnly,
    
    [Parameter(Mandatory=$false)]
    [int]$MaxConcurrentJobs = 50,
    
    [Parameter(Mandatory=$false)]
    [ValidateSet('Table', 'List', 'JSON', 'CSV')]
    [string]$OutputFormat = 'Table',
    
    [Parameter(Mandatory=$false)]
    [string]$ExportPath
)

# =============================================================================
# CONFIGURATION AND CONSTANTS
# =============================================================================

# Common API and service ports for IoT and network devices
$Script:CommonPorts = @(
    80,    # HTTP
    443,   # HTTPS
    8080,  # HTTP Alt
    8443,  # HTTPS Alt
    8123,  # Home Assistant
    8081,  # Common IoT
    5000,  # Synology DSM
    5001,  # Synology DSM HTTPS
    9000,  # Portainer
    9443,  # UniFi Controller
    8880,  # Ubiquiti
    7080,  # Ajax Security Hub
    554,   # RTSP (IP Cameras)
    8554,  # RTSP Alt
    1900,  # UPnP
    5353,  # mDNS
    502,   # Modbus (Industrial IoT)
    1883,  # MQTT
    8883   # MQTT over SSL
)

# Extended port list for comprehensive scanning
$Script:ExtendedPorts = @(
    80, 443, 8080, 8443, 8123, 8081, 5000, 5001, 9000, 9443, 8880, 
    7080, 554, 8554, 1900, 5353, 502, 1883, 8883, 3000, 3001, 
    4443, 6443, 7443, 10443, 8000, 8001, 8008, 8888, 9090, 9091,
    5555, 5556, 8082, 8083, 8084, 8181, 50000, 50001
)

# Device identification signatures based on HTTP responses and ports
$Script:DeviceSignatures = @{
    'Home Assistant' = @{
        Ports = @(8123)
        Headers = @('Server: Python*', '*Home Assistant*')
        Paths = @('/api/', '/auth/login')
    }
    'Shelly Device' = @{
        Ports = @(80)
        Headers = @('*Shelly*')
        Paths = @('/shelly', '/status', '/settings')
    }
    'Ubiquiti UniFi' = @{
        Ports = @(8443, 8880, 9443)
        Headers = @('*UniFi*', '*Ubiquiti*')
        Paths = @('/manage', '/api/s/default')
    }
    'Ajax Security Hub' = @{
        Ports = @(7080, 80, 443)
        Headers = @('*Ajax*', '*ajax-systems*')
        Paths = @('/api/', '/ajax')
    }
    'Synology NAS' = @{
        Ports = @(5000, 5001)
        Headers = @('*Synology*', '*DSM*')
        Paths = @('/webman', '/webapi')
    }
    'IP Camera' = @{
        Ports = @(554, 8554, 80, 8080)
        Headers = @('*Camera*', '*RTSP*', '*Hikvision*', '*Dahua*')
        Paths = @('/onvif', '/cgi-bin')
    }
    'MQTT Broker' = @{
        Ports = @(1883, 8883)
        Headers = @()
        Paths = @()
    }
    'Generic Web API' = @{
        Ports = @(80, 443, 8080, 8443)
        Headers = @()
        Paths = @('/api', '/api/', '/v1', '/v2')
    }
}

# =============================================================================
# HELPER FUNCTIONS
# =============================================================================

<#
.SYNOPSIS
    Writes colored console output for better readability
#>
function Write-ColorOutput {
    param(
        [string]$Message,
        [ValidateSet('Info', 'Success', 'Warning', 'Error', 'Header')]
        [string]$Type = 'Info'
    )
    
    $colors = @{
        'Info' = 'Cyan'
        'Success' = 'Green'
        'Warning' = 'Yellow'
        'Error' = 'Red'
        'Header' = 'Magenta'
    }
    
    Write-Host $Message -ForegroundColor $colors[$Type]
}

<#
.SYNOPSIS
    Converts CIDR notation to IP range for scanning
#>
function Get-IPRange {
    param(
        [string]$CIDR
    )
    
    try {
        $parts = $CIDR -split '/'
        $ip = $parts[0]
        $maskLength = [int]$parts[1]
        
        # Convert IP to integer
        $ipBytes = [System.Net.IPAddress]::Parse($ip).GetAddressBytes()
        [Array]::Reverse($ipBytes)
        $ipInt = [BitConverter]::ToUInt32($ipBytes, 0)
        
        # Calculate network and broadcast addresses
        $mask = [uint32]([Math]::Pow(2, 32) - [Math]::Pow(2, 32 - $maskLength))
        $networkInt = $ipInt -band $mask
        $broadcastInt = $networkInt -bor (-bnot $mask)
        
        # Generate all IPs in range using ArrayList for better performance
        $ips = New-Object System.Collections.ArrayList
        for ($i = $networkInt + 1; $i -lt $broadcastInt; $i++) {
            $bytes = [BitConverter]::GetBytes($i)
            [Array]::Reverse($bytes)
            [void]$ips.Add([System.Net.IPAddress]::new($bytes).ToString())
        }
        
        return $ips
    }
    catch {
        Write-ColorOutput "Error parsing CIDR $CIDR : $_" -Type Error
        return @()
    }
}

<#
.SYNOPSIS
    Auto-detects local network subnets from active network adapters
#>
function Get-LocalSubnets {
    Write-ColorOutput "`n[*] Auto-detecting local subnets..." -Type Info
    
    $subnets = @()
    $adapters = Get-NetIPAddress -AddressFamily IPv4 | 
                Where-Object { $_.PrefixOrigin -ne 'WellKnown' -and $_.InterfaceAlias -notlike '*Loopback*' }
    
    foreach ($adapter in $adapters) {
        $subnet = "$($adapter.IPAddress)/$($adapter.PrefixLength)"
        $subnets += $subnet
        Write-ColorOutput "    Found subnet: $subnet on $($adapter.InterfaceAlias)" -Type Success
    }
    
    return $subnets
}

<#
.SYNOPSIS
    Tests if a port is open on a target host
#>
function Test-Port {
    param(
        [string]$IPAddress,
        [int]$Port,
        [int]$Timeout
    )
    
    try {
        $tcpClient = New-Object System.Net.Sockets.TcpClient
        $asyncResult = $tcpClient.BeginConnect($IPAddress, $Port, $null, $null)
        $wait = $asyncResult.AsyncWaitHandle.WaitOne($Timeout, $false)
        
        if ($wait) {
            try {
                $tcpClient.EndConnect($asyncResult)
                $tcpClient.Close()
                return $true
            }
            catch {
                return $false
            }
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
    Attempts to retrieve HTTP/HTTPS response headers and content from a device
#>
function Get-HttpInfo {
    param(
        [string]$IPAddress,
        [int]$Port,
        [int]$Timeout
    )
    
    $result = @{
        Headers = @{}
        StatusCode = $null
        Content = ""
        SSL = $false
    }
    
    # Try HTTPS first if on typical HTTPS ports
    $protocols = @('http')
    if ($Port -in @(443, 8443, 5001, 9443, 4443, 6443, 7443, 10443)) {
        $protocols = @('https', 'http')
    }
    
    $originalCallback = $null
    try {
        foreach ($protocol in $protocols) {
            try {
                $uri = "${protocol}://${IPAddress}:${Port}/"
                
                # Disable SSL certificate validation for self-signed certs (common in IoT devices)
                # Note: This affects only requests made during this session. Restore it after scanning if needed.
                if ($protocol -eq 'https') {
                    $originalCallback = [System.Net.ServicePointManager]::ServerCertificateValidationCallback
                    [System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
                    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12 -bor [System.Net.SecurityProtocolType]::Tls11
                    $result.SSL = $true
                }
                
                $request = [System.Net.WebRequest]::Create($uri)
                $request.Timeout = $Timeout
                $request.Method = "GET"
                $request.UserAgent = "NetworkDeviceScanner/1.0"
                
                $response = $request.GetResponse()
                $result.StatusCode = [int]$response.StatusCode
                
                # Collect headers
                foreach ($header in $response.Headers.AllKeys) {
                    $result.Headers[$header] = $response.Headers[$header]
                }
                
                # Read content (first 4KB only)
                $stream = $response.GetResponseStream()
                $reader = New-Object System.IO.StreamReader($stream)
                $fullContent = $reader.ReadToEnd()
                $result.Content = $fullContent.Substring(0, [Math]::Min(4096, $fullContent.Length))
                
                $reader.Close()
                $stream.Close()
                $response.Close()
                
                return $result
            }
            catch [System.Net.WebException] {
                # If we get a web exception with a response, it's still a valid HTTP service
                if ($_.Exception.Response) {
                    $result.StatusCode = [int]$_.Exception.Response.StatusCode
                    foreach ($header in $_.Exception.Response.Headers.AllKeys) {
                        $result.Headers[$header] = $_.Exception.Response.Headers[$header]
                    }
                    return $result
                }
            }
            catch {
                # Try next protocol
                continue
            }
        }
        
        return $result
    }
    finally {
        # Restore original certificate validation callback
        if ($null -ne $originalCallback) {
            [System.Net.ServicePointManager]::ServerCertificateValidationCallback = $originalCallback
        }
    }
}

<#
.SYNOPSIS
    Identifies device type based on open ports and HTTP responses
#>
function Identify-Device {
    param(
        [string]$IPAddress,
        [array]$OpenPorts,
        [hashtable]$HttpResponses
    )
    
    $identifiedTypes = @()
    $apiEndpoints = @()
    $confidence = "Unknown"
    
    # Check against known device signatures
    foreach ($deviceType in $Script:DeviceSignatures.Keys) {
        $signature = $Script:DeviceSignatures[$deviceType]
        $matched = $false
        $matchReason = @()
        
        # Check if any signature ports are open
        foreach ($sigPort in $signature.Ports) {
            if ($sigPort -in $OpenPorts) {
                $matched = $true
                $matchReason += "Port $sigPort"
                
                # Check HTTP responses for this port
                if ($HttpResponses.ContainsKey($sigPort)) {
                    $httpInfo = $HttpResponses[$sigPort]
                    
                    # Check headers
                    foreach ($headerPattern in $signature.Headers) {
                        $headerMatches = $httpInfo.Headers.Values | Where-Object { $_ -like $headerPattern }
                        if ($headerMatches) {
                            $matchReason += "Header match: $headerPattern"
                            $confidence = "High"
                        }
                    }
                    
                    # Check for API paths
                    foreach ($path in $signature.Paths) {
                        if ($httpInfo.Content -like "*$path*") {
                            $matchReason += "Path found: $path"
                            $apiEndpoints += "http$(if($httpInfo.SSL){'s'})://${IPAddress}:${sigPort}${path}"
                            $confidence = "High"
                        }
                    }
                }
            }
        }
        
        if ($matched) {
            $identifiedTypes += @{
                Type = $deviceType
                Confidence = if ($confidence -eq "Unknown") { "Low" } else { $confidence }
                Reason = $matchReason -join ", "
            }
        }
    }
    
    # If no specific device identified, check for generic web services
    foreach ($port in $OpenPorts) {
        if ($HttpResponses.ContainsKey($port)) {
            $httpInfo = $HttpResponses[$port]
            if ($httpInfo.StatusCode) {
                if ($httpInfo.Content -match '["<>{}]|api|json|xml') {
                    $apiEndpoints += "http$(if($httpInfo.SSL){'s'})://${IPAddress}:${port}/"
                }
            }
        }
    }
    
    # Remove duplicates
    $apiEndpoints = $apiEndpoints | Select-Object -Unique
    
    return @{
        Types = $identifiedTypes
        APIs = $apiEndpoints
    }
}

<#
.SYNOPSIS
    Performs comprehensive scan of a single IP address
#>
function Scan-Device {
    param(
        [string]$IPAddress,
        [array]$Ports,
        [int]$PingTimeout,
        [int]$PortTimeout
    )
    
    # First, check if host is reachable
    $pingResult = Test-Connection -ComputerName $IPAddress -Count 1 -Quiet -TimeoutSeconds ($PingTimeout / 1000)
    
    if (-not $pingResult) {
        return $null
    }
    
    # Host is up, scan ports
    $openPorts = @()
    $httpResponses = @{}
    
    foreach ($port in $Ports) {
        if (Test-Port -IPAddress $IPAddress -Port $port -Timeout $PortTimeout) {
            $openPorts += $port
            
            # If it's a potential HTTP/HTTPS port, try to get more info
            if ($port -in @(80, 443, 8080, 8443, 8123, 8081, 5000, 5001, 9000, 9443, 8880, 7080, 3000, 8000, 8008, 8888)) {
                $httpInfo = Get-HttpInfo -IPAddress $IPAddress -Port $port -Timeout $PortTimeout
                if ($httpInfo.StatusCode) {
                    $httpResponses[$port] = $httpInfo
                }
            }
        }
    }
    
    if ($openPorts.Count -eq 0) {
        return $null
    }
    
    # Try to resolve hostname
    $hostname = "N/A"
    try {
        $hostEntry = [System.Net.Dns]::GetHostEntry($IPAddress)
        $hostname = $hostEntry.HostName
    }
    catch {
        $hostname = "N/A"
    }
    
    # Identify device type and APIs
    $identification = Identify-Device -IPAddress $IPAddress -OpenPorts $openPorts -HttpResponses $httpResponses
    
    # Build result object
    $result = [PSCustomObject]@{
        IPAddress = $IPAddress
        Hostname = $hostname
        Status = "Online"
        OpenPorts = ($openPorts | Sort-Object) -join ", "
        DeviceTypes = if ($identification.Types.Count -gt 0) {
            ($identification.Types | ForEach-Object { "$($_.Type) ($($_.Confidence))" }) -join "; "
        } else {
            "Unknown"
        }
        APIEndpoints = if ($identification.APIs.Count -gt 0) {
            $identification.APIs -join "; "
        } else {
            "None detected"
        }
        HttpServices = ($httpResponses.Keys | Sort-Object) -join ", "
        ScanTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    }
    
    return $result
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================

Write-ColorOutput "`n=====================================" -Type Header
Write-ColorOutput "  Network Device Scanner v1.0.0" -Type Header
Write-ColorOutput "=====================================" -Type Header

# Auto-detect subnets if not provided
if (-not $Subnets) {
    $Subnets = Get-LocalSubnets
    
    if ($Subnets.Count -eq 0) {
        Write-ColorOutput "`n[!] No active network subnets detected. Please specify subnets manually." -Type Error
        exit 1
    }
}

# Determine which ports to scan
$portsToScan = if ($CommonPortsOnly) { $Script:CommonPorts } else { $Script:ExtendedPorts }
Write-ColorOutput "`n[*] Scanning $($portsToScan.Count) ports per host" -Type Info

# Generate list of all IPs to scan
Write-ColorOutput "`n[*] Generating IP ranges from subnets..." -Type Info
$allIPs = @()
foreach ($subnet in $Subnets) {
    $ips = Get-IPRange -CIDR $subnet
    $allIPs += $ips
    Write-ColorOutput "    Subnet $subnet : $($ips.Count) hosts" -Type Info
}

Write-ColorOutput "`n[*] Total hosts to scan: $($allIPs.Count)" -Type Info
Write-ColorOutput "[*] Starting parallel scan with $MaxConcurrentJobs concurrent jobs..." -Type Info
Write-ColorOutput "[*] Timeout settings: Ping=${ScanTimeout}ms, Port=${PortTimeout}ms`n" -Type Info

# Perform parallel scanning using PowerShell jobs
$jobs = @()
$results = @()
$completedCount = 0
$foundDevices = 0

foreach ($ip in $allIPs) {
    # Throttle job creation
    while ((Get-Job -State Running).Count -ge $MaxConcurrentJobs) {
        Start-Sleep -Milliseconds 100
        
        # Collect completed jobs
        $completed = Get-Job -State Completed
        foreach ($job in $completed) {
            $result = Receive-Job -Job $job
            Remove-Job -Job $job
            
            if ($result) {
                $results += $result
                $foundDevices++
                Write-ColorOutput "[+] Device found: $($result.IPAddress) - $($result.DeviceTypes)" -Type Success
            }
            
            $completedCount++
        }
    }
    
    # Start new scanning job
    $scriptBlock = {
        param($ip, $ports, $pingTimeout, $portTimeout, $functions, $signatures)
        
        # Import functions into job scope
        . ([ScriptBlock]::Create($functions))
        $Script:DeviceSignatures = $signatures
        
        Scan-Device -IPAddress $ip -Ports $ports -PingTimeout $pingTimeout -PortTimeout $portTimeout
    }
    
    # Export function definitions to pass to jobs
    $functionDefs = @"
        function Test-Port { param([string]`$IPAddress, [int]`$Port, [int]`$Timeout)
            try {
                `$tcpClient = New-Object System.Net.Sockets.TcpClient
                `$asyncResult = `$tcpClient.BeginConnect(`$IPAddress, `$Port, `$null, `$null)
                `$wait = `$asyncResult.AsyncWaitHandle.WaitOne(`$Timeout, `$false)
                if (`$wait) {
                    try { `$tcpClient.EndConnect(`$asyncResult); `$tcpClient.Close(); return `$true }
                    catch { return `$false }
                } else { `$tcpClient.Close(); return `$false }
            } catch { return `$false }
        }
        
        function Get-HttpInfo { param([string]`$IPAddress, [int]`$Port, [int]`$Timeout)
            `$result = @{ Headers = @{}; StatusCode = `$null; Content = ""; SSL = `$false }
            `$protocols = @('http')
            if (`$Port -in @(443, 8443, 5001, 9443, 4443, 6443, 7443, 10443)) { `$protocols = @('https', 'http') }
            foreach (`$protocol in `$protocols) {
                try {
                    `$uri = "`${protocol}://`${IPAddress}:`${Port}/"
                    if (`$protocol -eq 'https') {
                        [System.Net.ServicePointManager]::ServerCertificateValidationCallback = {`$true}
                        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12 -bor [System.Net.SecurityProtocolType]::Tls11
                        `$result.SSL = `$true
                    }
                    `$request = [System.Net.WebRequest]::Create(`$uri)
                    `$request.Timeout = `$Timeout
                    `$request.Method = "GET"
                    `$request.UserAgent = "NetworkDeviceScanner/1.0"
                    `$response = `$request.GetResponse()
                    `$result.StatusCode = [int]`$response.StatusCode
                    foreach (`$header in `$response.Headers.AllKeys) { `$result.Headers[`$header] = `$response.Headers[`$header] }
                    `$stream = `$response.GetResponseStream()
                    `$reader = New-Object System.IO.StreamReader(`$stream)
                    `$result.Content = `$reader.ReadToEnd().Substring(0, [Math]::Min(4096, `$reader.BaseStream.Length))
                    `$reader.Close(); `$stream.Close(); `$response.Close()
                    return `$result
                } catch [System.Net.WebException] {
                    if (`$_.Exception.Response) {
                        `$result.StatusCode = [int]`$_.Exception.Response.StatusCode
                        foreach (`$header in `$_.Exception.Response.Headers.AllKeys) { `$result.Headers[`$header] = `$_.Exception.Response.Headers[`$header] }
                        return `$result
                    }
                } catch { continue }
            }
            return `$result
        }
        
        function Identify-Device { param([string]`$IPAddress, [array]`$OpenPorts, [hashtable]`$HttpResponses)
            `$identifiedTypes = @(); `$apiEndpoints = @(); `$confidence = "Unknown"
            foreach (`$deviceType in `$Script:DeviceSignatures.Keys) {
                `$signature = `$Script:DeviceSignatures[`$deviceType]
                `$matched = `$false; `$matchReason = @()
                foreach (`$sigPort in `$signature.Ports) {
                    if (`$sigPort -in `$OpenPorts) {
                        `$matched = `$true; `$matchReason += "Port `$sigPort"
                        if (`$HttpResponses.ContainsKey(`$sigPort)) {
                            `$httpInfo = `$HttpResponses[`$sigPort]
                            foreach (`$headerPattern in `$signature.Headers) {
                                `$headerMatches = `$httpInfo.Headers.Values | Where-Object { `$_ -like `$headerPattern }
                                if (`$headerMatches) { `$matchReason += "Header match: `$headerPattern"; `$confidence = "High" }
                            }
                            foreach (`$path in `$signature.Paths) {
                                if (`$httpInfo.Content -like "*`$path*") {
                                    `$matchReason += "Path found: `$path"
                                    `$apiEndpoints += "http`$(if(`$httpInfo.SSL){'s'})://`${IPAddress}:`${sigPort}`${path}"
                                    `$confidence = "High"
                                }
                            }
                        }
                    }
                }
                if (`$matched) {
                    `$identifiedTypes += @{ Type = `$deviceType; Confidence = if (`$confidence -eq "Unknown") { "Low" } else { `$confidence }; Reason = `$matchReason -join ", " }
                }
            }
            foreach (`$port in `$OpenPorts) {
                if (`$HttpResponses.ContainsKey(`$port)) {
                    `$httpInfo = `$HttpResponses[`$port]
                    if (`$httpInfo.StatusCode -and (`$httpInfo.Content -match '["<>{}]|api|json|xml')) {
                        `$apiEndpoints += "http`$(if(`$httpInfo.SSL){'s'})://`${IPAddress}:`${port}/"
                    }
                }
            }
            `$apiEndpoints = `$apiEndpoints | Select-Object -Unique
            return @{ Types = `$identifiedTypes; APIs = `$apiEndpoints }
        }
        
        function Scan-Device { param([string]`$IPAddress, [array]`$Ports, [int]`$PingTimeout, [int]`$PortTimeout)
            `$pingResult = Test-Connection -ComputerName `$IPAddress -Count 1 -Quiet -TimeoutSeconds (`$PingTimeout / 1000)
            if (-not `$pingResult) { return `$null }
            `$openPorts = @(); `$httpResponses = @{}
            foreach (`$port in `$Ports) {
                if (Test-Port -IPAddress `$IPAddress -Port `$port -Timeout `$PortTimeout) {
                    `$openPorts += `$port
                    if (`$port -in @(80, 443, 8080, 8443, 8123, 8081, 5000, 5001, 9000, 9443, 8880, 7080, 3000, 8000, 8008, 8888)) {
                        `$httpInfo = Get-HttpInfo -IPAddress `$IPAddress -Port `$port -Timeout `$PortTimeout
                        if (`$httpInfo.StatusCode) { `$httpResponses[`$port] = `$httpInfo }
                    }
                }
            }
            if (`$openPorts.Count -eq 0) { return `$null }
            `$hostname = "N/A"
            try { `$hostEntry = [System.Net.Dns]::GetHostEntry(`$IPAddress); `$hostname = `$hostEntry.HostName } catch { `$hostname = "N/A" }
            `$identification = Identify-Device -IPAddress `$IPAddress -OpenPorts `$openPorts -HttpResponses `$httpResponses
            return [PSCustomObject]@{
                IPAddress = `$IPAddress; Hostname = `$hostname; Status = "Online"
                OpenPorts = (`$openPorts | Sort-Object) -join ", "
                DeviceTypes = if (`$identification.Types.Count -gt 0) { (`$identification.Types | ForEach-Object { "`$(`$_.Type) (`$(`$_.Confidence))" }) -join "; " } else { "Unknown" }
                APIEndpoints = if (`$identification.APIs.Count -gt 0) { `$identification.APIs -join "; " } else { "None detected" }
                HttpServices = (`$httpResponses.Keys | Sort-Object) -join ", "
                ScanTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
        }
"@
    
    $job = Start-Job -ScriptBlock $scriptBlock -ArgumentList $ip, $portsToScan, $ScanTimeout, $PortTimeout, $functionDefs, $Script:DeviceSignatures
    $jobs += $job
}

# Wait for all remaining jobs to complete
Write-ColorOutput "`n[*] Waiting for remaining scan jobs to complete..." -Type Info
Get-Job | Wait-Job | Out-Null

# Collect final results
foreach ($job in Get-Job) {
    $result = Receive-Job -Job $job
    Remove-Job -Job $job
    
    if ($result) {
        $results += $result
    }
}

# =============================================================================
# RESULTS OUTPUT
# =============================================================================

Write-ColorOutput "`n=====================================" -Type Header
Write-ColorOutput "  Scan Complete!" -Type Header
Write-ColorOutput "=====================================" -Type Header
Write-ColorOutput "`nTotal devices found: $($results.Count)" -Type Success
Write-ColorOutput "Total hosts scanned: $($allIPs.Count)`n" -Type Info

if ($results.Count -gt 0) {
    # Output results in requested format
    switch ($OutputFormat) {
        'Table' {
            $results | Format-Table -AutoSize -Wrap
        }
        'List' {
            $results | Format-List
        }
        'JSON' {
            $results | ConvertTo-Json -Depth 10
        }
        'CSV' {
            $results | ConvertTo-Csv -NoTypeInformation
        }
    }
    
    # Export if requested
    if ($ExportPath) {
        try {
            $extension = [System.IO.Path]::GetExtension($ExportPath).ToLower()
            
            switch ($extension) {
                '.json' {
                    $results | ConvertTo-Json -Depth 10 | Out-File -FilePath $ExportPath -Encoding UTF8
                }
                '.csv' {
                    $results | Export-Csv -Path $ExportPath -NoTypeInformation -Encoding UTF8
                }
                '.xml' {
                    $results | Export-Clixml -Path $ExportPath
                }
                default {
                    $results | Out-File -FilePath $ExportPath -Encoding UTF8
                }
            }
            
            Write-ColorOutput "`n[*] Results exported to: $ExportPath" -Type Success
        }
        catch {
            Write-ColorOutput "`n[!] Failed to export results: $_" -Type Error
        }
    }
    
    # Summary statistics
    Write-ColorOutput "`n=====================================" -Type Header
    Write-ColorOutput "  Device Type Summary" -Type Header
    Write-ColorOutput "=====================================" -Type Header
    
    $deviceTypeCounts = @{}
    foreach ($result in $results) {
        $types = $result.DeviceTypes -split ";" | ForEach-Object { $_.Trim() -replace '\s*\(.*\)\s*$', '' }
        foreach ($type in $types) {
            if ($type -and $type -ne "Unknown") {
                if (-not $deviceTypeCounts.ContainsKey($type)) {
                    $deviceTypeCounts[$type] = 0
                }
                $deviceTypeCounts[$type]++
            }
        }
    }
    
    if ($deviceTypeCounts.Count -gt 0) {
        foreach ($type in ($deviceTypeCounts.Keys | Sort-Object)) {
            Write-ColorOutput "  $type : $($deviceTypeCounts[$type])" -Type Info
        }
    }
    else {
        Write-ColorOutput "  No specifically identified device types" -Type Warning
    }
    
    # API endpoint summary
    $totalAPIs = ($results | Where-Object { $_.APIEndpoints -ne "None detected" }).Count
    Write-ColorOutput "`n=====================================" -Type Header
    Write-ColorOutput "  API Endpoints Detected: $totalAPIs" -Type Header
    Write-ColorOutput "=====================================" -Type Header
}
else {
    Write-ColorOutput "`n[!] No devices found on scanned networks." -Type Warning
    Write-ColorOutput "    This could mean:" -Type Info
    Write-ColorOutput "    - No devices are online" -Type Info
    Write-ColorOutput "    - Firewall is blocking ICMP/port scans" -Type Info
    Write-ColorOutput "    - Network isolation is in place" -Type Info
}

Write-ColorOutput "`n[*] Scan completed at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -Type Success
Write-ColorOutput "=====================================" -Type Header

# Return results object for programmatic use
return $results
