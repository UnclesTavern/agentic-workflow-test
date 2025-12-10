# Agent Workflow Example

This document provides a complete example of the agent workflow in action.

## Scenario: Implementing a Simple Calculator Function

### Initial Request
```
Task: Create a simple calculator function that supports addition, subtraction, 
multiplication, and division operations.
```

---

## Step 1: Develop Agent

**Input**: Create a simple calculator function

**Actions Taken**:
- Created `calculator.js` with basic operations
- Implemented add, subtract, multiply, divide functions
- Added basic error handling for division by zero

**Output**:
```
Files Created:
- src/calculator.js

Implementation Summary:
- Created Calculator class with four basic operations
- Each operation takes two numbers and returns result
- Division includes zero-check protection

Notes for test-agent:
- Verify all four operations work correctly
- Test division by zero handling
- Test with positive, negative, and decimal numbers
```

**Status**: ✓ Complete, handing off to test-agent

---

## Step 2: Test Agent

**Input**: Test the calculator implementation

**Actions Taken**:
- Created test suite for calculator
- Tested all four operations with various inputs
- Verified error handling
- Checked edge cases

**Output**:
```
Files Created:
- tests/calculator.test.js

Test Results:
✓ Addition with positive numbers
✓ Addition with negative numbers
✓ Subtraction operations
✓ Multiplication operations
✓ Division operations
✓ Division by zero throws error
✓ Handles decimal numbers

Total: 7/7 tests passed (100% pass rate)

Notes for document-agent:
- All tests passing
- Coverage includes basic operations and error cases
- Document the error handling for division by zero
```

**Status**: ✓ Complete, handing off to document-agent

---

## Step 3: Document Agent

**Input**: Document the calculator feature

**Actions Taken**:
- Added API documentation for Calculator class
- Created usage examples
- Documented error handling
- Updated README with calculator information

**Output**:
```
Files Created/Modified:
- docs/calculator-api.md (new)
- README.md (updated)

Documentation Includes:
- Complete API reference for all methods
- Usage examples for each operation
- Error handling documentation
- Quick start guide

Notes for review-agent:
- Documentation covers all functionality
- Examples are tested and verified
- Follows existing documentation style
```

**Status**: ✓ Complete, handing off to review-agent

---

## Step 4: Review Agent

**Input**: Review all work from the workflow

**Review Process**:

### Code Review
- ✓ Code is clean and well-structured
- ✓ Follows JavaScript best practices
- ✓ Error handling is appropriate
- ✓ No security concerns identified

### Test Review
- ✓ All tests passing (100% pass rate)
- ✓ Good coverage of functionality
- ✓ Edge cases tested
- ⚠ Could add tests for type validation

### Documentation Review
- ✓ API documentation is comprehensive
- ✓ Examples are clear and helpful
- ✓ Error handling documented
- ✓ Follows repository conventions

**Decision**: APPROVED with minor recommendation

**Final Summary**:
```
STATUS: ✓ APPROVED

Quality Assessment:
- Code Quality: Excellent
- Test Coverage: Very Good (minor enhancement suggested)
- Documentation: Excellent

Workflow Results:
- All agents completed successfully
- No critical issues identified
- Feature ready for production

Recommendations for Future:
- Consider adding type validation tests
- Could add performance benchmarks for large numbers

Overall: The calculator feature is well-implemented, thoroughly tested, 
and properly documented. Approved for merge.
```

**Status**: ✓ Workflow Complete

---

## Workflow Summary

| Agent | Iterations | Status | Issues Found |
|-------|------------|--------|--------------|
| develop-agent | 1 | ✓ Complete | 0 |
| test-agent | 1 | ✓ Complete | 0 |
| document-agent | 1 | ✓ Complete | 0 |
| review-agent | 1 | ✓ Approved | 0 critical |

**Total Workflow Iterations**: 1
**Outcome**: Approved
**Time to Completion**: 1 pass through workflow

---

## Example with Changes Requested

If the review-agent found issues, the workflow would restart:

### Review Agent Output (Alternative Scenario)
```
STATUS: ⚠ CHANGES REQUESTED

Issues Identified:
1. Missing input validation for non-numeric inputs
2. No tests for string/null inputs
3. Documentation doesn't mention input requirements

Feedback for develop-agent:
- Add input validation to ensure parameters are numbers
- Throw appropriate error for invalid input types
- Priority: High

Workflow: Restarting from develop-agent with feedback
```

Then the workflow would restart:
```
develop-agent (iteration 2) → test-agent → document-agent → review-agent → APPROVED
```

---

## Key Takeaways

1. **Linear Flow**: Each agent builds on the previous one's work
2. **Independent Operation**: Each agent works independently with clear inputs
3. **Quality Gates**: Review agent acts as final quality checkpoint
4. **Iterative**: Workflow can restart based on review feedback
5. **Comprehensive**: All aspects covered (code, tests, docs, review)
