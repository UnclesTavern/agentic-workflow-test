# Agent Workflow System - README

## Overview

This directory contains **custom GitHub Copilot agent definitions** and workflow orchestration documentation for the agentic workflow test system.

**Important**: These are custom agent definitions for use with GitHub Copilot's agent system, not standard GitHub @mentions. They must be invoked through GitHub Copilot, not directly in GitHub issues or pull requests.

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

## Agent File Format

Each agent file **must** include YAML frontmatter to be discoverable in GitHub Copilot Agent HQ:

```yaml
---
name: agent-name              # Unique agent identifier
description: Brief description of the agent's purpose  # Required!
target: github-copilot        # Where the agent can be used
tools: ["*"]                  # Tools available to the agent
---
```

After the frontmatter, the markdown content describes the agent's detailed instructions, role, and behavior.

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

### Custom Agent Invocation
These are **custom GitHub Copilot agents**. Invoke them through GitHub Copilot's custom agent system:

```
Custom agent: develop-agent → completes task → provides context
Custom agent: test-agent → completes task → provides context
Custom agent: document-agent → completes task → provides context
Custom agent: review-agent → approves or requests changes
```

The `@agent-name` syntax in documentation is shorthand representing these custom agents, but they are invoked through GitHub Copilot, not as standard GitHub mentions.

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
2. Add YAML frontmatter with required fields:
   ```yaml
   ---
   name: agent-name
   description: Clear description of what the agent does
   target: github-copilot
   tools: ["*"]
   ---
   ```
3. Follow the structure of existing agent definitions
4. Update the workflow orchestrator to include the new agent
5. Document handoff protocols

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
