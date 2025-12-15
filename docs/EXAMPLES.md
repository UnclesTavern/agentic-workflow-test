# Network Device Scanner - Examples

Real-world usage scenarios, sample outputs, and integration examples.

## Table of Contents

1. [Basic Usage Examples](#basic-usage-examples)
2. [Real-World Scenarios](#real-world-scenarios)
3. [Sample Output](#sample-output)
4. [Integration Examples](#integration-examples)
5. [Automation Examples](#automation-examples)
6. [Data Analysis Examples](#data-analysis-examples)

---

## Basic Usage Examples

### Example 1: First-Time Scan

**Scenario:** New user running script for the first time on home network.

```powershell
# Navigate to script location
cd C:\Scripts

# Run with default settings
.\NetworkDeviceScanner.ps1
```

**Expected Console Output:**
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
  [+] Found: 192.168.1.10
  [+] Found: 192.168.1.100
  [+] Found: 192.168.1.150
  [+] Found: 192.168.1.151

Found 5 reachable host(s) in 192.168.1.0/24

Phase 2: Scanning devices for details...
  [*] 192.168.1.1 - Unknown
  [*] 192.168.1.10 - Unknown
  [*] 192.168.1.100 - IOTHub
  [*] 192.168.1.150 - IOTDevice
  [*] 192.168.1.151 - IOTDevice

========================================
  Scan Complete - Summary
========================================

Total devices found: 5

IOTHub Devices (1):
------------------------------------------------------------

IP Address: 192.168.1.100
  Hostname: homeassistant.local
  MAC: a0-20-a6-12-34-56 (Espressif (ESP8266/ESP32))
  Open Ports: 80, 8123
  API Endpoints:
    - http://192.168.1.100:8123/ [Status: 200]

IOTDevice Devices (2):
------------------------------------------------------------

IP Address: 192.168.1.150
  Hostname: shelly1pm-ABC123.local
  MAC: ec-08-6b-11-22-33 (Shelly)
  Open Ports: 80
  API Endpoints:
    - http://192.168.1.150/ [Status: 200]
    - http://192.168.1.150/status [Status: 200]

IP Address: 192.168.1.151
  Hostname: shellyplug-DEF456.local
  MAC: ec-08-6b-44-55-66 (Shelly)
  Open Ports: 80
  API Endpoints:
    - http://192.168.1.151/ [Status: 200]

Unknown Devices (2):
------------------------------------------------------------

IP Address: 192.168.1.1
  Hostname: router.local
  Open Ports: 80, 443

IP Address: 192.168.1.10
  Hostname: desktop-ABC.local


Results exported to: NetworkScan_20231215_143022.json

Scan completed successfully!
```

---

### Example 2: Targeted Subnet Scan

**Scenario:** IT professional scanning specific IoT VLAN.

```powershell
.\NetworkDeviceScanner.ps1 -Subnets "10.0.10.0/24" -Timeout 500
```

**Use Case:**
- Dedicated IoT subnet (10.0.10.0/24)
- Fast wired network (500ms timeout)
- Need to inventory smart home devices

---

### Example 3: Multi-Subnet Corporate Environment

**Scenario:** Network administrator scanning multiple VLANs.

```powershell
.\NetworkDeviceScanner.ps1 `
    -Subnets "10.0.10.0/24","10.0.20.0/24","10.0.30.0/24" `
    -Ports 80,443,8080,8443 `
    -Timeout 1500
```

**Network Layout:**
- 10.0.10.0/24 - IoT devices
- 10.0.20.0/24 - Security cameras
- 10.0.30.0/24 - Access control systems

---

### Example 4: Finding Specific Device Type

**Scenario:** Looking for Home Assistant instance.

```powershell
# Scan with ports common to Home Assistant
.\NetworkDeviceScanner.ps1 -Ports 8123,8080,443

# Review JSON output for IOTHub devices
$scan = Get-Content "NetworkScan_*.json" | ConvertFrom-Json
$scan | Where-Object DeviceType -eq 'IOTHub'
```

---

## Real-World Scenarios

### Scenario 1: Smart Home Inventory

**Context:**
- Homeowner with 20+ smart devices
- Multiple brands (Shelly, Philips Hue, TP-Link)
- Wants complete device inventory

**Solution:**
```powershell
# Full scan with all default ports
.\NetworkDeviceScanner.ps1 -Timeout 2000

# Analyze results
$devices = Get-Content "NetworkScan_*.json" | ConvertFrom-Json

# Count by type
$devices | Group-Object DeviceType | Select-Object Name, Count

# List by manufacturer
$devices | Group-Object Manufacturer | Select-Object Name, Count
```

**Expected Results:**
```
Name         Count
----         -----
IOTHub       1
IOTDevice    18
Security     2
Unknown      5

Manufacturer                    Count
------------                    -----
Shelly                          8
Espressif (ESP8266/ESP32)       6
TP-Link (Tapo/Kasa)            4
Philips Hue                     1
Ubiquiti Networks               2
Unknown                         5
```

---

### Scenario 2: Network Security Audit

**Context:**
- Security consultant hired for home network audit
- Need to identify all devices with web interfaces
- Check for unexpected devices

**Solution:**
```powershell
# Comprehensive scan
.\NetworkDeviceScanner.ps1 -Timeout 2000

# Load results
$devices = Get-Content "NetworkScan_*.json" | ConvertFrom-Json

# Devices with web interfaces
$webDevices = $devices | Where-Object { $_.OpenPorts -contains 80 -or $_.OpenPorts -contains 443 }

Write-Host "`nDevices with web interfaces: $($webDevices.Count)" -ForegroundColor Yellow
$webDevices | ForEach-Object {
    Write-Host "`n$($_.IPAddress) - $($_.Hostname)"
    Write-Host "  Type: $($_.DeviceType)"
    Write-Host "  Ports: $($_.OpenPorts -join ', ')"
    if ($_.Endpoints.Count -gt 0) {
        Write-Host "  URLs:"
        $_.Endpoints | ForEach-Object {
            Write-Host "    - $($_.URL)"
        }
    }
}

# Check for devices without hostnames (potential security risk)
$unknownDevices = $devices | Where-Object { -not $_.Hostname }
Write-Host "`nDevices without hostnames: $($unknownDevices.Count)" -ForegroundColor Red
```

---

### Scenario 3: Pre-Purchase Home Inspection

**Context:**
- Home buyer wants to know about smart home system
- Seller claims "fully smart home with 30+ devices"
- Buyer's agent performs scan during inspection

**Solution:**
```powershell
# Quick scan during home showing
.\NetworkDeviceScanner.ps1 -Timeout 1000

# Generate simple report
$devices = Get-Content "NetworkScan_*.json" | ConvertFrom-Json

$report = @"
Smart Home Inspection Report
=============================
Scan Date: $(Get-Date -Format 'yyyy-MM-dd HH:mm')

Total Devices: $($devices.Count)

By Category:
$(($devices | Group-Object DeviceType | ForEach-Object { "  $($_.Name): $($_.Count)" }) -join "`n")

By Manufacturer:
$(($devices | Group-Object Manufacturer | Where-Object Name -ne 'Unknown' | ForEach-Object { "  $($_.Name): $($_.Count)" }) -join "`n")

Hub Devices:
$(($devices | Where-Object DeviceType -eq 'IOTHub' | ForEach-Object { "  - $($_.IPAddress): $($_.Hostname)" }) -join "`n")

Notes:
- All devices appear operational
- Central hub detected (Home Assistant)
- Compatible with standard systems
"@

$report | Out-File "SmartHome_Inspection_$(Get-Date -Format 'yyyyMMdd').txt"
Write-Host $report
```

---

### Scenario 4: IoT Device Troubleshooting

**Context:**
- User's Shelly device stopped responding
- Can't remember device IP address
- Needs to locate device on network

**Solution:**
```powershell
# Quick scan to find Shelly devices
.\NetworkDeviceScanner.ps1 -Ports 80,443 -Timeout 1000

# Filter for Shelly devices
$devices = Get-Content "NetworkScan_*.json" | ConvertFrom-Json
$shellyDevices = $devices | Where-Object Manufacturer -like '*Shelly*'

Write-Host "`nFound $($shellyDevices.Count) Shelly device(s):" -ForegroundColor Green
$shellyDevices | ForEach-Object {
    Write-Host "`nIP: $($_.IPAddress)"
    Write-Host "Hostname: $($_.Hostname)"
    Write-Host "MAC: $($_.MACAddress)"
    if ($_.Endpoints.Count -gt 0) {
        Write-Host "Status: Online ✓" -ForegroundColor Green
        Write-Host "Access: $($_.Endpoints[0].URL)"
    } else {
        Write-Host "Status: Not responding ✗" -ForegroundColor Red
    }
}
```

---

### Scenario 5: Network Segmentation Planning

**Context:**
- Network engineer planning VLAN segmentation
- Need inventory of current device placement
- Will separate IoT from main network

**Solution:**
```powershell
# Scan current network
.\NetworkDeviceScanner.ps1

# Analyze for VLAN planning
$devices = Get-Content "NetworkScan_*.json" | ConvertFrom-Json

# Group devices for VLAN assignment
$vlans = @{
    "VLAN 10 - Management" = $devices | Where-Object { $_.DeviceType -eq 'Unknown' -and ($_.OpenPorts -contains 80 -or $_.OpenPorts -contains 443) }
    "VLAN 20 - IoT Hub" = $devices | Where-Object DeviceType -eq 'IOTHub'
    "VLAN 30 - IoT Devices" = $devices | Where-Object DeviceType -eq 'IOTDevice'
    "VLAN 40 - Security" = $devices | Where-Object DeviceType -eq 'Security'
}

# Generate VLAN plan
Write-Host "`nVLAN Segmentation Plan" -ForegroundColor Cyan
Write-Host "=" * 50

foreach ($vlan in $vlans.Keys) {
    Write-Host "`n$vlan ($($vlans[$vlan].Count) devices)" -ForegroundColor Yellow
    $vlans[$vlan] | ForEach-Object {
        Write-Host "  - $($_.IPAddress)`t$($_.Hostname)`t$($_.Manufacturer)"
    }
}

# Export VLAN assignments
$vlans.Keys | ForEach-Object {
    $vlanName = $_ -replace ' ', '_'
    $vlans[$_] | Export-Csv -Path "VLAN_${vlanName}.csv" -NoTypeInformation
}
```

---

## Sample Output

### JSON Output Sample

**File:** `NetworkScan_20231215_143022.json`

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
        "Server": "nginx/1.18.0",
        "ContentLength": 5432,
        "Content": "<!DOCTYPE html><html><head><title>Home Assistant</title>..."
      },
      {
        "URL": "http://192.168.1.100:8123/api",
        "StatusCode": 200,
        "Server": "nginx/1.18.0",
        "ContentLength": 45,
        "Content": "{\"message\": \"API running.\"}"
      }
    ],
    "ScanTime": "2023-12-15 14:30:22"
  },
  {
    "IPAddress": "192.168.1.150",
    "Hostname": "shelly1pm-ABC123.local",
    "MACAddress": "ec-08-6b-11-22-33",
    "Manufacturer": "Shelly",
    "DeviceType": "IOTDevice",
    "OpenPorts": [80],
    "Endpoints": [
      {
        "URL": "http://192.168.1.150/",
        "StatusCode": 200,
        "Server": "Mongoose/6.18",
        "ContentLength": 2341,
        "Content": "<!DOCTYPE html><html><head><title>Shelly 1PM</title>..."
      },
      {
        "URL": "http://192.168.1.150/status",
        "StatusCode": 200,
        "Server": "Mongoose/6.18",
        "ContentLength": 234,
        "Content": "{\"wifi_sta\":{\"connected\":true,\"ssid\":\"MyNetwork\",\"ip\":\"192.168.1.150\"..."
      }
    ],
    "ScanTime": "2023-12-15 14:30:45"
  },
  {
    "IPAddress": "192.168.1.1",
    "Hostname": "router.local",
    "MACAddress": "00-11-22-33-44-55",
    "Manufacturer": "Unknown",
    "DeviceType": "Unknown",
    "OpenPorts": [80, 443],
    "Endpoints": [
      {
        "URL": "https://192.168.1.1/",
        "StatusCode": 200,
        "Server": "lighttpd",
        "ContentLength": 1523,
        "Content": "<!DOCTYPE html><html><head><title>Router Login</title>..."
      }
    ],
    "ScanTime": "2023-12-15 14:29:15"
  }
]
```

---

## Integration Examples

### Example 1: Home Assistant Integration

**Scenario:** Send scan results to Home Assistant sensor.

```powershell
# Perform scan
.\NetworkDeviceScanner.ps1

# Load results
$devices = Get-Content "NetworkScan_*.json" | ConvertFrom-Json

# Calculate statistics
$stats = @{
    total_devices = $devices.Count
    iot_hubs = ($devices | Where-Object DeviceType -eq 'IOTHub').Count
    iot_devices = ($devices | Where-Object DeviceType -eq 'IOTDevice').Count
    security_devices = ($devices | Where-Object DeviceType -eq 'Security').Count
    unknown_devices = ($devices | Where-Object DeviceType -eq 'Unknown').Count
    scan_time = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
}

# Send to Home Assistant
$haUrl = "http://homeassistant.local:8123/api/states/sensor.network_scanner"
$haToken = "YOUR_LONG_LIVED_ACCESS_TOKEN"

$body = @{
    state = $stats.total_devices
    attributes = $stats
} | ConvertTo-Json

Invoke-RestMethod `
    -Uri $haUrl `
    -Method Post `
    -Headers @{ "Authorization" = "Bearer $haToken" } `
    -Body $body `
    -ContentType "application/json"

Write-Host "Sent scan results to Home Assistant" -ForegroundColor Green
```

**Home Assistant Configuration:**

```yaml
# configuration.yaml
sensor:
  - platform: rest
    name: Network Scanner
    resource: http://homeassistant.local:8123/api/states/sensor.network_scanner
    value_template: "{{ value_json.state }}"
    json_attributes:
      - total_devices
      - iot_hubs
      - iot_devices
      - security_devices
      - unknown_devices
      - scan_time
```

---

### Example 2: Excel Report Generation

**Scenario:** Create Excel spreadsheet for management.

```powershell
# Requires ImportExcel module
# Install-Module -Name ImportExcel -Scope CurrentUser

# Perform scan
.\NetworkDeviceScanner.ps1

# Load results
$devices = Get-Content "NetworkScan_*.json" | ConvertFrom-Json

# Prepare data for Excel
$excelData = $devices | Select-Object `
    IPAddress,
    Hostname,
    MACAddress,
    Manufacturer,
    DeviceType,
    @{Name='OpenPorts'; Expression={$_.OpenPorts -join ', '}},
    @{Name='EndpointCount'; Expression={$_.Endpoints.Count}},
    ScanTime

# Export to Excel with formatting
$excelPath = "NetworkScan_$(Get-Date -Format 'yyyyMMdd').xlsx"

$excelData | Export-Excel `
    -Path $excelPath `
    -AutoSize `
    -TableName "NetworkDevices" `
    -TableStyle Medium6 `
    -FreezeTopRow `
    -BoldTopRow

Write-Host "Excel report created: $excelPath" -ForegroundColor Green

# Open Excel
Start-Process $excelPath
```

---

### Example 3: Database Integration

**Scenario:** Store scan history in SQL Server database.

```powershell
# Perform scan
.\NetworkDeviceScanner.ps1

# Database connection
$connectionString = "Server=localhost;Database=NetworkInventory;Integrated Security=True;"
$connection = New-Object System.Data.SqlClient.SqlConnection($connectionString)
$connection.Open()

# Load results
$devices = Get-Content "NetworkScan_*.json" | ConvertFrom-Json
$scanId = [guid]::NewGuid().ToString()
$scanTime = Get-Date

# Insert scan record
$scanQuery = @"
INSERT INTO Scans (ScanId, ScanDate, DeviceCount)
VALUES (@ScanId, @ScanDate, @DeviceCount)
"@

$scanCmd = $connection.CreateCommand()
$scanCmd.CommandText = $scanQuery
$scanCmd.Parameters.AddWithValue("@ScanId", $scanId) | Out-Null
$scanCmd.Parameters.AddWithValue("@ScanDate", $scanTime) | Out-Null
$scanCmd.Parameters.AddWithValue("@DeviceCount", $devices.Count) | Out-Null
$scanCmd.ExecuteNonQuery() | Out-Null

# Insert device records
$deviceQuery = @"
INSERT INTO Devices (ScanId, IPAddress, Hostname, MACAddress, Manufacturer, DeviceType, OpenPorts, ScanTime)
VALUES (@ScanId, @IPAddress, @Hostname, @MACAddress, @Manufacturer, @DeviceType, @OpenPorts, @ScanTime)
"@

foreach ($device in $devices) {
    $deviceCmd = $connection.CreateCommand()
    $deviceCmd.CommandText = $deviceQuery
    $deviceCmd.Parameters.AddWithValue("@ScanId", $scanId) | Out-Null
    $deviceCmd.Parameters.AddWithValue("@IPAddress", $device.IPAddress) | Out-Null
    $deviceCmd.Parameters.AddWithValue("@Hostname", $device.Hostname ?? [DBNull]::Value) | Out-Null
    $deviceCmd.Parameters.AddWithValue("@MACAddress", $device.MACAddress ?? [DBNull]::Value) | Out-Null
    $deviceCmd.Parameters.AddWithValue("@Manufacturer", $device.Manufacturer) | Out-Null
    $deviceCmd.Parameters.AddWithValue("@DeviceType", $device.DeviceType) | Out-Null
    $deviceCmd.Parameters.AddWithValue("@OpenPorts", ($device.OpenPorts -join ',')) | Out-Null
    $deviceCmd.Parameters.AddWithValue("@ScanTime", $device.ScanTime) | Out-Null
    $deviceCmd.ExecuteNonQuery() | Out-Null
}

$connection.Close()
Write-Host "Stored $($devices.Count) devices in database" -ForegroundColor Green
```

**Database Schema:**

```sql
CREATE TABLE Scans (
    ScanId UNIQUEIDENTIFIER PRIMARY KEY,
    ScanDate DATETIME NOT NULL,
    DeviceCount INT NOT NULL
);

CREATE TABLE Devices (
    DeviceId INT IDENTITY(1,1) PRIMARY KEY,
    ScanId UNIQUEIDENTIFIER NOT NULL,
    IPAddress VARCHAR(15) NOT NULL,
    Hostname VARCHAR(255),
    MACAddress VARCHAR(17),
    Manufacturer VARCHAR(255),
    DeviceType VARCHAR(50),
    OpenPorts VARCHAR(255),
    ScanTime DATETIME,
    FOREIGN KEY (ScanId) REFERENCES Scans(ScanId)
);
```

---

### Example 4: Slack Notification

**Scenario:** Send scan summary to Slack channel.

```powershell
# Perform scan
.\NetworkDeviceScanner.ps1

# Load results
$devices = Get-Content "NetworkScan_*.json" | ConvertFrom-Json

# Calculate stats
$stats = $devices | Group-Object DeviceType
$newDevices = $devices | Where-Object { 
    (Get-Date $_.ScanTime) -gt (Get-Date).AddHours(-1) 
}

# Build Slack message
$slackMessage = @{
    text = "Network Scan Complete"
    blocks = @(
        @{
            type = "header"
            text = @{
                type = "plain_text"
                text = "🔍 Network Scan Results"
            }
        },
        @{
            type = "section"
            fields = @(
                @{
                    type = "mrkdwn"
                    text = "*Total Devices:*`n$($devices.Count)"
                },
                @{
                    type = "mrkdwn"
                    text = "*Scan Time:*`n$(Get-Date -Format 'HH:mm:ss')"
                }
            )
        },
        @{
            type = "section"
            text = @{
                type = "mrkdwn"
                text = "*Devices by Type:*`n" + (($stats | ForEach-Object { "• $($_.Name): $($_.Count)" }) -join "`n")
            }
        }
    )
}

if ($newDevices.Count -gt 0) {
    $slackMessage.blocks += @{
        type = "section"
        text = @{
            type = "mrkdwn"
            text = "⚠️ *$($newDevices.Count) new device(s) detected!*"
        }
    }
}

# Send to Slack
$webhookUrl = "https://hooks.slack.com/services/YOUR/WEBHOOK/URL"
Invoke-RestMethod `
    -Uri $webhookUrl `
    -Method Post `
    -Body ($slackMessage | ConvertTo-Json -Depth 10) `
    -ContentType "application/json"

Write-Host "Notification sent to Slack" -ForegroundColor Green
```

---

## Automation Examples

### Example 1: Scheduled Daily Scan

**Using Windows Task Scheduler:**

1. **Create PowerShell script** (`C:\Scripts\DailyScan.ps1`):

```powershell
# Daily network scan script
$logFile = "C:\Scripts\Logs\scan_$(Get-Date -Format 'yyyyMMdd').log"

# Start logging
Start-Transcript -Path $logFile

Write-Host "Starting scheduled network scan..." -ForegroundColor Cyan

try {
    # Run scan
    & "C:\Scripts\NetworkDeviceScanner.ps1" -Timeout 1000
    
    # Archive JSON to dedicated folder
    $latestScan = Get-ChildItem -Path "C:\Scripts" -Filter "NetworkScan_*.json" | 
                  Sort-Object LastWriteTime -Descending | 
                  Select-Object -First 1
    
    if ($latestScan) {
        $archivePath = "C:\Scripts\ScanArchive"
        if (-not (Test-Path $archivePath)) {
            New-Item -Path $archivePath -ItemType Directory
        }
        Move-Item -Path $latestScan.FullName -Destination $archivePath
        Write-Host "Archived scan results to $archivePath" -ForegroundColor Green
    }
    
    Write-Host "Scan completed successfully" -ForegroundColor Green
}
catch {
    Write-Error "Scan failed: $_"
    
    # Send error email (optional)
    Send-MailMessage `
        -To "admin@example.com" `
        -From "scanner@example.com" `
        -Subject "Network Scan Failed" `
        -Body "Error: $_" `
        -SmtpServer "smtp.example.com"
}
finally {
    Stop-Transcript
}
```

2. **Create scheduled task:**

```powershell
# Run as Administrator
$action = New-ScheduledTaskAction `
    -Execute "PowerShell.exe" `
    -Argument "-ExecutionPolicy Bypass -File C:\Scripts\DailyScan.ps1"

$trigger = New-ScheduledTaskTrigger -Daily -At 2:00AM

$settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -StartWhenAvailable

Register-ScheduledTask `
    -TaskName "Daily Network Scan" `
    -Action $action `
    -Trigger $trigger `
    -Settings $settings `
    -User "SYSTEM" `
    -RunLevel Highest `
    -Description "Performs daily network device scan"
```

---

### Example 2: Change Detection

**Monitor for new or removed devices:**

```powershell
# Change detection script
$baselinePath = "C:\Scripts\baseline.json"
$currentScanPath = "NetworkScan_*.json"

# Run current scan
.\NetworkDeviceScanner.ps1

# Load current scan
$currentDevices = Get-Content (Get-ChildItem $currentScanPath | Sort-Object LastWriteTime -Descending | Select-Object -First 1).FullName | ConvertFrom-Json

# Check if baseline exists
if (Test-Path $baselinePath) {
    # Load baseline
    $baselineDevices = Get-Content $baselinePath | ConvertFrom-Json
    
    # Find new devices
    $newDevices = $currentDevices | Where-Object { 
        $current = $_
        -not ($baselineDevices | Where-Object IPAddress -eq $current.IPAddress)
    }
    
    # Find removed devices
    $removedDevices = $baselineDevices | Where-Object {
        $baseline = $_
        -not ($currentDevices | Where-Object IPAddress -eq $baseline.IPAddress)
    }
    
    # Report changes
    if ($newDevices.Count -gt 0 -or $removedDevices.Count -gt 0) {
        Write-Host "`n⚠️  NETWORK CHANGES DETECTED ⚠️`n" -ForegroundColor Yellow
        
        if ($newDevices.Count -gt 0) {
            Write-Host "New Devices ($($newDevices.Count)):" -ForegroundColor Green
            $newDevices | ForEach-Object {
                Write-Host "  + $($_.IPAddress) - $($_.Hostname) [$($_.DeviceType)]" -ForegroundColor Green
            }
        }
        
        if ($removedDevices.Count -gt 0) {
            Write-Host "`nRemoved Devices ($($removedDevices.Count)):" -ForegroundColor Red
            $removedDevices | ForEach-Object {
                Write-Host "  - $($_.IPAddress) - $($_.Hostname) [$($_.DeviceType)]" -ForegroundColor Red
            }
        }
        
        # Send alert (optional)
        # ... send email/Slack notification ...
    } else {
        Write-Host "`n✓ No changes detected" -ForegroundColor Green
    }
} else {
    Write-Host "No baseline found. Creating baseline..." -ForegroundColor Yellow
    $currentDevices | ConvertTo-Json -Depth 10 | Out-File $baselinePath
    Write-Host "Baseline created: $baselinePath" -ForegroundColor Green
}

# Update baseline (optional - only if you want rolling baseline)
# $currentDevices | ConvertTo-Json -Depth 10 | Out-File $baselinePath
```

---

## Data Analysis Examples

### Example 1: Historical Trend Analysis

**Analyze device count over time:**

```powershell
# Load all archived scans
$archivePath = "C:\Scripts\ScanArchive"
$scanFiles = Get-ChildItem -Path $archivePath -Filter "NetworkScan_*.json"

$history = foreach ($file in $scanFiles) {
    $devices = Get-Content $file.FullName | ConvertFrom-Json
    
    [PSCustomObject]@{
        Date = $file.BaseName -replace 'NetworkScan_', '' -replace '(\d{4})(\d{2})(\d{2})_.*', '$1-$2-$3'
        TotalDevices = $devices.Count
        IOTHubs = ($devices | Where-Object DeviceType -eq 'IOTHub').Count
        IOTDevices = ($devices | Where-Object DeviceType -eq 'IOTDevice').Count
        SecurityDevices = ($devices | Where-Object DeviceType -eq 'Security').Count
        UnknownDevices = ($devices | Where-Object DeviceType -eq 'Unknown').Count
    }
}

# Display trend
$history | Sort-Object Date | Format-Table -AutoSize

# Export to CSV for charting
$history | Export-Csv -Path "DeviceTrend.csv" -NoTypeInformation

# Simple statistics
Write-Host "`nDevice Count Statistics:" -ForegroundColor Cyan
Write-Host "  Average: $(($history | Measure-Object TotalDevices -Average).Average)"
Write-Host "  Minimum: $(($history | Measure-Object TotalDevices -Minimum).Minimum)"
Write-Host "  Maximum: $(($history | Measure-Object TotalDevices -Maximum).Maximum)"
```

---

### Example 2: Manufacturer Distribution

**Analyze manufacturer distribution:**

```powershell
# Load latest scan
$devices = Get-Content "NetworkScan_*.json" | ConvertFrom-Json

# Group by manufacturer
$manufacturers = $devices | 
    Where-Object Manufacturer -ne 'Unknown' |
    Group-Object Manufacturer |
    Sort-Object Count -Descending

# Display chart
Write-Host "`nManufacturer Distribution:" -ForegroundColor Cyan
$maxCount = ($manufacturers | Measure-Object Count -Maximum).Maximum

foreach ($mfg in $manufacturers) {
    $barLength = [Math]::Round(($mfg.Count / $maxCount) * 50)
    $bar = "█" * $barLength
    Write-Host ("{0,-30} {1,3} {2}" -f $mfg.Name, $mfg.Count, $bar) -ForegroundColor Green
}

# Percentage breakdown
Write-Host "`nPercentage Breakdown:" -ForegroundColor Cyan
$total = ($manufacturers | Measure-Object Count -Sum).Sum
foreach ($mfg in $manufacturers) {
    $percentage = [Math]::Round(($mfg.Count / $total) * 100, 1)
    Write-Host ("{0,-30} {1,5}%" -f $mfg.Name, $percentage)
}
```

---

### Example 3: Port Usage Analysis

**Identify most common open ports:**

```powershell
# Load scan
$devices = Get-Content "NetworkScan_*.json" | ConvertFrom-Json

# Flatten port list
$allPorts = $devices | ForEach-Object { $_.OpenPorts } | Group-Object | Sort-Object Count -Descending

Write-Host "`nMost Common Open Ports:" -ForegroundColor Cyan
$allPorts | Select-Object -First 10 | ForEach-Object {
    $portName = switch ($_.Name) {
        "80" { "HTTP" }
        "443" { "HTTPS" }
        "8080" { "HTTP Alt" }
        "8123" { "Home Assistant" }
        "8443" { "HTTPS Alt" }
        default { "Port $($_.Name)" }
    }
    Write-Host ("{0,-20} {1,3} devices" -f $portName, $_.Count)
}
```

---

## Next Steps

For more information:
- **[User Guide](USER_GUIDE.md)** - Detailed usage instructions
- **[Technical Reference](TECHNICAL_REFERENCE.md)** - Function documentation
- **[Main Documentation](NetworkDeviceScanner.md)** - Overview and quick reference

---

**Have a scenario not covered here?** The script's JSON output can be analyzed with any PowerShell commands or integrated with external systems using REST APIs, databases, or file exports.
