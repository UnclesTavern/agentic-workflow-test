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

## Features

✓ Four specialized agents with clear roles
✓ Agent handover orchestration with explicit @mentions
✓ Independent agent operation
✓ Review feedback loop for iterations
✓ Comprehensive documentation
✓ Example workflow demonstration
✓ Extensible architecture

## Example Implementation: Calculator Module

This repository includes a complete example implementation showcasing the agent workflow system:

### Calculator Feature

A production-ready calculator module implementing basic arithmetic operations:

- **Implementation**: Python module with `Calculator` class and functional interface
- **Operations**: Addition, subtraction, multiplication, division
- **Type Support**: Integers, floats, and mixed types
- **Error Handling**: Division by zero protection and invalid operation detection
- **Test Coverage**: 100% coverage with 38 comprehensive tests
- **Documentation**: Complete user guide and API reference

### Documentation

- **[Calculator User Guide](docs/CALCULATOR.md)** - Complete guide with examples and use cases
- **[API Reference](docs/API_REFERENCE.md)** - Detailed API documentation
- **[Test Report](TEST_REPORT.md)** - Test results and coverage analysis

### Quick Example

```python
from src.calculator import Calculator, calculate

# Class-based approach
calc = Calculator()
result = calc.add(10, 5)  # 15

# Functional approach
result = calculate('multiply', 7, 6)  # 42
```

This implementation demonstrates the complete workflow cycle:
1. **Develop Agent**: Implemented the calculator module
2. **Test Agent**: Created comprehensive test suite (38 tests, 100% coverage)
3. **Document Agent**: Generated user guide and API reference
4. **Review Agent**: Ready for final review

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
