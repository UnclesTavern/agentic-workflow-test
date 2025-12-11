# Agent Workflow Architecture

## Visual Workflow Diagram

### Complete Workflow
```
                    ┌─────────────────────┐
                    │   Feature Request   │
                    │   or Task           │
                    └──────────┬──────────┘
                               │
                               ▼
                    ┌─────────────────────┐
                    │   DEVELOP AGENT     │
                    │   ───────────────   │
                    │ • Implements code   │
                    │ • Writes features   │
                    │ • Makes changes     │
                    └──────────┬──────────┘
                               │
                               │ [Code + Changes Summary]
                               ▼
                    ┌─────────────────────┐
                    │    TEST AGENT       │
                    │   ───────────────   │
                    │ • Creates tests     │
                    │ • Runs validation   │
                    │ • Reports results   │
                    └──────────┬──────────┘
                               │
                               │ [Test Results + Coverage]
                               ▼
                    ┌─────────────────────┐
                    │  DOCUMENT AGENT     │
                    │   ───────────────   │
                    │ • Writes docs       │
                    │ • Creates guides    │
                    │ • Updates README    │
                    └──────────┬──────────┘
                               │
                               │ [Documentation]
                               ▼
                    ┌─────────────────────┐
                    │   REVIEW AGENT      │
                    │   ───────────────   │
                    │ • Reviews all work  │
                    │ • Validates quality │
                    │ • Provides feedback │
                    └──────────┬──────────┘
                               │
                ┌──────────────┴──────────────┐
                │                             │
                ▼                             ▼
     ┌────────────────────┐       ┌────────────────────┐
     │   APPROVED         │       │ CHANGES REQUESTED  │
     │   ──────────       │       │ ───────────────    │
     │ • Workflow done    │       │ • Specific issues  │
     │ • Ready to merge   │       │ • Back to develop  │
     └────────────────────┘       └─────────┬──────────┘
                                            │
                                            │ [Feedback]
                                            │
                                            └──────────┐
                                                       │
                                                       ▼
                                            ┌─────────────────────┐
                                            │  DEVELOP AGENT      │
                                            │  (Iteration 2)      │
                                            └─────────────────────┘
```

## Data Flow

### Forward Flow (Success Path)
```
Request
   ↓
Code Implementation
   ↓
Test Results
   ↓
Documentation
   ↓
Final Review
   ↓
Approval
```

### Feedback Loop (Iteration Path)
```
Review Issues
   ↓
Specific Feedback
   ↓
Code Updates
   ↓
Re-test
   ↓
Update Docs
   ↓
Re-review
   ↓
Approval
```

## Agent Interactions

### develop-agent OUTPUT → test-agent INPUT
```
┌─────────────────────────────────────┐
│ Files Changed:                      │
│ - src/feature.js (new)              │
│ - lib/utils.js (modified)           │
│                                     │
│ Implementation Summary:             │
│ - Added feature X                   │
│ - Updated utility Y                 │
│                                     │
│ Notes for Testing:                  │
│ - Verify X with input A, B, C       │
│ - Check edge case Y                 │
└─────────────────────────────────────┘
```

### test-agent OUTPUT → document-agent INPUT
```
┌─────────────────────────────────────┐
│ Test Results:                       │
│ ✓ 15/15 tests passed (100%)         │
│ ✓ Coverage: 95%                     │
│                                     │
│ What to Document:                   │
│ - Feature X API reference           │
│ - Usage examples for Y              │
│ - Known limitation Z                │
└─────────────────────────────────────┘
```

### document-agent OUTPUT → review-agent INPUT
```
┌─────────────────────────────────────┐
│ Documentation Created:              │
│ - docs/api.md (updated)             │
│ - README.md (updated)               │
│ - examples/usage.js (new)           │
│                                     │
│ Coverage:                           │
│ ✓ All functions documented          │
│ ✓ Examples provided                 │
│ ✓ Installation steps updated        │
└─────────────────────────────────────┘
```

### review-agent OUTPUT (Approved)
```
┌─────────────────────────────────────┐
│ STATUS: ✓ APPROVED                  │
│                                     │
│ Quality Metrics:                    │
│ - Code: Excellent                   │
│ - Tests: Very Good                  │
│ - Docs: Excellent                   │
│                                     │
│ Ready for Production: YES           │
└─────────────────────────────────────┘
```

### review-agent OUTPUT (Changes Requested)
```
┌─────────────────────────────────────┐
│ STATUS: ⚠ CHANGES REQUESTED         │
│                                     │
│ Issues:                             │
│ 1. Missing input validation         │
│ 2. Test coverage gap for edge case  │
│ 3. Documentation incomplete         │
│                                     │
│ Feedback for develop-agent:         │
│ - Add validation for input type X   │
│ - Priority: High                    │
│                                     │
│ Action: Restart workflow            │
└─────────────────────────────────────┘
```

## Parallel Possibilities (Future)

```
                    ┌─────────────────┐
                    │  DEVELOP AGENT  │
                    └────────┬────────┘
                             │
              ┌──────────────┼──────────────┐
              │              │              │
              ▼              ▼              ▼
      ┌──────────┐   ┌──────────┐   ┌──────────┐
      │   TEST   │   │  LINT &  │   │ SECURITY │
      │  AGENT   │   │  FORMAT  │   │  SCAN    │
      └─────┬────┘   └─────┬────┘   └─────┬────┘
            │              │              │
            └──────────────┼──────────────┘
                           │
                           ▼
                   ┌──────────────┐
                   │   DOCUMENT   │
                   └──────┬───────┘
                          │
                          ▼
                   ┌──────────────┐
                   │    REVIEW    │
                   └──────────────┘
```

## Agent States

```
┌─────────┐     ┌─────────┐     ┌─────────┐
│  READY  │────▶│ WORKING │────▶│  DONE   │
└─────────┘     └─────────┘     └─────────┘
                      │
                      ▼
                ┌─────────┐
                │  ERROR  │
                └─────────┘
```

## Workflow Metrics

```
┌────────────────────────────────────┐
│ Workflow Performance               │
├────────────────────────────────────┤
│ Total Iterations:           1-3    │
│ Average Time per Agent:     5-15m  │
│ Success Rate (1st pass):    70%    │
│ Success Rate (2nd pass):    95%    │
│ Average Feedback Items:     2-3    │
└────────────────────────────────────┘
```
