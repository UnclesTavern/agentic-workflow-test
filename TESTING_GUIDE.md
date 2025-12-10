# Testing Guide for Calculator

## Quick Test Commands

```bash
# Run all tests
npm test

# Run tests with coverage report
npm run test:coverage

# Run tests with verbose output
npm run test:verbose
```

## Test Coverage Summary

- **76 total tests** covering all functionality
- **100% code coverage** (statements, functions, lines)
- **90% branch coverage** (environment conditionals excluded)

## What's Tested

### Core Operations
- ✅ Addition (9 tests)
- ✅ Subtraction (7 tests)
- ✅ Multiplication (10 tests)
- ✅ Division (12 tests)

### Error Handling
- ✅ Type validation (13 tests)
- ✅ NaN detection (4 tests)
- ✅ Infinity detection (7 tests)
- ✅ Division by zero (3 tests)

### Edge Cases
- ✅ Boundary values (4 tests)
- ✅ Floating-point precision (3 tests)
- ✅ Return value validation (6 tests)
- ✅ Multiple operations (3 tests)
- ✅ Calculator instances (2 tests)

## Test Structure

The test suite is organized into logical sections:
1. **Addition** - All addition scenarios
2. **Subtraction** - All subtraction scenarios
3. **Multiplication** - All multiplication scenarios
4. **Division** - All division scenarios including error cases
5. **Input Validation** - Type, NaN, and Infinity checks
6. **Return Value Validation** - Output correctness
7. **Multiple Operations** - Chaining and independence
8. **Boundary Conditions** - Edge values
9. **Floating Point Precision** - Known JS quirks
10. **Calculator Instance** - Object behavior

## Adding New Tests

When adding new functionality:

1. **Create new test section** in `src/calculator.test.js`
2. **Follow existing structure:**
   ```javascript
   describe('New Feature', () => {
     describe('Core functionality', () => {
       test('should do something', () => {
         expect(calc.newMethod(input)).toBe(expectedOutput);
       });
     });
   });
   ```
3. **Test all scenarios:**
   - Positive cases
   - Negative cases
   - Edge cases
   - Error conditions
4. **Run tests:** `npm test`
5. **Check coverage:** `npm run test:coverage`

## Continuous Testing

For development with auto-rerun on file changes:

```bash
# Install Jest globally (optional)
npm install -g jest

# Watch mode
jest --watch

# Or use npm script
npx jest --watch
```

## Debugging Tests

To debug a specific test:

```bash
# Run single test file
npx jest calculator.test.js

# Run tests matching pattern
npx jest -t "should add two positive integers"

# Run with additional output
npx jest --verbose
```

## Test Best Practices

1. ✅ Each test should test one thing
2. ✅ Use descriptive test names
3. ✅ Use `beforeEach` for setup
4. ✅ Test both success and failure cases
5. ✅ Use appropriate matchers (`toBe`, `toBeCloseTo`, `toThrow`)
6. ✅ Keep tests independent
7. ✅ Don't test implementation details

## Coverage Reports

After running `npm run test:coverage`, view detailed report:

```bash
# Coverage summary in terminal
# Detailed HTML report in: coverage/lcov-report/index.html
open coverage/lcov-report/index.html  # macOS
xdg-open coverage/lcov-report/index.html  # Linux
```

## Known Behavior

### Floating-Point Precision
JavaScript's floating-point arithmetic can produce unexpected results:
- `0.1 + 0.2 = 0.30000000000000004` (not exactly 0.3)
- Tests use `toBeCloseTo()` to handle this properly
- This is expected behavior, not a bug

### Module Exports
Lines 79-84 in calculator.js contain conditional exports:
- Support both CommonJS and ES6 modules
- These are environment-dependent (not always executed)
- Contributes to 90% branch coverage (not 100%)
- This is intentional and correct

## CI/CD Integration

To integrate with CI/CD pipelines:

```yaml
# Example GitHub Actions
- name: Install dependencies
  run: npm install
  
- name: Run tests
  run: npm test
  
- name: Generate coverage
  run: npm run test:coverage
```

## Test Maintenance

When modifying calculator.js:
1. Run tests after each change: `npm test`
2. Ensure all tests pass
3. Check coverage: `npm run test:coverage`
4. Add tests for new functionality
5. Update this guide if test structure changes

---

For detailed test results and findings, see **TEST_REPORT.md**.
