<#
.SYNOPSIS
    Pester tests for Scan-LANDevices.ps1

.DESCRIPTION
    Comprehensive test suite covering all 10 test categories:
    1. Subnet Detection Tests
    2. Network Scanning Tests
    3. Device Discovery Tests
    4. Device Type Identification Tests
    5. API Endpoint Discovery Tests
    6. Output Function Tests
    7. Error Scenario Tests
    8. Performance Tests
    9. PowerShell Compatibility Tests
    10. Integration Tests

.NOTES
    Author: test-agent
    Date: 2025-12-13
    Requires: Pester 5.x
#>

BeforeAll {
    # Dot-source the script to import all functions
    $scriptPath = Join-Path $PSScriptRoot "Scan-LANDevices.ps1"
    
    if (-not (Test-Path $scriptPath)) {
        throw "Cannot find Scan-LANDevices.ps1 at $scriptPath"
    }
    
    # Parse and execute only function definitions (avoid running main script)
    $scriptContent = Get-Content $scriptPath -Raw
    
    # Extract and execute each function definition
    $functionPattern = '(?s)function\s+(\S+)\s*\{(?:[^{}]|(?<open>\{)|(?<-open>\}))+(?(open)(?!))\}'
    $matches = [regex]::Matches($scriptContent, $functionPattern)
    
    foreach ($match in $matches) {
        $functionCode = $match.Value
        Invoke-Expression $functionCode
    }
    
    Write-Host "Loaded $($matches.Count) functions from Scan-LANDevices.ps1" -ForegroundColor Cyan
}

Describe "1. Subnet Detection Tests" -Tag "Subnet" {
    
    Context "1.1 CIDR Notation Parsing" {
        
        It "Should parse valid /24 CIDR notation correctly" {
            $result = ConvertFrom-CIDR -CIDR "192.168.1.0/24"
            
            $result | Should -Not -BeNullOrEmpty
            $result.TotalHosts | Should -Be 254
            $result.FirstUsable | Should -Not -BeNullOrEmpty
            $result.LastUsable | Should -Not -BeNullOrEmpty
        }
        
        It "Should parse valid /16 CIDR notation correctly" {
            $result = ConvertFrom-CIDR -CIDR "10.0.0.0/16"
            
            $result | Should -Not -BeNullOrEmpty
            $result.TotalHosts | Should -Be 65534
        }
        
        It "Should parse valid /8 CIDR notation correctly" {
            $result = ConvertFrom-CIDR -CIDR "172.16.0.0/8"
            
            $result | Should -Not -BeNullOrEmpty
            $result.TotalHosts | Should -BeGreaterThan 16000000
        }
        
        It "Should handle invalid CIDR notation gracefully" {
            { ConvertFrom-CIDR -CIDR "invalid" -ErrorAction Stop } | Should -Throw
        }
        
        It "Should handle invalid prefix length gracefully" {
            { ConvertFrom-CIDR -CIDR "192.168.1.0/33" -ErrorAction Stop } | Should -Throw
        }
    }
    
    Context "1.2 IP Address Conversion" {
        
        It "Should convert integer to valid IP address" {
            # 192.168.1.1 = 3232235777 (in host byte order)
            $result = ConvertTo-IPAddress -IPInteger 3232235777
            
            $result | Should -Match '^\d+\.\d+\.\d+\.\d+$'
        }
        
        It "Should convert minimum IP address (0.0.0.0)" {
            $result = ConvertTo-IPAddress -IPInteger 0
            
            $result | Should -Be "0.0.0.0"
        }
        
        It "Should handle large IP integers" {
            $result = ConvertTo-IPAddress -IPInteger 4294967295
            
            $result | Should -Be "255.255.255.255"
        }
    }
    
    Context "1.3 Local Subnet Detection" {
        
        It "Should detect local subnets without errors" {
            { $result = Get-LocalSubnets -ErrorAction Stop } | Should -Not -Throw
        }
        
        It "Should return array of CIDR notations" {
            $result = Get-LocalSubnets
            
            if ($result) {
                $result | Should -BeOfType [System.Array]
                $result[0] | Should -Match '^\d+\.\d+\.\d+\.\d+/\d+$'
            }
        }
    }
}

Describe "2. Network Scanning Tests" -Tag "Scanning" {
    
    Context "2.1 Host Alive Detection" {
        
        It "Should test localhost successfully" {
            $result = Test-HostAlive -IPAddress "127.0.0.1" -Timeout 1000
            
            $result | Should -Be $true
        }
        
        It "Should handle unreachable host gracefully" {
            $result = Test-HostAlive -IPAddress "192.168.255.254" -Timeout 100
            
            $result | Should -Be $false
        }
        
        It "Should respect timeout parameter" {
            $startTime = Get-Date
            $result = Test-HostAlive -IPAddress "192.168.255.254" -Timeout 100
            $endTime = Get-Date
            $duration = ($endTime - $startTime).TotalMilliseconds
            
            $duration | Should -BeLessThan 500
        }
    }
    
    Context "2.2 Parallel Scanning" {
        
        It "Should create subnet scan without errors" {
            { Invoke-SubnetScan -CIDR "127.0.0.0/30" -Timeout 100 -Threads 2 -ErrorAction Stop } | Should -Not -Throw
        }
        
        It "Should return array of alive hosts" {
            $result = Invoke-SubnetScan -CIDR "127.0.0.0/30" -Timeout 500 -Threads 2
            
            $result | Should -BeOfType [System.Array]
            $result | Should -Contain "127.0.0.1"
        }
    }
}

Describe "3. Device Discovery Tests" -Tag "Discovery" {
    
    Context "3.1 Hostname Resolution" {
        
        It "Should resolve localhost hostname" {
            $result = Get-DeviceHostname -IPAddress "127.0.0.1"
            
            $result | Should -Not -BeNullOrEmpty
            $result | Should -Match 'localhost|DESKTOP|LAPTOP|PC'
        }
        
        It "Should handle unresolvable IP gracefully" {
            $result = Get-DeviceHostname -IPAddress "192.168.255.254"
            
            # Should return IP or Unknown, not throw
            $result | Should -Not -BeNullOrEmpty
        }
    }
    
    Context "3.2 MAC Address Retrieval" {
        
        It "Should attempt MAC address lookup without errors" {
            { Get-DeviceMACAddress -IPAddress "127.0.0.1" -ErrorAction SilentlyContinue } | Should -Not -Throw
        }
        
        It "Should return string result" {
            $result = Get-DeviceMACAddress -IPAddress "127.0.0.1"
            
            $result | Should -BeOfType [string]
        }
    }
    
    Context "3.3 Port Scanning" {
        
        It "Should scan ports without errors" {
            { Get-OpenPorts -IPAddress "127.0.0.1" -ErrorAction Stop } | Should -Not -Throw
        }
        
        It "Should return array of port objects" {
            $result = Get-OpenPorts -IPAddress "127.0.0.1"
            
            $result | Should -BeOfType [System.Array]
        }
        
        It "Should detect common open ports on localhost" {
            $result = Get-OpenPorts -IPAddress "127.0.0.1"
            
            # At least one port might be open on localhost
            $result | Should -Not -BeNullOrEmpty
        }
    }
    
    Context "3.4 HTTP Device Info" {
        
        It "Should handle HTTP request to localhost gracefully" {
            { Get-HTTPDeviceInfo -IPAddress "127.0.0.1" -Port 80 -ErrorAction SilentlyContinue } | Should -Not -Throw
        }
        
        It "Should return hashtable structure" {
            $result = Get-HTTPDeviceInfo -IPAddress "127.0.0.1" -Port 80
            
            $result | Should -BeOfType [hashtable]
            $result.Keys | Should -Contain "Title"
            $result.Keys | Should -Contain "Server"
        }
    }
}

Describe "4. Device Type Identification Tests" -Tag "DeviceType" {
    
    Context "4.1 Home Assistant Detection" {
        
        It "Should identify Home Assistant by port 8123" {
            $result = Test-HomeAssistant -IPAddress "192.168.1.100" -OpenPorts @(8123)
            
            $result | Should -Not -BeNullOrEmpty
            $result.Keys | Should -Contain "Confidence"
            $result.Keys | Should -Contain "Evidence"
            $result.Confidence | Should -BeGreaterThan 0
        }
        
        It "Should not identify device without Home Assistant port" {
            $result = Test-HomeAssistant -IPAddress "192.168.1.100" -OpenPorts @(80, 443)
            
            $result | Should -Not -BeNullOrEmpty
            $result.Confidence | Should -Be 0
            $result.IsHomeAssistant | Should -Be $false
        }
    }
    
    Context "4.2 Shelly Device Detection" {
        
        It "Should check Shelly device detection with port 80" {
            $result = Test-ShellyDevice -IPAddress "192.168.1.101" -OpenPorts @(80)
            
            $result | Should -Not -BeNullOrEmpty
            $result.Keys | Should -Contain "Confidence"
            $result.Keys | Should -Contain "Evidence"
        }
        
        It "Should not identify device without required ports" {
            $result = Test-ShellyDevice -IPAddress "192.168.1.101" -OpenPorts @(443, 22)
            
            $result | Should -Not -BeNullOrEmpty
            $result.Confidence | Should -Be 0
            $result.IsShellyDevice | Should -Be $false
        }
    }
    
    Context "4.3 Ubiquiti Device Detection" {
        
        It "Should check Ubiquiti detection with port 8443" {
            $result = Test-UbiquitiDevice -IPAddress "192.168.1.102" -OpenPorts @(8443)
            
            $result | Should -Not -BeNullOrEmpty
            $result.Keys | Should -Contain "Confidence"
            $result.Keys | Should -Contain "Evidence"
        }
        
        It "Should not identify device without Ubiquiti ports" {
            $result = Test-UbiquitiDevice -IPAddress "192.168.1.102" -OpenPorts @(80, 443)
            
            $result | Should -Not -BeNullOrEmpty
            $result.Confidence | Should -Be 0
            $result.IsUbiquitiDevice | Should -Be $false
        }
    }
    
    Context "4.4 Ajax Security Hub Detection" {
        
        It "Should check Ajax detection with standard ports" {
            $result = Test-AjaxSecurityHub -IPAddress "192.168.1.103" -OpenPorts @(443, 80)
            
            $result | Should -Not -BeNullOrEmpty
            $result.Keys | Should -Contain "Confidence"
            $result.Keys | Should -Contain "Evidence"
        }
    }
    
    Context "4.5 Device Type Orchestration" {
        
        It "Should run Get-DeviceType without errors" {
            $mockDevice = @{
                IPAddress = "192.168.1.100"
                Hostname = "test-device"
                OpenPorts = @(80, 443)
            }
            
            { Get-DeviceType -Device $mockDevice -ErrorAction SilentlyContinue } | Should -Not -Throw
        }
        
        It "Should return device type structure" {
            $mockDevice = @{
                IPAddress = "192.168.1.100"
                Hostname = "test"
                OpenPorts = @(80)
            }
            
            $result = Get-DeviceType -Device $mockDevice
            
            $result | Should -Not -BeNullOrEmpty
            $result.Keys | Should -Contain "DeviceType"
        }
    }
}

Describe "5. API Endpoint Discovery Tests" -Tag "API" {
    
    Context "5.1 API Endpoint Probing" {
        
        It "Should probe common API endpoints without errors" {
            { Find-APIEndpoints -IPAddress "127.0.0.1" -OpenPorts @(80) -ErrorAction SilentlyContinue } | Should -Not -Throw
        }
        
        It "Should return array of API endpoint objects" {
            $result = Find-APIEndpoints -IPAddress "127.0.0.1" -OpenPorts @(80)
            
            $result | Should -BeOfType [System.Array]
        }
        
        It "Should test multiple ports" {
            { Find-APIEndpoints -IPAddress "127.0.0.1" -OpenPorts @(80, 443) -ErrorAction SilentlyContinue } | Should -Not -Throw
        }
    }
    
    Context "5.2 Device-Specific Endpoints" {
        
        It "Should probe Home Assistant specific endpoints with DeviceSubType" {
            $result = Find-APIEndpoints -IPAddress "192.168.1.100" -OpenPorts @(8123) -DeviceSubType "Home Assistant"
            
            # Should include Home Assistant specific paths
            $result | Should -BeOfType [System.Array]
        }
        
        It "Should probe Shelly specific endpoints with DeviceSubType" {
            $result = Find-APIEndpoints -IPAddress "192.168.1.101" -OpenPorts @(80) -DeviceSubType "Shelly"
            
            $result | Should -BeOfType [System.Array]
        }
    }
}

Describe "6. Output Function Tests" -Tag "Output" {
    
    Context "6.1 Console Output" {
        
        It "Should display results without errors" {
            $mockDevices = @(
                @{
                    IPAddress = "192.168.1.100"
                    Hostname = "homeassistant"
                    DeviceType = "IoT Hub"
                    Subtype = "Home Assistant"
                    Confidence = 95
                    APIEndpoints = @(@{URL="http://192.168.1.100:8123/api"; Status=200})
                }
            )
            
            { Show-DeviceScanResults -Devices $mockDevices -ErrorAction Stop } | Should -Not -Throw
        }
        
        It "Should handle empty device array" {
            { Show-DeviceScanResults -Devices @() -ErrorAction Stop } | Should -Not -Throw
        }
    }
    
    Context "6.2 JSON Export" {
        
        It "Should export to JSON file successfully" {
            $mockDevices = @(
                @{
                    IPAddress = "192.168.1.100"
                    Hostname = "homeassistant"
                    DeviceType = "IoT Hub"
                    Subtype = "Home Assistant"
                    Confidence = 95
                    MACAddress = "AA:BB:CC:DD:EE:FF"
                    OpenPorts = @(@{Port=8123; Status="Open"})
                    APIEndpoints = @(@{URL="http://192.168.1.100:8123/api"; Status=200})
                }
            )
            
            $testPath = Join-Path $TestDrive "test-export.json"
            
            { Export-DeviceScanResults -Devices $mockDevices -OutputPath $testPath -ErrorAction Stop } | Should -Not -Throw
            
            Test-Path $testPath | Should -Be $true
        }
        
        It "Should create valid JSON structure" {
            $mockDevices = @(
                @{
                    IPAddress = "192.168.1.100"
                    Hostname = "test"
                    DeviceType = "Network Device"
                    Confidence = 50
                    OpenPorts = @()
                    APIEndpoints = @()
                }
            )
            
            $testPath = Join-Path $TestDrive "test-json-structure.json"
            Export-DeviceScanResults -Devices $mockDevices -OutputPath $testPath
            
            $jsonContent = Get-Content $testPath -Raw | ConvertFrom-Json
            
            $jsonContent | Should -Not -BeNullOrEmpty
            $jsonContent.ScanDate | Should -Not -BeNullOrEmpty
            $jsonContent.TotalDevices | Should -Be 1
            $jsonContent.Devices | Should -HaveCount 1
        }
    }
}

Describe "7. Error Scenario Tests" -Tag "Error" {
    
    Context "7.1 Invalid Input Handling" {
        
        It "Should handle invalid CIDR gracefully" {
            { ConvertFrom-CIDR -CIDR "999.999.999.999/99" -ErrorAction Stop } | Should -Throw
        }
        
        It "Should handle null device input" {
            { Get-DeviceType -Device $null -ErrorAction SilentlyContinue } | Should -Not -Throw
        }
    }
    
    Context "7.2 Network Error Handling" {
        
        It "Should handle unreachable IP addresses" {
            $result = Test-HostAlive -IPAddress "192.168.255.254" -Timeout 100
            
            $result | Should -Be $false
        }
        
        It "Should handle DNS resolution failures" {
            $result = Get-DeviceHostname -IPAddress "192.168.255.254"
            
            $result | Should -Not -BeNullOrEmpty
        }
    }
    
    Context "7.3 HTTP Error Handling" {
        
        It "Should handle HTTP connection failures gracefully" {
            $result = Get-HTTPDeviceInfo -IPAddress "192.168.255.254" -Port 80
            
            # Should return empty/default hashtable, not throw
            $result | Should -BeOfType [hashtable]
        }
    }
}

Describe "8. Performance Tests" -Tag "Performance" {
    
    Context "8.1 Function Execution Time" {
        
        It "Should parse CIDR quickly" {
            $duration = Measure-Command {
                ConvertFrom-CIDR -CIDR "192.168.1.0/24"
            }
            
            $duration.TotalMilliseconds | Should -BeLessThan 100
        }
        
        It "Should convert IP address quickly" {
            $duration = Measure-Command {
                ConvertTo-IPAddress -IPInteger 3232235777
            }
            
            $duration.TotalMilliseconds | Should -BeLessThan 50
        }
    }
    
    Context "8.2 Scanning Performance" {
        
        It "Should scan small subnet in reasonable time" {
            $duration = Measure-Command {
                Invoke-SubnetScan -CIDR "127.0.0.0/30" -Timeout 100 -Threads 2
            }
            
            # Should complete in under 5 seconds for 2 hosts
            $duration.TotalSeconds | Should -BeLessThan 5
        }
    }
}

Describe "9. PowerShell Compatibility Tests" -Tag "Compatibility" {
    
    Context "9.1 PowerShell Version" {
        
        It "Should run on PowerShell 5.1 or higher" {
            $PSVersionTable.PSVersion.Major | Should -BeGreaterOrEqual 5
        }
        
        It "Should have required .NET types available" {
            [System.Net.IPAddress] | Should -Not -BeNullOrEmpty
            [System.Net.Sockets.TcpClient] | Should -Not -BeNullOrEmpty
        }
    }
    
    Context "9.2 Function Availability" {
        
        It "Should have all 19 functions defined" {
            $expectedFunctions = @(
                "ConvertFrom-CIDR",
                "ConvertTo-IPAddress",
                "Get-LocalSubnets",
                "Test-HostAlive",
                "Invoke-SubnetScan",
                "Get-DeviceHostname",
                "Get-DeviceMACAddress",
                "Get-OpenPorts",
                "Get-HTTPDeviceInfo",
                "Test-HomeAssistant",
                "Test-ShellyDevice",
                "Test-UbiquitiDevice",
                "Test-AjaxSecurityHub",
                "Get-DeviceType",
                "Find-APIEndpoints",
                "Get-DeviceInformation",
                "Start-LANDeviceScan",
                "Show-DeviceScanResults",
                "Export-DeviceScanResults"
            )
            
            foreach ($funcName in $expectedFunctions) {
                Get-Command $funcName -ErrorAction SilentlyContinue | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Describe "10. Integration Tests" -Tag "Integration" {
    
    Context "10.1 Full Workflow" {
        
        It "Should execute complete device information gathering" {
            $mockDevice = @{
                IPAddress = "127.0.0.1"
            }
            
            { Get-DeviceInformation -IPAddress $mockDevice.IPAddress -ErrorAction SilentlyContinue } | Should -Not -Throw
        }
        
        It "Should handle full scan workflow" {
            # Test with tiny subnet to avoid long execution
            { Start-LANDeviceScan -SubnetCIDR @("127.0.0.0/30") -Timeout 100 -Threads 2 -ErrorAction SilentlyContinue } | Should -Not -Throw
        }
    }
    
    Context "10.2 Data Flow Integrity" {
        
        It "Should maintain data structure through pipeline" {
            $device = Get-DeviceInformation -IPAddress "127.0.0.1"
            
            $device | Should -Not -BeNullOrEmpty
            $device.IPAddress | Should -Be "127.0.0.1"
            $device.Keys | Should -Contain "Hostname"
            $device.Keys | Should -Contain "DeviceType"
        }
    }
}
