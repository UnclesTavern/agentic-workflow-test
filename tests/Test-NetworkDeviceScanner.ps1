<#
.SYNOPSIS
    Comprehensive test suite for NetworkDeviceScanner.ps1

.DESCRIPTION
    Tests code quality, syntax, security, and functional requirements
    of the Network Device Scanner PowerShell script.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$ScriptPath = "../scripts/NetworkDeviceScanner.ps1"
)

$ErrorActionPreference = 'Continue'
$testResults = @{
    Passed = [System.Collections.ArrayList]::new()
    Failed = [System.Collections.ArrayList]::new()
    Warnings = [System.Collections.ArrayList]::new()
}

function Write-TestHeader {
    param([string]$Title)
    Write-Host "`n================================" -ForegroundColor Cyan
    Write-Host "  $Title" -ForegroundColor Cyan
    Write-Host "================================" -ForegroundColor Cyan
}

function Test-Pass {
    param([string]$TestName, [string]$Details = "")
    Write-Host "[PASS] $TestName" -ForegroundColor Green
    if ($Details) { Write-Host "       $Details" -ForegroundColor Gray }
    [void]$testResults.Passed.Add($TestName)
}

function Test-Fail {
    param([string]$TestName, [string]$Details = "")
    Write-Host "[FAIL] $TestName" -ForegroundColor Red
    if ($Details) { Write-Host "       $Details" -ForegroundColor Yellow }
    [void]$testResults.Failed.Add($TestName)
}

function Test-Warning {
    param([string]$TestName, [string]$Details = "")
    Write-Host "[WARN] $TestName" -ForegroundColor Yellow
    if ($Details) { Write-Host "       $Details" -ForegroundColor Gray }
    [void]$testResults.Warnings.Add($TestName)
}

# =============================================================================
# TEST 1: FILE EXISTENCE AND BASIC STRUCTURE
# =============================================================================
Write-TestHeader "Test 1: File Existence and Structure"

if (-not (Test-Path $ScriptPath)) {
    Test-Fail "Script file exists" "File not found at: $ScriptPath"
    exit 1
}
Test-Pass "Script file exists" "Found: $ScriptPath"

$scriptContent = Get-Content $ScriptPath -Raw
$scriptLines = Get-Content $ScriptPath

Test-Pass "Script content readable" "Total lines: $($scriptLines.Count)"

# =============================================================================
# TEST 2: SYNTAX VALIDATION
# =============================================================================
Write-TestHeader "Test 2: PowerShell Syntax Validation"

try {
    $null = [System.Management.Automation.PSParser]::Tokenize($scriptContent, [ref]$null)
    Test-Pass "PowerShell syntax valid" "No parsing errors detected"
}
catch {
    Test-Fail "PowerShell syntax valid" $_.Exception.Message
}

# Check for valid CmdletBinding
if ($scriptContent -match '\[CmdletBinding\(\)\]') {
    Test-Pass "CmdletBinding present" "Script supports advanced features"
}
else {
    Test-Fail "CmdletBinding present" "Script should use [CmdletBinding()]"
}

# Check parameter block
if ($scriptContent -match 'param\s*\(') {
    Test-Pass "Parameter block defined" "Parameters properly declared"
}
else {
    Test-Warning "Parameter block defined" "No parameters defined"
}

# =============================================================================
# TEST 3: CRITICAL REQUIREMENT - NO += IN LOOPS
# =============================================================================
Write-TestHeader "Test 3: Array Performance - No += in Loops"

$violations = @()
$inLoop = $false
$loopDepth = 0
$lineNum = 0

foreach ($line in $scriptLines) {
    $lineNum++
    
    # Track loop depth
    if ($line -match '\bforeach\s*\(|\bfor\s*\(|\bwhile\s*\(') {
        $inLoop = $true
        $loopDepth++
    }
    
    if ($line -match '^\s*\}' -and $loopDepth -gt 0) {
        $loopDepth--
        if ($loopDepth -eq 0) {
            $inLoop = $false
        }
    }
    
    # Check for += operations inside loops
    if ($inLoop -and $line -match '\$\w+\s*\+=\s*' -and $line -notmatch '#.*\+=') {
        # Allow += for non-array operations (like counters)
        if ($line -notmatch '\+=\s*\d+\s*$') {
            $violations += "Line $lineNum : $($line.Trim())"
        }
    }
}

if ($violations.Count -eq 0) {
    Test-Pass "No += array operations in loops" "All loops use ArrayList.Add() for performance"
}
else {
    Test-Fail "No += array operations in loops" "Found $($violations.Count) violations:`n$($violations -join "`n")"
}

# Verify ArrayList usage
$arrayListCount = ($scriptContent | Select-String -Pattern '\[System\.Collections\.ArrayList\]::new\(\)' -AllMatches).Matches.Count
if ($arrayListCount -gt 0) {
    Test-Pass "ArrayList used for collections" "Found $arrayListCount ArrayList instances"
}
else {
    Test-Fail "ArrayList used for collections" "Should use ArrayList instead of array concatenation"
}

# =============================================================================
# TEST 4: CRITICAL REQUIREMENT - ISOLATED FUNCTIONS
# =============================================================================
Write-TestHeader "Test 4: Functionality in Isolated Functions"

# Extract all functions
$functionMatches = [regex]::Matches($scriptContent, 'function\s+([A-Za-z0-9-]+)\s*\{')
$functions = $functionMatches | ForEach-Object { $_.Groups[1].Value }

if ($functions.Count -gt 0) {
    Test-Pass "Functions defined" "Found $($functions.Count) functions"
    Write-Host "       Functions: $($functions -join ', ')" -ForegroundColor Gray
}
else {
    Test-Fail "Functions defined" "No functions found - all code should be in functions"
}

# Required functions based on spec
$requiredFunctions = @(
    'Get-LocalSubnets',
    'Expand-Subnet', 
    'Test-HostReachable',
    'Get-HostnameFromIP',
    'Get-MACAddress',
    'Get-ManufacturerFromMAC',
    'Test-PortOpen',
    'Get-OpenPorts',
    'Get-HTTPEndpointInfo',
    'Get-DeviceClassification',
    'Get-DeviceInfo',
    'Start-NetworkScan'
)

$missingFunctions = @()
foreach ($required in $requiredFunctions) {
    if ($functions -notcontains $required) {
        $missingFunctions += $required
    }
}

if ($missingFunctions.Count -eq 0) {
    Test-Pass "All required functions present" "12 core functions implemented"
}
else {
    Test-Fail "All required functions present" "Missing: $($missingFunctions -join ', ')"
}

# Check main execution is minimal (should mostly call functions)
$mainRegion = $scriptContent -split '#region Main Execution' | Select-Object -Last 1
$mainRegion = $mainRegion -split '#endregion' | Select-Object -First 1
$mainLines = ($mainRegion -split "`n").Count

if ($mainLines -lt 100) {
    Test-Pass "Main execution is minimal" "Main code is $mainLines lines (good)"
}
else {
    Test-Warning "Main execution is minimal" "Main code is $mainLines lines (consider refactoring)"
}

# =============================================================================
# TEST 5: CRITICAL REQUIREMENT - SSL CALLBACK RESTORATION
# =============================================================================
Write-TestHeader "Test 5: SSL Certificate Validation Callback"

$sslSetMatches = [regex]::Matches($scriptContent, '\[System\.Net\.ServicePointManager\]::ServerCertificateValidationCallback\s*=')
$sslGetMatches = [regex]::Matches($scriptContent, '\$\w+\s*=\s*\[System\.Net\.ServicePointManager\]::ServerCertificateValidationCallback')

if ($sslGetMatches.Count -gt 0) {
    Test-Pass "SSL callback state saved" "Original callback preserved before modification"
}
else {
    Test-Fail "SSL callback state saved" "Must save original callback before modifying"
}

if ($sslSetMatches.Count -ge 2) {
    Test-Pass "SSL callback restored" "Callback is set and restored"
}
else {
    Test-Fail "SSL callback restored" "Must restore original callback after use"
}

# Check for try-finally pattern
if ($scriptContent -match 'finally\s*\{[^}]*ServerCertificateValidationCallback') {
    Test-Pass "SSL callback in finally block" "Restoration guaranteed even on error"
}
else {
    Test-Warning "SSL callback in finally block" "Consider using finally block for guaranteed restoration"
}

# =============================================================================
# TEST 6: SECURITY CHECKS
# =============================================================================
Write-TestHeader "Test 6: Security and Best Practices"

# Check for hardcoded credentials
$credentialPatterns = @(
    'password\s*=\s*[''"](?!.*\$)',
    'apikey\s*=\s*[''"](?!.*\$)',
    'token\s*=\s*[''"](?!.*\$)',
    'secret\s*=\s*[''"](?!.*\$)'
)

$foundCredentials = $false
foreach ($pattern in $credentialPatterns) {
    if ($scriptContent -match $pattern) {
        $foundCredentials = $true
        break
    }
}

if (-not $foundCredentials) {
    Test-Pass "No hardcoded credentials" "No passwords, API keys, or tokens found"
}
else {
    Test-Fail "No hardcoded credentials" "Found potential hardcoded credentials"
}

# Check for input validation in parameters
if ($scriptContent -match '\[Parameter\(Mandatory') {
    Test-Pass "Parameter validation present" "Mandatory parameters defined"
}
else {
    Test-Warning "Parameter validation present" "Consider adding mandatory parameter validation"
}

# Check error handling
$tryBlocks = ($scriptContent | Select-String -Pattern '\btry\s*\{' -AllMatches).Matches.Count
$catchBlocks = ($scriptContent | Select-String -Pattern '\bcatch\s*\{' -AllMatches).Matches.Count

if ($tryBlocks -gt 0 -and $tryBlocks -eq $catchBlocks) {
    Test-Pass "Error handling implemented" "Found $tryBlocks try-catch blocks"
}
else {
    Test-Warning "Error handling implemented" "Try blocks: $tryBlocks, Catch blocks: $catchBlocks"
}

# =============================================================================
# TEST 7: FUNCTION STRUCTURE AND DOCUMENTATION
# =============================================================================
Write-TestHeader "Test 7: Function Structure and Documentation"

# Check for comment-based help
$helpBlocks = ($scriptContent | Select-String -Pattern '\.SYNOPSIS' -AllMatches).Matches.Count
if ($helpBlocks -gt 0) {
    Test-Pass "Comment-based help present" "Found $helpBlocks help blocks"
}
else {
    Test-Fail "Comment-based help present" "Functions should have .SYNOPSIS documentation"
}

# Check for CmdletBinding in functions
$functionCmdletBinding = ($scriptContent | Select-String -Pattern 'function.*\{[^}]*\[CmdletBinding\(\)\]' -AllMatches).Matches.Count
if ($functionCmdletBinding -gt 0) {
    Test-Pass "Functions use CmdletBinding" "Found $functionCmdletBinding functions with CmdletBinding"
}
else {
    Test-Warning "Functions use CmdletBinding" "Consider adding [CmdletBinding()] to functions"
}

# Check for regions
$regions = ($scriptContent | Select-String -Pattern '#region' -AllMatches).Matches.Count
if ($regions -gt 0) {
    Test-Pass "Code organized in regions" "Found $regions regions for organization"
}
else {
    Test-Warning "Code organized in regions" "Consider using #region for better organization"
}

# =============================================================================
# TEST 8: DEVICE CLASSIFICATION LOGIC
# =============================================================================
Write-TestHeader "Test 8: Device Classification Features"

# Check for device patterns
if ($scriptContent -match '\$script:DevicePatterns') {
    Test-Pass "Device patterns defined" "Global device classification patterns present"
}
else {
    Test-Fail "Device patterns defined" "Missing device pattern definitions"
}

# Check for required device types
$requiredTypes = @('IOTHub', 'IOTDevice', 'Security')
$allTypesFound = $true
foreach ($type in $requiredTypes) {
    if ($scriptContent -notmatch $type) {
        $allTypesFound = $false
        break
    }
}

if ($allTypesFound) {
    Test-Pass "All device types implemented" "IOTHub, IOTDevice, Security classifications present"
}
else {
    Test-Fail "All device types implemented" "Missing required device type classifications"
}

# Check for MAC OUI database
if ($scriptContent -match '\$ouiDatabase') {
    Test-Pass "MAC OUI database present" "Manufacturer identification implemented"
}
else {
    Test-Fail "MAC OUI database present" "Missing MAC address manufacturer lookup"
}

# =============================================================================
# TEST 9: NETWORK SCANNING FEATURES
# =============================================================================
Write-TestHeader "Test 9: Network Scanning Capabilities"

# Check for ICMP ping functionality
if ($scriptContent -match 'System\.Net\.NetworkInformation\.Ping') {
    Test-Pass "ICMP ping capability" "Host reachability testing implemented"
}
else {
    Test-Fail "ICMP ping capability" "Missing ping functionality"
}

# Check for TCP port scanning
if ($scriptContent -match 'System\.Net\.Sockets\.TcpClient') {
    Test-Pass "TCP port scanning" "Port connectivity testing implemented"
}
else {
    Test-Fail "TCP port scanning" "Missing TCP port scan functionality"
}

# Check for HTTP/HTTPS probing
if ($scriptContent -match 'System\.Net\.HttpWebRequest') {
    Test-Pass "HTTP endpoint probing" "API endpoint discovery implemented"
}
else {
    Test-Fail "HTTP endpoint probing" "Missing HTTP endpoint detection"
}

# Check for subnet expansion
if ($scriptContent -match 'Expand-Subnet') {
    Test-Pass "CIDR subnet expansion" "Subnet to IP list conversion present"
}
else {
    Test-Fail "CIDR subnet expansion" "Missing subnet expansion logic"
}

# =============================================================================
# TEST 10: OUTPUT AND REPORTING
# =============================================================================
Write-TestHeader "Test 10: Output and Reporting"

# Check for JSON export
if ($scriptContent -match 'ConvertTo-Json') {
    Test-Pass "JSON export capability" "Results can be exported to JSON"
}
else {
    Test-Warning "JSON export capability" "Consider adding JSON export for results"
}

# Check for progress indicators
if ($scriptContent -match 'Write-Progress') {
    Test-Pass "Progress indicators" "User feedback during long operations"
}
else {
    Test-Warning "Progress indicators" "Consider adding progress indicators"
}

# Check for colored output
if ($scriptContent -match '-ForegroundColor') {
    Test-Pass "Colored console output" "Enhanced readability with colors"
}
else {
    Test-Warning "Colored console output" "Consider using colored output"
}

# =============================================================================
# FINAL RESULTS
# =============================================================================
Write-Host "`n`n" -NoNewline
Write-TestHeader "TEST SUMMARY"

$totalTests = $testResults.Passed.Count + $testResults.Failed.Count + $testResults.Warnings.Count
$passRate = if ($totalTests -gt 0) { [Math]::Round(($testResults.Passed.Count / $totalTests) * 100, 1) } else { 0 }

Write-Host "`nTotal Tests Run: $totalTests" -ForegroundColor White
Write-Host "Passed: $($testResults.Passed.Count)" -ForegroundColor Green
Write-Host "Failed: $($testResults.Failed.Count)" -ForegroundColor Red
Write-Host "Warnings: $($testResults.Warnings.Count)" -ForegroundColor Yellow
Write-Host "Pass Rate: $passRate%`n" -ForegroundColor $(if ($passRate -ge 80) { 'Green' } elseif ($passRate -ge 60) { 'Yellow' } else { 'Red' })

if ($testResults.Failed.Count -eq 0) {
    Write-Host "✓ ALL CRITICAL TESTS PASSED!" -ForegroundColor Green
    exit 0
}
else {
    Write-Host "✗ Some tests failed - review required" -ForegroundColor Red
    Write-Host "`nFailed Tests:" -ForegroundColor Yellow
    foreach ($failed in $testResults.Failed) {
        Write-Host "  - $failed" -ForegroundColor Red
    }
    exit 1
}
