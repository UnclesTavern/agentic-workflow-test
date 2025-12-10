# Agent Workflow Orchestrator

This document describes how to chain the custom agents together to create a complete development workflow.

## Workflow Overview

The agent workflow follows this sequence:

```
[Task Request] → develop-agent → test-agent → document-agent → review-agent → [Complete/Restart]
```

## Agent Chain Description

### 1. Develop Agent (develop-agent.md)
**Input**: Feature request or task description
**Output**: Implemented code and list of changes
**Next**: test-agent

### 2. Test Agent (test-agent.md)
**Input**: Code from develop-agent
**Output**: Test results and validation report
**Next**: document-agent

### 3. Document Agent (document-agent.md)
**Input**: Code and test results
**Output**: Updated documentation
**Next**: review-agent

### 4. Review Agent (review-agent.md)
**Input**: All artifacts from previous agents
**Output**: Final approval or change requests
**Next**: Complete or restart from develop-agent

## How to Use the Workflow

### Agent Handover Orchestration

The workflow is orchestrated through **agent handovers**, where each agent completes its work and explicitly hands off to the next agent in the chain.

#### Step 1: Invoke develop-agent
```
@develop-agent please implement [feature description]

Context: New feature request
Requirements: [detailed requirements]
```

The develop-agent will:
- Implement the requested feature
- Document what was changed
- Hand off to test-agent with a summary

#### Step 2: develop-agent hands off to test-agent
The develop-agent completes with:
```
@test-agent please test the implementation

Context: Implemented [feature] in the following files:
- src/feature.js
- lib/utils.js

Changes made:
- Added feature X with methods A, B, C
- Updated utility Y to support Z

Please verify: [test scenarios]
```

#### Step 3: test-agent hands off to document-agent
The test-agent completes with:
```
@document-agent please document the feature

Context: Testing complete for [feature]

Test Results:
- 15/15 tests passed (100%)
- Coverage: 95%
- All edge cases validated

Please document:
- Feature X API and usage
- Methods A, B, C specifications
- Known limitations: [if any]
```

#### Step 4: document-agent hands off to review-agent
The document-agent completes with:
```
@review-agent please review the complete workflow

Context: Documentation complete for [feature]

Documentation created:
- API reference in docs/api.md
- Usage examples in examples/usage.js
- Updated README.md

All artifacts ready for review:
- Code implementation (develop-agent)
- Test results (test-agent)
- Documentation (document-agent)
```

#### Step 5: review-agent completes or restarts workflow
The review-agent either:

**APPROVED**:
```
STATUS: ✓ APPROVED

Quality Assessment:
- Code: Excellent
- Tests: Very Good
- Documentation: Excellent

Workflow complete. Ready for merge.
```

**CHANGES REQUESTED**:
```
STATUS: ⚠ CHANGES REQUESTED

@develop-agent please address the following:

Issues found:
1. Missing input validation for parameter X
2. Edge case not handled: [specific case]

Priority: High
Please reimplement and restart workflow.
```

## Workflow States

### Success Path
```
develop → test → document → review → APPROVED → COMPLETE
```

### Iteration Path
```
develop → test → document → review → CHANGES REQUESTED → develop (with feedback)
```

## Context Passing

Each agent should receive:
- **Task**: What they need to accomplish
- **Previous Context**: Summary from previous agents
- **Artifacts**: Relevant files, code, or results

Format for context passing:
```
## Previous Agent Output
[Summary from previous agent]

## Artifacts
- File: path/to/file.ext
- Changes: description of changes
- Results: test results or other outputs

## Your Task
[Specific instructions for current agent]
```

## Best Practices

1. **Clear Communication**: Each agent should provide clear output for the next agent
2. **Independent Operation**: Agents should work independently without assuming previous agent's perspective
3. **Comprehensive Output**: Include all relevant information in handoff
4. **Iteration Ready**: Support workflow restarts based on review feedback

## Example Workflow Session

See `workflow-example.md` for a complete example of the workflow in action.

## Future Enhancements

- Automated agent chaining via CI/CD
- Workflow state persistence
- Metrics and analytics collection
- Parallel agent execution for independent tasks
- Custom workflow branching logic
