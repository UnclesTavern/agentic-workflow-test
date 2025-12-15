# Network Device Scanner - Documentation

Complete documentation for the NetworkDeviceScanner.ps1 PowerShell script.

## 📚 Documentation Index

### Getting Started
Start here if you're new to the Network Device Scanner.

**[📖 NetworkDeviceScanner.md](NetworkDeviceScanner.md)**
- Overview and features
- Quick start guide
- Requirements and installation
- Basic usage examples
- Parameter reference
- Output format overview

---

### User Documentation

**[👤 USER_GUIDE.md](USER_GUIDE.md)**
Complete guide for end users covering:
- Getting started and prerequisites
- Step-by-step usage instructions
- 8+ common scenarios with examples
- Understanding scan results
- Advanced configuration
- Troubleshooting guide (6 common issues)
- FAQ (10 questions)
- Best practices

**Best for:** Beginners through intermediate users

---

### Technical Documentation

**[⚙️ TECHNICAL_REFERENCE.md](TECHNICAL_REFERENCE.md)**
Comprehensive technical documentation covering:
- Architecture overview
- Complete function reference (13 functions)
- Data structures and schemas
- Device classification algorithm
- Network operations details
- Security implementation
- Performance considerations
- Extension guide for developers

**Best for:** Advanced users and developers

---

### Examples & Integration

**[💡 EXAMPLES.md](EXAMPLES.md)**
Real-world usage scenarios including:
- Basic usage examples
- 5 real-world scenarios
- Sample output (JSON and console)
- Integration examples (Home Assistant, Excel, SQL, Slack)
- Automation examples (Task Scheduler, change detection)
- Data analysis examples

**Best for:** Users looking for practical, copy-paste solutions

---

## 🚀 Quick Links

### By User Type

**New Users:**
1. Read [Overview](NetworkDeviceScanner.md#overview)
2. Check [Requirements](NetworkDeviceScanner.md#requirements)
3. Try [Quick Start](NetworkDeviceScanner.md#quick-start)
4. Review [Basic Usage](USER_GUIDE.md#basic-usage)

**Intermediate Users:**
1. Explore [Common Scenarios](USER_GUIDE.md#common-scenarios)
2. Learn [Advanced Configuration](USER_GUIDE.md#advanced-configuration)
3. Check [Examples](EXAMPLES.md#real-world-scenarios)
4. Review [Troubleshooting](USER_GUIDE.md#troubleshooting)

**Advanced Users / Developers:**
1. Review [Architecture](TECHNICAL_REFERENCE.md#architecture-overview)
2. Study [Function Reference](TECHNICAL_REFERENCE.md#function-reference)
3. Understand [Classification System](TECHNICAL_REFERENCE.md#device-classification-system)
4. Follow [Extension Guide](TECHNICAL_REFERENCE.md#extension-guide)

### By Task

**Installing & Running:**
- [Installation](NetworkDeviceScanner.md#installation)
- [First-Time Setup](USER_GUIDE.md#first-time-setup)
- [Basic Usage](USER_GUIDE.md#basic-usage)

**Understanding Results:**
- [Output Format](NetworkDeviceScanner.md#output-format)
- [Understanding Results](USER_GUIDE.md#understanding-results)
- [Sample Output](EXAMPLES.md#sample-output)

**Troubleshooting:**
- [Known Limitations](NetworkDeviceScanner.md#known-limitations)
- [Troubleshooting Guide](USER_GUIDE.md#troubleshooting)
- [FAQ](USER_GUIDE.md#faq)

**Integrating:**
- [Integration Examples](EXAMPLES.md#integration-examples)
- [Automation Examples](EXAMPLES.md#automation-examples)
- [Extension Guide](TECHNICAL_REFERENCE.md#extension-guide)

**Developing:**
- [Architecture Overview](TECHNICAL_REFERENCE.md#architecture-overview)
- [Function Reference](TECHNICAL_REFERENCE.md#function-reference)
- [Performance Considerations](TECHNICAL_REFERENCE.md#performance-considerations)

---

## 📊 Documentation Overview

| Document | Size | Topics | Audience |
|----------|------|--------|----------|
| NetworkDeviceScanner.md | 12 KB | Overview, Quick Start, Parameters | All users |
| USER_GUIDE.md | 18 KB | Instructions, Scenarios, Troubleshooting | Beginners-Intermediate |
| TECHNICAL_REFERENCE.md | 30 KB | Functions, API, Architecture | Advanced/Developers |
| EXAMPLES.md | 26 KB | Real scenarios, Integrations, Analysis | Intermediate-Advanced |

**Total:** 86 KB of comprehensive documentation

---

## 🔍 Key Topics

### Device Types
Learn about the three device categories:
- **IOTHub** - Home Assistant, OpenHAB, Hubitat
- **IOTDevice** - Shelly, ESP devices, smart home gadgets
- **Security** - UniFi, cameras, NVR systems

See: [Device Types](NetworkDeviceScanner.md#device-types)

### Device Classification
Understand how devices are automatically classified:
- Scoring algorithm with multiple factors
- Keyword matching in hostname, manufacturer, content
- Port-based identification
- 13-vendor OUI database

See: [Classification Algorithm](NetworkDeviceScanner.md#device-classification-algorithm) | [Technical Details](TECHNICAL_REFERENCE.md#device-classification-system)

### Network Scanning
Two-phase scanning process:
1. **Phase 1:** ICMP ping sweep for host discovery
2. **Phase 2:** Detailed device scanning (ports, HTTP, classification)

See: [Scan Process](NetworkDeviceScanner.md#scan-process) | [Network Operations](TECHNICAL_REFERENCE.md#network-operations)

### Performance
Optimize scan speed:
- ArrayList performance pattern (O(1) vs O(n²))
- Timeout tuning for different networks
- Subnet sizing recommendations
- Scan time calculations

See: [Performance Tuning](USER_GUIDE.md#performance-tuning) | [Performance Considerations](TECHNICAL_REFERENCE.md#performance-considerations)

---

## ⚙️ Script Features

### Capabilities
- ✅ Multi-subnet scanning with CIDR notation
- ✅ Automatic subnet detection
- ✅ Device type classification (3 categories)
- ✅ Manufacturer identification (13 vendors)
- ✅ Port scanning (configurable)
- ✅ HTTP/HTTPS endpoint discovery
- ✅ JSON export with timestamps
- ✅ Colored console output
- ✅ Progress indicators

### Technical Highlights
- ✅ 13 isolated functions (Single Responsibility)
- ✅ ArrayList performance optimization
- ✅ Proper SSL certificate handling
- ✅ Comprehensive error handling
- ✅ 96.6% test pass rate (28/29 tests)
- ✅ PSScriptAnalyzer compliant
- ✅ Security-conscious design

See: [Key Features](NetworkDeviceScanner.md#key-features) | [Architecture](TECHNICAL_REFERENCE.md#architecture-overview)

---

## 🛠️ Requirements

- **Platform:** Windows 11
- **PowerShell:** 5.1 or higher
- **.NET Framework:** 4.7.2+ (included with Windows 11)
- **Permissions:** May require Administrator privileges

See: [Requirements](NetworkDeviceScanner.md#requirements) | [Prerequisites](USER_GUIDE.md#prerequisites-check)

---

## 📖 Usage Examples

### Basic Scan
```powershell
.\NetworkDeviceScanner.ps1
```

### Specific Subnet
```powershell
.\NetworkDeviceScanner.ps1 -Subnets "192.168.1.0/24"
```

### Multiple Subnets with Custom Timeout
```powershell
.\NetworkDeviceScanner.ps1 `
    -Subnets "192.168.1.0/24","192.168.2.0/24" `
    -Timeout 500
```

More examples: [Quick Start](NetworkDeviceScanner.md#quick-start) | [Usage Examples](USER_GUIDE.md#basic-usage) | [Examples](EXAMPLES.md)

---

## 🔒 Security

The script follows security best practices:
- ✅ No hardcoded credentials
- ✅ Proper SSL certificate handling (temporary bypass, guaranteed restore)
- ✅ Read-only operations (no device modification)
- ✅ Input validation and error handling
- ✅ No external data transmission

**Important:** Only scan networks you own or have permission to scan.

See: [Security Best Practices](NetworkDeviceScanner.md#security-best-practices) | [Security Implementation](TECHNICAL_REFERENCE.md#security-implementation)

---

## 🤝 Support

### Common Issues
- [No subnets found](USER_GUIDE.md#problem-no-local-subnets-found)
- [No devices found](USER_GUIDE.md#problem-no-devices-found)
- [Permission errors](USER_GUIDE.md#problem-access-denied-or-permission-errors)
- [Slow scans](USER_GUIDE.md#problem-scan-is-very-slow)

### Get Help
1. Check [FAQ](USER_GUIDE.md#faq)
2. Review [Troubleshooting](USER_GUIDE.md#troubleshooting)
3. See [Known Limitations](NetworkDeviceScanner.md#known-limitations)
4. Review test results in `tests/TEST_REPORT.md`

---

## 📝 Version History

**Version 1.0** (Current)
- Initial release
- 13 isolated functions
- 3 device classification categories
- Multi-subnet scanning
- JSON export
- Comprehensive documentation

---

## 📄 License

See [LICENSE](../LICENSE) file for details.

---

## 🔗 Related Files

- **Script:** [`scripts/NetworkDeviceScanner.ps1`](../scripts/NetworkDeviceScanner.ps1)
- **Tests:** [`tests/`](../tests/)
- **Test Report:** [`tests/TEST_REPORT.md`](../tests/TEST_REPORT.md)
- **Main README:** [`README.md`](../README.md)

---

**Documentation Version:** 1.0  
**Last Updated:** 2025-12-13  
**Created by:** document-agent
