# Agent Workflow System - README

## Overview

This directory contains the custom agent definitions and workflow orchestration documentation for the agentic workflow test system.

## Structure

```
.github/agents/
├── develop-agent.md          # Development agent definition
├── test-agent.md             # Testing agent definition
├── document-agent.md         # Documentation agent definition
├── review-agent.md           # Review agent definition
├── workflow-orchestrator.md  # Workflow chaining guide
├── workflow-example.md       # Complete example walkthrough
└── README.md                 # This file
```

## Quick Reference

### Agent Sequence
1. **develop-agent** → Implements code
2. **test-agent** → Tests independently  
3. **document-agent** → Creates documentation
4. **review-agent** → Reviews and approves/requests changes

### Key Files

- **Agent Definitions**: Individual `.md` files define each agent's role, responsibilities, and output format
- **Workflow Orchestrator**: Explains how to chain agents together
- **Workflow Example**: Shows a complete workflow example from start to finish

## Using the Agents

### Agent Handover Orchestration
Invoke agents using @mentions and have each agent hand off to the next:

```
@develop-agent [task] → completes and hands off to @test-agent
@test-agent [task] → completes and hands off to @document-agent
@document-agent [task] → completes and hands off to @review-agent
@review-agent [task] → approves or requests changes from @develop-agent
```

### Individual Agent Use
Each agent can be invoked independently with specific instructions following the format in their definition file.

### Workflow Chain
Use the orchestrator guide to understand handoff protocols and context passing between agents.

## Agent Characteristics

### ✓ Independence
Each agent operates independently without assuming context from previous agents.

### ✓ Specialization
Each agent is specialized for a specific role in the development workflow.

### ✓ Clear Handoffs
Each agent provides structured output for the next agent in the chain.

### ✓ Iteration Support
The workflow supports restart from develop-agent based on review feedback.

## Current Status

All agents are currently **placeholders** ready for concrete task definitions. The framework is in place for:

- ✓ Agent definitions and roles
- ✓ Workflow orchestration
- ✓ Handoff protocols
- ✓ Review feedback loop
- ⏳ Specific development tasks (to be added)
- ⏳ Testing frameworks (to be defined)
- ⏳ Documentation standards (to be specified)
- ⏳ Review criteria (to be established)

## Extending the System

### Adding New Agents
1. Create a new `<agent-name>.md` file in this directory
2. Follow the structure of existing agent definitions
3. Update the workflow orchestrator to include the new agent
4. Document handoff protocols

### Customizing Existing Agents
1. Edit the relevant agent `.md` file
2. Maintain the standard output format
3. Update the workflow example if needed
4. Ensure compatibility with adjacent agents in the chain

## Best Practices

1. **Keep Agents Independent**: Each agent should work without relying on previous agent's assumptions
2. **Clear Communication**: Use structured output formats for handoffs
3. **Document Thoroughly**: Each agent should document what it did and what the next agent needs to know
4. **Support Iteration**: Design for workflow restarts based on feedback

## Further Reading

- See `workflow-orchestrator.md` for detailed chaining instructions
- See `workflow-example.md` for a complete example
- See individual agent files for specific agent details
