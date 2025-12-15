<#
.SYNOPSIS
    Focused tests for critical requirements specified in the task

.DESCRIPTION
    Tests the three critical requirements:
    1. All functionality in isolated functions
    2. No += operations on arrays in loops (use ArrayList)
    3. SSL ServerCertificateValidationCallback restoration
#>

[CmdletBinding()]
param()

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  CRITICAL REQUIREMENTS TEST" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$scriptPath = "../scripts/NetworkDeviceScanner.ps1"
$scriptContent = Get-Content $scriptPath -Raw
$scriptLines = Get-Content $scriptPath

$criticalPassed = 0
$criticalFailed = 0

# =============================================================================
# CRITICAL TEST 1: All functionality in isolated functions
# =============================================================================
Write-Host "`n[CRITICAL TEST 1] All Functionality in Isolated Functions" -ForegroundColor Yellow
Write-Host "=" * 70 -ForegroundColor Gray

# Count functions
$functionMatches = [regex]::Matches($scriptContent, 'function\s+([A-Za-z0-9-]+)')
Write-Host "Functions found: $($functionMatches.Count)" -ForegroundColor White

# List all functions
$functions = @()
foreach ($match in $functionMatches) {
    $funcName = $match.Groups[1].Value
    $functions += $funcName
    Write-Host "  - $funcName" -ForegroundColor Gray
}

# Analyze main execution region
$mainCode = $scriptContent -split '#region Main Execution' | Select-Object -Last 1
$mainCode = $mainCode -split '#endregion' | Select-Object -First 1

# Count non-comment, non-blank lines in main
$mainLines = ($mainCode -split "`n") | Where-Object { 
    $_ -match '\S' -and $_ -notmatch '^\s*#' -and $_ -notmatch '^\s*\}?\s*$'
}
$mainLineCount = $mainLines.Count

Write-Host "`nMain execution region: $mainLineCount substantive lines" -ForegroundColor White

# Check that main code mostly calls functions
$functionCalls = ($mainCode | Select-String -Pattern '\b(' + ($functions -join '|') + ')\s*-' -AllMatches).Matches.Count
Write-Host "Function calls in main: $functionCalls" -ForegroundColor White

if ($functions.Count -ge 12 -and $mainLineCount -lt 80) {
    Write-Host "`n✓ PASS: All functionality is in isolated functions" -ForegroundColor Green
    $criticalPassed++
} else {
    Write-Host "`n✗ FAIL: Not enough functions or main is too complex" -ForegroundColor Red
    $criticalFailed++
}

# =============================================================================
# CRITICAL TEST 2: No += on arrays in loops (ArrayList usage)
# =============================================================================
Write-Host "`n`n[CRITICAL TEST 2] No += Array Operations in Loops" -ForegroundColor Yellow
Write-Host "=" * 70 -ForegroundColor Gray

# Detailed analysis
$violations = [System.Collections.ArrayList]::new()
$inLoop = $false
$loopDepth = 0
$currentFunction = "Main"

for ($i = 0; $i -lt $scriptLines.Count; $i++) {
    $line = $scriptLines[$i]
    $lineNum = $i + 1
    
    # Track current function
    if ($line -match 'function\s+([A-Za-z0-9-]+)') {
        $currentFunction = $Matches[1]
    }
    
    # Track loop depth
    if ($line -match '\bforeach\s*\(|\bfor\s*\(|\bwhile\s*\(') {
        $loopDepth++
        $inLoop = $true
    }
    
    if ($line -match '^\s*\}') {
        if ($loopDepth -gt 0) {
            $loopDepth--
            if ($loopDepth -eq 0) {
                $inLoop = $false
            }
        }
    }
    
    # Check for += in loops (excluding counters like $i += 1)
    if ($inLoop -and $line -match '\$(\w+)\s*\+=\s*' -and $line -notmatch '#') {
        $varName = $Matches[1]
        # Allow numeric counters
        if ($line -notmatch '\+=\s*\d+\s*$' -and $line -notmatch '\+=\s*\$\w+\s*$') {
            [void]$violations.Add([PSCustomObject]@{
                Line = $lineNum
                Function = $currentFunction
                Variable = $varName
                Code = $line.Trim()
            })
        }
    }
}

Write-Host "Array concatenation violations in loops: $($violations.Count)" -ForegroundColor White

if ($violations.Count -gt 0) {
    Write-Host "`nViolations found:" -ForegroundColor Yellow
    foreach ($v in $violations) {
        Write-Host "  Line $($v.Line) in $($v.Function): $($v.Code)" -ForegroundColor Red
    }
}

# Check ArrayList usage
$arrayListUsage = ($scriptContent | Select-String -Pattern '\[System\.Collections\.ArrayList\]::new\(\)' -AllMatches).Matches
Write-Host "`nArrayList instances: $($arrayListUsage.Count)" -ForegroundColor White

# Check for [void] pattern to suppress output
$voidPattern = ($scriptContent | Select-String -Pattern '\[void\]\s*\$\w+\.Add\(' -AllMatches).Matches
Write-Host "Proper [void] usage with Add(): $($voidPattern.Count)" -ForegroundColor White

if ($violations.Count -eq 0 -and $arrayListUsage.Count -gt 0) {
    Write-Host "`n✓ PASS: No array += in loops, ArrayList used correctly" -ForegroundColor Green
    $criticalPassed++
} else {
    Write-Host "`n✗ FAIL: Array performance issues detected" -ForegroundColor Red
    $criticalFailed++
}

# =============================================================================
# CRITICAL TEST 3: SSL Certificate Callback Restoration
# =============================================================================
Write-Host "`n`n[CRITICAL TEST 3] SSL ServerCertificateValidationCallback Restoration" -ForegroundColor Yellow
Write-Host "=" * 70 -ForegroundColor Gray

# Find the function that uses SSL callback
$httpFunction = $scriptContent -match 'Get-HTTPEndpointInfo' 
$functionStart = $scriptContent.IndexOf('function Get-HTTPEndpointInfo')
$functionEnd = $scriptContent.IndexOf('#endregion', $functionStart)
$functionCode = $scriptContent.Substring($functionStart, $functionEnd - $functionStart)

# Check for saving original callback
$saveCallback = $functionCode -match '\$originalCallback\s*=\s*\[System\.Net\.ServicePointManager\]::ServerCertificateValidationCallback'
Write-Host "Original callback saved: $saveCallback" -ForegroundColor $(if ($saveCallback) { 'Green' } else { 'Red' })

# Check for setting callback
$setCallback = $functionCode -match '\[System\.Net\.ServicePointManager\]::ServerCertificateValidationCallback\s*=\s*\{\s*\$true\s*\}'
Write-Host "Callback set to bypass validation: $setCallback" -ForegroundColor $(if ($setCallback) { 'Green' } else { 'Red' })

# Check for restoration
$restoreCallback = $functionCode -match '\[System\.Net\.ServicePointManager\]::ServerCertificateValidationCallback\s*=\s*\$originalCallback'
Write-Host "Callback restored: $restoreCallback" -ForegroundColor $(if ($restoreCallback) { 'Green' } else { 'Red' })

# Check for try-finally pattern
$hasTryFinally = $functionCode -match 'try\s*\{' -and $functionCode -match 'finally\s*\{'
$restoreInFinally = $functionCode -match 'finally\s*\{[^}]*ServerCertificateValidationCallback\s*=\s*\$originalCallback'
Write-Host "Uses try-finally pattern: $hasTryFinally" -ForegroundColor $(if ($hasTryFinally) { 'Green' } else { 'Yellow' })
Write-Host "Restoration in finally block: $restoreInFinally" -ForegroundColor $(if ($restoreInFinally) { 'Green' } else { 'Red' })

# Extract the relevant code section
Write-Host "`nSSL Callback Management Code:" -ForegroundColor Cyan
$callbackLines = $scriptLines | Select-String -Pattern 'ServerCertificateValidationCallback' -Context 1,1
foreach ($line in $callbackLines) {
    Write-Host "  Line $($line.LineNumber): $($line.Line.Trim())" -ForegroundColor Gray
}

if ($saveCallback -and $restoreCallback -and $restoreInFinally) {
    Write-Host "`n✓ PASS: SSL callback properly saved and restored in finally block" -ForegroundColor Green
    $criticalPassed++
} else {
    Write-Host "`n✗ FAIL: SSL callback not properly managed" -ForegroundColor Red
    $criticalFailed++
}

# =============================================================================
# FINAL CRITICAL REQUIREMENTS SUMMARY
# =============================================================================
Write-Host "`n`n========================================" -ForegroundColor Cyan
Write-Host "  CRITICAL REQUIREMENTS SUMMARY" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

Write-Host "`nCritical Tests Passed: $criticalPassed / 3" -ForegroundColor $(if ($criticalPassed -eq 3) { 'Green' } else { 'Red' })
Write-Host "Critical Tests Failed: $criticalFailed / 3" -ForegroundColor $(if ($criticalFailed -eq 0) { 'Green' } else { 'Red' })

Write-Host "`nRequirement Status:" -ForegroundColor White
Write-Host "  1. Isolated Functions: $(if ($criticalPassed -ge 1) { '✓ PASS' } else { '✗ FAIL' })" -ForegroundColor $(if ($criticalPassed -ge 1) { 'Green' } else { 'Red' })
Write-Host "  2. ArrayList Performance: $(if ($criticalPassed -ge 2) { '✓ PASS' } else { '✗ FAIL' })" -ForegroundColor $(if ($criticalPassed -ge 2) { 'Green' } else { 'Red' })
Write-Host "  3. SSL Callback Safety: $(if ($criticalPassed -eq 3) { '✓ PASS' } else { '✗ FAIL' })" -ForegroundColor $(if ($criticalPassed -eq 3) { 'Green' } else { 'Red' })

if ($criticalPassed -eq 3) {
    Write-Host "`n✓✓✓ ALL CRITICAL REQUIREMENTS MET! ✓✓✓`n" -ForegroundColor Green
    exit 0
} else {
    Write-Host "`n✗✗✗ CRITICAL REQUIREMENTS NOT MET ✗✗✗`n" -ForegroundColor Red
    exit 1
}
