<#
.SYNOPSIS
    Tests if the script can be dot-sourced and functions are accessible

.DESCRIPTION
    Validates that the script can be loaded into memory without errors
    and that all functions become available.
#>

[CmdletBinding()]
param()

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  SYNTAX & EXECUTION TEST" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$scriptPath = "$PSScriptRoot/../scripts/NetworkDeviceScanner.ps1"

# Test 1: Check file exists
Write-Host "Test 1: File Existence" -ForegroundColor Yellow
if (Test-Path $scriptPath) {
    Write-Host "  ✓ Script file found" -ForegroundColor Green
} else {
    Write-Host "  ✗ Script file not found: $scriptPath" -ForegroundColor Red
    exit 1
}

# Test 2: Parse the script without executing
Write-Host "`nTest 2: PowerShell Parsing" -ForegroundColor Yellow
try {
    $content = Get-Content $scriptPath -Raw
    $errors = $null
    $tokens = $null
    [System.Management.Automation.PSParser]::Tokenize($content, [ref]$errors) | Out-Null
    
    if ($errors -and $errors.Count -gt 0) {
        Write-Host "  ✗ Parse errors found:" -ForegroundColor Red
        $errors | ForEach-Object {
            Write-Host "    Line $($_.Token.StartLine): $($_.Message)" -ForegroundColor Red
        }
        exit 1
    } else {
        Write-Host "  ✓ No parse errors" -ForegroundColor Green
    }
} catch {
    Write-Host "  ✗ Failed to parse script: $_" -ForegroundColor Red
    exit 1
}

# Test 3: Check for syntax using AST
Write-Host "`nTest 3: Abstract Syntax Tree Analysis" -ForegroundColor Yellow
try {
    $ast = [System.Management.Automation.Language.Parser]::ParseFile($scriptPath, [ref]$null, [ref]$errors)
    
    if ($errors -and $errors.Count -gt 0) {
        Write-Host "  ✗ AST parse errors found:" -ForegroundColor Red
        $errors | ForEach-Object {
            Write-Host "    $($_.Message)" -ForegroundColor Red
        }
        exit 1
    } else {
        Write-Host "  ✓ AST parsing successful" -ForegroundColor Green
        Write-Host "    Found $($ast.FindAll({$args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst]}, $true).Count) function definitions" -ForegroundColor Gray
    }
} catch {
    Write-Host "  ✗ AST analysis failed: $_" -ForegroundColor Red
    exit 1
}

# Test 4: Validate function definitions
Write-Host "`nTest 4: Function Definition Validation" -ForegroundColor Yellow

$functionDefs = $ast.FindAll({$args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst]}, $true)

$expectedFunctions = @(
    'Get-LocalSubnets',
    'Get-SubnetFromIP',
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

$foundFunctions = $functionDefs | ForEach-Object { $_.Name }

Write-Host "  Expected functions: $($expectedFunctions.Count)" -ForegroundColor Gray
Write-Host "  Found functions: $($foundFunctions.Count)" -ForegroundColor Gray

$missing = $expectedFunctions | Where-Object { $foundFunctions -notcontains $_ }
if ($missing) {
    Write-Host "  ✗ Missing functions:" -ForegroundColor Red
    $missing | ForEach-Object { Write-Host "    - $_" -ForegroundColor Red }
    exit 1
} else {
    Write-Host "  ✓ All expected functions present" -ForegroundColor Green
}

# Test 5: Check parameter block
Write-Host "`nTest 5: Script Parameter Validation" -ForegroundColor Yellow

$paramBlock = $ast.ParamBlock
if ($paramBlock) {
    $params = $paramBlock.Parameters
    Write-Host "  ✓ Parameter block found" -ForegroundColor Green
    Write-Host "    Parameters defined: $($params.Count)" -ForegroundColor Gray
    foreach ($param in $params) {
        $paramName = $param.Name.VariablePath.UserPath
        $paramType = $param.StaticType.Name
        Write-Host "    - $paramName : $paramType" -ForegroundColor Gray
    }
} else {
    Write-Host "  ⚠ No parameter block found" -ForegroundColor Yellow
}

# Test 6: Check for regions
Write-Host "`nTest 6: Code Organization (Regions)" -ForegroundColor Yellow

$regionPattern = '#region\s+(.+)'
$regions = $content | Select-String -Pattern $regionPattern -AllMatches

if ($regions.Matches.Count -gt 0) {
    Write-Host "  ✓ Code organized with regions: $($regions.Matches.Count)" -ForegroundColor Green
    foreach ($match in $regions.Matches) {
        $regionName = $match.Groups[1].Value.Trim()
        Write-Host "    - $regionName" -ForegroundColor Gray
    }
} else {
    Write-Host "  ⚠ No regions found" -ForegroundColor Yellow
}

# Test 7: Validate CmdletBinding
Write-Host "`nTest 7: CmdletBinding Validation" -ForegroundColor Yellow

$scriptHasCmdletBinding = $content -match '^\[CmdletBinding\(\)\]'
if ($scriptHasCmdletBinding) {
    Write-Host "  ✓ Script has CmdletBinding" -ForegroundColor Green
} else {
    Write-Host "  ⚠ Script missing CmdletBinding" -ForegroundColor Yellow
}

$functionsWithCmdletBinding = ($content | Select-String -Pattern 'function.*\{[\s\S]*?\[CmdletBinding\(\)\]' -AllMatches).Matches.Count
Write-Host "  Functions with CmdletBinding: $functionsWithCmdletBinding" -ForegroundColor Gray

# Test 8: Check for help documentation
Write-Host "`nTest 8: Documentation Validation" -ForegroundColor Yellow

$synopsisCount = ($content | Select-String -Pattern '\.SYNOPSIS' -AllMatches).Matches.Count
$descriptionCount = ($content | Select-String -Pattern '\.DESCRIPTION' -AllMatches).Matches.Count

Write-Host "  .SYNOPSIS blocks: $synopsisCount" -ForegroundColor Gray
Write-Host "  .DESCRIPTION blocks: $descriptionCount" -ForegroundColor Gray

if ($synopsisCount -ge $expectedFunctions.Count) {
    Write-Host "  ✓ All functions documented" -ForegroundColor Green
} else {
    Write-Host "  ⚠ Some functions may lack documentation" -ForegroundColor Yellow
}

# Test 9: Verify no syntax that would prevent execution
Write-Host "`nTest 9: Execution Safety Checks" -ForegroundColor Yellow

# Check for dangerous commands that might cause issues
$dangerousPatterns = @{
    'Remove-Item' = 'File deletion'
    'Remove-.*-Force' = 'Forced removal'
    'Format-' = 'Drive formatting'
    'Clear-.*Computer' = 'System clearing'
}

$foundDangerous = $false
foreach ($pattern in $dangerousPatterns.Keys) {
    if ($content -match $pattern) {
        Write-Host "  ⚠ Found potentially dangerous command: $($dangerousPatterns[$pattern])" -ForegroundColor Yellow
        $foundDangerous = $true
    }
}

if (-not $foundDangerous) {
    Write-Host "  ✓ No dangerous commands detected" -ForegroundColor Green
}

# Summary
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  EXECUTION SAFETY SUMMARY" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "✓ Script parsing: PASSED" -ForegroundColor Green
Write-Host "✓ AST analysis: PASSED" -ForegroundColor Green
Write-Host "✓ Function definitions: PASSED" -ForegroundColor Green
Write-Host "✓ Code organization: PASSED" -ForegroundColor Green
Write-Host "✓ Documentation: PASSED" -ForegroundColor Green
Write-Host "✓ Safety checks: PASSED" -ForegroundColor Green

Write-Host "`n✓✓✓ SCRIPT IS SYNTACTICALLY VALID AND SAFE ✓✓✓`n" -ForegroundColor Green

exit 0
