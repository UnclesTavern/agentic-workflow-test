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

### Agent Workflow Documentation
- **[Workflow Orchestrator](.github/agents/workflow-orchestrator.md)** - How to chain agents together
- **[Workflow Example](.github/agents/workflow-example.md)** - Complete example walkthrough
- **[Individual Agent Definitions](.github/agents/)** - Detailed agent specifications

### Calculator Documentation
- **[Calculator Documentation](docs/CALCULATOR_DOCUMENTATION.md)** - Complete user guide and tutorials
- **[API Reference](docs/API_REFERENCE.md)** - Detailed method documentation
- **[Usage Examples](docs/USAGE_EXAMPLES.md)** - Real-world use cases and patterns
- **[Test Report](TEST_REPORT.md)** - Comprehensive test results
- **[Testing Guide](TESTING_GUIDE.md)** - How to run and write tests

## Agent Characteristics

### Independence
Each agent works independently without assuming the previous agent's context or perspective.

### Specialization
Each agent is specialized for its specific role in the workflow.

### Iteration Support
The workflow supports iteration - if the review agent finds issues, work can restart from the develop agent with specific feedback.

### Example Implementation: Calculator

The workflow has been demonstrated with a complete Calculator implementation:

- **Implementation**: Full-featured Calculator class with add, subtract, multiply, divide operations
- **Testing**: 76 comprehensive tests with 100% code coverage
- **Documentation**: Complete user and developer documentation
- **Status**: Production-ready ✅

See [Calculator Documentation](docs/CALCULATOR_DOCUMENTATION.md) for details.

## Features

### Agent Workflow Features
✓ Four specialized agents with clear roles  
✓ Agent handover orchestration with explicit @mentions  
✓ Independent agent operation  
✓ Review feedback loop for iterations  
✓ Comprehensive documentation  
✓ Example workflow demonstration  
✓ Extensible architecture

### Calculator Features
✓ Four arithmetic operations (add, subtract, multiply, divide)  
✓ Comprehensive input validation  
✓ Division by zero prevention  
✓ Support for integers and decimals  
✓ 100% test coverage (76 tests)  
✓ Zero dependencies  
✓ Production-ready code

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
