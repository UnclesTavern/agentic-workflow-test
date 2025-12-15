# agentic-workflow-test

Repository for testing chaining of agents and handovers

## Overview

This repository demonstrates a complete agent workflow system with four specialized **custom GitHub Copilot agents** that work together in a coordinated pipeline:

**develop → test → document → review**

Each agent is a custom agent definition stored in `.github/agents/` that can be invoked through the GitHub Copilot agent system. Each agent is independent and specialized for a specific task, allowing for a robust, iterative development workflow.

## Agent Workflow

### The Four Agents

1. **[Develop Agent](.github/agents/develop-agent.md)** - Implements features and writes code
2. **[Test Agent](.github/agents/test-agent.md)** - Tests implementations independently  
3. **[Document Agent](.github/agents/document-agent.md)** - Creates comprehensive documentation
4. **[Review Agent](.github/agents/review-agent.md)** - Reviews all work and provides feedback

### Workflow Process

```
┌─────────────┐
│   Request   │
└──────┬──────┘
       │
       ▼
┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Develop   │────▶│    Test     │────▶│  Document   │────▶│   Review    │
└─────────────┘     └─────────────┘     └─────────────┘     └──────┬──────┘
       ▲                                                            │
       │                                                            │
       └────────────────────────────────────────────────────────────┘
                          (if changes requested)
```

## Quick Start

### Using Custom Agent Handovers

Simply start with this prompt, do not save it in a prompt-file, could not make that work (yet)
```
@develop-agent Task: {Your special task to be used}
- Remember to follow the orchestration workflow as described in the repository
- Run subagents for each phase
```

These agents are **custom GitHub Copilot agents** defined in `.github/agents/`. Orchestrate the workflow by invoking these custom agents through GitHub Copilot's agent system, having each agent hand off to the next in sequence:

```
Invoke custom agent: develop-agent to implement [your feature]
  ↓ (develops code)
  ↓ (provides context for next agent)
Invoke custom agent: test-agent to test the implementation
  ↓ (tests code)
  ↓ (provides context for next agent)
Invoke custom agent: document-agent to document the feature
  ↓ (creates docs)
  ↓ (provides context for next agent)
Invoke custom agent: review-agent to review all work
  ↓ (approves or requests changes)
```

Each custom agent:
1. Is invoked through GitHub Copilot's custom agent system
2. Completes its specialized task
3. Provides context and artifacts for the next agent

**Note**: These are custom agent definitions, not standard GitHub @mentions. They must be invoked through GitHub Copilot, not directly in issues or PRs.

See [Workflow Orchestrator](.github/agents/workflow-orchestrator.md) for detailed handover examples.

## Documentation

- **[Workflow Orchestrator](.github/agents/workflow-orchestrator.md)** - How to chain agents together
- **[Workflow Example](.github/agents/workflow-example.md)** - Complete example walkthrough
- **[Individual Agent Definitions](.github/agents/)** - Detailed agent specifications

## Agent Characteristics

### Independence
Each agent works independently without assuming the previous agent's context or perspective.

### Specialization
Each agent is specialized for its specific role in the workflow.

### Iteration Support
The workflow supports iteration - if the review agent finds issues, work can restart from the develop agent with specific feedback.

### Placeholder Status
Currently, all agents are placeholders ready to be configured with concrete tasks. The framework is in place for:
- Adding specific development tasks
- Defining testing frameworks
- Establishing documentation standards
- Setting review criteria

## Current Project: PowerShell LAN Device Scanner

### Status: ⚠️ Documentation Complete - Ready for Review

The workflow has successfully produced a PowerShell LAN Device Scanner with comprehensive documentation:

**Implementation**: ✅ Complete (19 isolated functions, 1,069 lines)  
**Testing**: ✅ Complete (56 test cases, 66.1% pass rate)  
**Documentation**: ✅ Complete (8 comprehensive documents)  
**Review**: ⏳ Pending

### 📖 Documentation Available

- **[Scan-LANDevices-README.md](Scan-LANDevices-README.md)** - Main project overview
- **[KNOWN-ISSUES.md](KNOWN-ISSUES.md)** - ⚠️ **READ FIRST** - Critical bugs and workarounds
- **[USER-GUIDE.md](USER-GUIDE.md)** - Comprehensive usage guide (22k+ chars)
- **[DEVELOPER-GUIDE.md](DEVELOPER-GUIDE.md)** - Technical documentation (28k+ chars)
- **[PREREQUISITES.md](PREREQUISITES.md)** - Requirements and compatibility (17k+ chars)
- **[SECURITY.md](SECURITY.md)** - Security considerations (14k+ chars)
- **[TEST-REPORT.md](TEST-REPORT.md)** - Detailed test analysis (23k+ chars)
- **[TEST-SUMMARY.md](TEST-SUMMARY.md)** - Quick test reference (7k+ chars)

### ⚠️ Important Notes

**Critical Issue Identified**: The script contains a reserved variable name bug (`$host` on line 931) that prevents full workflow execution. This is thoroughly documented with fixes in [KNOWN-ISSUES.md](KNOWN-ISSUES.md).

**Production Readiness**: NOT ready for production without applying documented fixes.

**Testing Coverage**: 66.1% pass rate on 56 test cases, tested on Linux (not Windows 11 target platform).

### What It Does

Scans local area networks to:
- Discover alive hosts via ICMP ping
- Identify device types (Home Assistant, Shelly, Ubiquiti, Ajax, NVR)
- Discover API endpoints
- Export results to JSON

### Key Features

- ✅ Multi-subnet scanning
- ✅ Parallel processing (50 threads default)
- ✅ Device type identification with confidence scoring
- ✅ API endpoint discovery
- ✅ 19 modular, isolated functions
- ⚠️ Requires bug fixes before production use

---

## Workflow Features

✓ Four specialized agents with clear roles
✓ Agent handover orchestration with explicit @mentions
✓ Independent agent operation
✓ Review feedback loop for iterations
✓ Comprehensive documentation
✓ Example workflow demonstration
✓ Extensible architecture
✓ **Successfully completed full workflow cycle** ✅

## Future Enhancements

- Integration with CI/CD pipelines
- Automated workflow state management
- Metrics and analytics collection
- Parallel execution for independent tasks
- Custom workflow branching logic
- Integration with GitHub Actions

## Contributing

When adding concrete tasks to agents:
1. Update the relevant agent definition in `.github/agents/`
2. Maintain the independence of each agent
3. Ensure clear handoff protocols
4. Update documentation accordingly

## License

See [LICENSE](LICENSE) file for details.

