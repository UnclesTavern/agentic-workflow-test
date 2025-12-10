# Calculator Quick Reference

A one-page reference for the Calculator module.

---

## Installation

```javascript
const Calculator = require('./calculator');
const calc = new Calculator();
```

---

## Methods

| Method | Syntax | Returns | Example |
|--------|--------|---------|---------|
| **Add** | `calc.add(a, b)` | Sum | `calc.add(5, 3)` → `8` |
| **Subtract** | `calc.subtract(a, b)` | Difference | `calc.subtract(10, 4)` → `6` |
| **Multiply** | `calc.multiply(a, b)` | Product | `calc.multiply(6, 7)` → `42` |
| **Divide** | `calc.divide(a, b)` | Quotient | `calc.divide(20, 4)` → `5` |

---

## Error Messages

| Error | Cause |
|-------|-------|
| "Both arguments must be numbers" | Non-number type passed |
| "Arguments cannot be NaN" | NaN value passed |
| "Arguments must be finite numbers" | Infinity passed |
| "Division by zero is not allowed" | Divisor is zero |

---

## Common Patterns

### Error Handling
```javascript
try {
  const result = calc.divide(10, 0);
} catch (error) {
  console.error(error.message);
}
```

### Chaining Operations
```javascript
const step1 = calc.add(10, 5);      // 15
const step2 = calc.multiply(step1, 2);  // 30
const result = calc.divide(step2, 3);   // 10
```

### Percentage Calculation
```javascript
function percentOf(percent, value) {
  const decimal = calc.divide(percent, 100);
  return calc.multiply(value, decimal);
}
```

---

## Input Validation

✅ **Accepts**: Finite numbers (integers and decimals)  
❌ **Rejects**: Strings, null, undefined, NaN, Infinity, objects, arrays

---

## Quick Tips

1. **Floating-point precision**: `0.1 + 0.2` = `0.30000000000000004`
   - Solution: Use `result.toFixed(2)` for display

2. **Division by zero**: Always throws error
   - Solution: Check divisor before calling

3. **Type safety**: Always validates input types
   - Solution: Use `parseFloat()` on user input

4. **Independent instances**: Each `new Calculator()` is separate

---

## Resources

- 📖 [Full Documentation](CALCULATOR_DOCUMENTATION.md)
- 🔍 [API Reference](API_REFERENCE.md)
- 📝 [Usage Examples](USAGE_EXAMPLES.md)
- 🧪 [Test Report](../TEST_REPORT.md)

---

**Version**: 1.0.0 | **Status**: Production Ready ✅
