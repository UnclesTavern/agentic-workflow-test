# Calculator API Reference

Complete API documentation for the Calculator module.

---

## Table of Contents

- [Class: Calculator](#class-calculator)
  - [Constructor](#constructor)
  - [Methods](#methods)
    - [add()](#addab)
    - [subtract()](#subtractab)
    - [multiply()](#multiplyab)
    - [divide()](#divideab)
  - [Private Methods](#private-methods)
- [Error Reference](#error-reference)
- [Type Definitions](#type-definitions)
- [Examples by Category](#examples-by-category)

---

## Class: Calculator

The Calculator class provides basic arithmetic operations with comprehensive input validation and error handling.

### Constructor

#### `new Calculator()`

Creates a new instance of the Calculator class.

**Syntax:**
```javascript
const calc = new Calculator();
```

**Parameters:**
- None

**Returns:**
- `{Calculator}` - A new Calculator instance

**Description:**
- Each Calculator instance is independent
- No state is maintained between method calls
- Multiple instances can coexist without interference

**Examples:**
```javascript
// Create a single instance
const calc = new Calculator();

// Create multiple instances
const calc1 = new Calculator();
const calc2 = new Calculator();

// Instances are independent
console.log(calc1.add(1, 2));  // 3
console.log(calc2.add(5, 5));  // 10
```

**Throws:**
- None (constructor cannot fail)

---

## Methods

### `add(a, b)`

Adds two numbers and returns the sum.

**Syntax:**
```javascript
calc.add(a, b)
```

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `a` | number | Yes | The first number (addend) |
| `b` | number | Yes | The second number (addend) |

**Returns:**
- `{number}` - The sum of `a` and `b`

**Throws:**

| Error | Condition | Error Message |
|-------|-----------|---------------|
| `Error` | Either parameter is not a number | "Both arguments must be numbers" |
| `Error` | Either parameter is NaN | "Arguments cannot be NaN" |
| `Error` | Either parameter is Infinity or -Infinity | "Arguments must be finite numbers" |

**Examples:**

```javascript
// Basic addition
calc.add(5, 3);           // 8
calc.add(10, 20);         // 30

// Negative numbers
calc.add(-5, 3);          // -2
calc.add(-10, -20);       // -30

// Decimals
calc.add(0.1, 0.2);       // 0.30000000000000004
calc.add(1.5, 2.5);       // 4

// Zero
calc.add(0, 5);           // 5
calc.add(5, 0);           // 5
calc.add(0, 0);           // 0

// Mixed positive and negative
calc.add(-5, 10);         // 5
calc.add(10, -5);         // 5

// Large numbers
calc.add(1000000, 2000000);  // 3000000
```

**Edge Cases:**

```javascript
// Very small decimals
calc.add(0.0001, 0.0002);  // 0.0003

// Negative zero
calc.add(-0, 5);           // 5
calc.add(0, -0);           // 0

// Near MAX_SAFE_INTEGER
calc.add(Number.MAX_SAFE_INTEGER, 0);  // 9007199254740991
```

**Error Examples:**

```javascript
// Type errors
calc.add('5', 3);          // Error: Both arguments must be numbers
calc.add(5, null);         // Error: Both arguments must be numbers
calc.add(undefined, 5);    // Error: Both arguments must be numbers
calc.add([1], 2);          // Error: Both arguments must be numbers
calc.add({value: 5}, 3);   // Error: Both arguments must be numbers
calc.add(true, 5);         // Error: Both arguments must be numbers

// NaN errors
calc.add(NaN, 5);          // Error: Arguments cannot be NaN
calc.add(5, NaN);          // Error: Arguments cannot be NaN

// Infinity errors
calc.add(Infinity, 5);     // Error: Arguments must be finite numbers
calc.add(5, -Infinity);    // Error: Arguments must be finite numbers
```

---

### `subtract(a, b)`

Subtracts the second number from the first and returns the difference.

**Syntax:**
```javascript
calc.subtract(a, b)
```

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `a` | number | Yes | The minuend (number to subtract from) |
| `b` | number | Yes | The subtrahend (number to subtract) |

**Returns:**
- `{number}` - The difference `a - b`

**Throws:**

| Error | Condition | Error Message |
|-------|-----------|---------------|
| `Error` | Either parameter is not a number | "Both arguments must be numbers" |
| `Error` | Either parameter is NaN | "Arguments cannot be NaN" |
| `Error` | Either parameter is Infinity or -Infinity | "Arguments must be finite numbers" |

**Examples:**

```javascript
// Basic subtraction
calc.subtract(10, 4);      // 6
calc.subtract(20, 5);      // 15

// Negative result
calc.subtract(5, 10);      // -5
calc.subtract(3, 8);       // -5

// Negative numbers
calc.subtract(-5, 3);      // -8
calc.subtract(5, -3);      // 8
calc.subtract(-5, -3);     // -2

// Decimals
calc.subtract(5.5, 2.5);   // 3
calc.subtract(10.75, 3.25); // 7.5

// Zero
calc.subtract(10, 0);      // 10
calc.subtract(0, 10);      // -10
calc.subtract(0, 0);       // 0

// Same numbers (result is zero)
calc.subtract(5, 5);       // 0
calc.subtract(-5, -5);     // 0
```

**Edge Cases:**

```javascript
// Very small differences
calc.subtract(1.0001, 1.0);  // 0.00010000000000008882

// Large numbers
calc.subtract(1000000, 500000);  // 500000

// Boundary values
calc.subtract(Number.MAX_SAFE_INTEGER, 0);  // 9007199254740991
calc.subtract(0, Number.MIN_SAFE_INTEGER);  // 9007199254740991
```

**Error Examples:**

```javascript
// Type errors
calc.subtract('10', 4);    // Error: Both arguments must be numbers
calc.subtract(10, null);   // Error: Both arguments must be numbers

// NaN errors
calc.subtract(NaN, 5);     // Error: Arguments cannot be NaN

// Infinity errors
calc.subtract(Infinity, 5); // Error: Arguments must be finite numbers
```

---

### `multiply(a, b)`

Multiplies two numbers and returns the product.

**Syntax:**
```javascript
calc.multiply(a, b)
```

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `a` | number | Yes | The first factor |
| `b` | number | Yes | The second factor |

**Returns:**
- `{number}` - The product of `a` and `b`

**Throws:**

| Error | Condition | Error Message |
|-------|-----------|---------------|
| `Error` | Either parameter is not a number | "Both arguments must be numbers" |
| `Error` | Either parameter is NaN | "Arguments cannot be NaN" |
| `Error` | Either parameter is Infinity or -Infinity | "Arguments must be finite numbers" |

**Examples:**

```javascript
// Basic multiplication
calc.multiply(6, 7);       // 42
calc.multiply(5, 5);       // 25

// Negative numbers
calc.multiply(-3, 4);      // -12
calc.multiply(3, -4);      // -12
calc.multiply(-3, -4);     // 12

// Decimals
calc.multiply(2.5, 4);     // 10
calc.multiply(0.5, 0.5);   // 0.25

// Multiplication by zero
calc.multiply(5, 0);       // 0
calc.multiply(0, 5);       // 0
calc.multiply(0, 0);       // 0

// Multiplication by one
calc.multiply(5, 1);       // 5
calc.multiply(1, 5);       // 5

// Multiplication by negative one
calc.multiply(5, -1);      // -5
calc.multiply(-1, 5);      // -5
```

**Edge Cases:**

```javascript
// Very small decimals
calc.multiply(0.1, 0.1);   // 0.010000000000000002

// Fractions
calc.multiply(0.25, 0.5);  // 0.125

// Large numbers
calc.multiply(1000, 1000); // 1000000

// Near MAX_SAFE_INTEGER
calc.multiply(Number.MAX_SAFE_INTEGER, 1);  // 9007199254740991
```

**Error Examples:**

```javascript
// Type errors
calc.multiply('6', 7);     // Error: Both arguments must be numbers
calc.multiply(6, [7]);     // Error: Both arguments must be numbers

// NaN errors
calc.multiply(NaN, 5);     // Error: Arguments cannot be NaN

// Infinity errors
calc.multiply(Infinity, 5); // Error: Arguments must be finite numbers
```

---

### `divide(a, b)`

Divides the first number by the second and returns the quotient.

**Syntax:**
```javascript
calc.divide(a, b)
```

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `a` | number | Yes | The dividend (number to be divided) |
| `b` | number | Yes | The divisor (number to divide by) |

**Returns:**
- `{number}` - The quotient `a / b`

**Throws:**

| Error | Condition | Error Message |
|-------|-----------|---------------|
| `Error` | Either parameter is not a number | "Both arguments must be numbers" |
| `Error` | Either parameter is NaN | "Arguments cannot be NaN" |
| `Error` | Either parameter is Infinity or -Infinity | "Arguments must be finite numbers" |
| `Error` | Divisor (b) is zero | "Division by zero is not allowed" |

**Examples:**

```javascript
// Basic division
calc.divide(20, 4);        // 5
calc.divide(15, 3);        // 5

// Decimal results
calc.divide(7, 2);         // 3.5
calc.divide(10, 4);        // 2.5

// Negative numbers
calc.divide(-20, 4);       // -5
calc.divide(20, -4);       // -5
calc.divide(-20, -4);      // 5

// Zero as dividend
calc.divide(0, 5);         // 0
calc.divide(0, -5);        // -0

// Division by one
calc.divide(10, 1);        // 10
calc.divide(-10, 1);       // -10

// Division by negative one
calc.divide(10, -1);       // -10
calc.divide(-10, -1);      // 10

// Repeating decimals
calc.divide(1, 3);         // 0.3333333333333333
calc.divide(2, 3);         // 0.6666666666666666
```

**Edge Cases:**

```javascript
// Very small results
calc.divide(1, 1000000);   // 0.000001

// Large results
calc.divide(1000000, 2);   // 500000

// Decimal division
calc.divide(0.5, 0.25);    // 2

// Near MAX_SAFE_INTEGER
calc.divide(Number.MAX_SAFE_INTEGER, 1);  // 9007199254740991
```

**Error Examples:**

```javascript
// Division by zero errors
calc.divide(10, 0);        // Error: Division by zero is not allowed
calc.divide(0, 0);         // Error: Division by zero is not allowed
calc.divide(-10, 0);       // Error: Division by zero is not allowed

// Type errors
calc.divide('20', 4);      // Error: Both arguments must be numbers
calc.divide(20, null);     // Error: Both arguments must be numbers

// NaN errors
calc.divide(NaN, 5);       // Error: Arguments cannot be NaN
calc.divide(5, NaN);       // Error: Arguments cannot be NaN

// Infinity errors
calc.divide(Infinity, 5);  // Error: Arguments must be finite numbers
calc.divide(5, Infinity);  // Error: Arguments must be finite numbers
```

---

## Private Methods

### `_validateNumbers(a, b)`

Internal validation method called by all public methods.

**⚠️ Private Method** - Not intended for external use

**Purpose:**
- Validates that both arguments are valid numbers
- Ensures type safety
- Prevents NaN and Infinity values

**Parameters:**
- `a` (any): First value to validate
- `b` (any): Second value to validate

**Returns:**
- `{void}` - Returns nothing on success

**Throws:**
- `Error` if type check fails
- `Error` if NaN is detected
- `Error` if Infinity is detected

**Validation Logic:**
```javascript
// 1. Type check
if (typeof a !== 'number' || typeof b !== 'number')
  throw Error

// 2. NaN check
if (isNaN(a) || isNaN(b))
  throw Error

// 3. Infinity check
if (!isFinite(a) || !isFinite(b))
  throw Error
```

---

## Error Reference

### Error Messages

| Error Message | Cause | Resolution |
|---------------|-------|------------|
| "Both arguments must be numbers" | Non-number type passed | Ensure both arguments are of type `number` |
| "Arguments cannot be NaN" | NaN value passed | Check calculations that might produce NaN |
| "Arguments must be finite numbers" | Infinity or -Infinity passed | Ensure values are within finite range |
| "Division by zero is not allowed" | Attempted to divide by zero | Check divisor is not zero before calling |

### Error Handling Patterns

#### Pattern 1: Try-Catch

```javascript
try {
  const result = calc.divide(a, b);
  console.log(`Result: ${result}`);
} catch (error) {
  console.error(`Error: ${error.message}`);
}
```

#### Pattern 2: Pre-Validation

```javascript
function safeDivide(a, b) {
  if (typeof a !== 'number' || typeof b !== 'number') {
    return { error: 'Invalid types' };
  }
  if (b === 0) {
    return { error: 'Division by zero' };
  }
  return { result: calc.divide(a, b) };
}
```

#### Pattern 3: Error Wrapper

```javascript
function calculate(operation, a, b) {
  const errors = [];
  
  try {
    return { success: true, result: calc[operation](a, b) };
  } catch (error) {
    return { success: false, error: error.message };
  }
}
```

---

## Type Definitions

### TypeScript Definitions

```typescript
declare class Calculator {
  /**
   * Creates a new Calculator instance
   */
  constructor();

  /**
   * Adds two numbers
   * @param a - First number
   * @param b - Second number
   * @returns Sum of a and b
   * @throws {Error} If arguments are invalid
   */
  add(a: number, b: number): number;

  /**
   * Subtracts second number from first
   * @param a - Minuend
   * @param b - Subtrahend
   * @returns Difference of a and b
   * @throws {Error} If arguments are invalid
   */
  subtract(a: number, b: number): number;

  /**
   * Multiplies two numbers
   * @param a - First factor
   * @param b - Second factor
   * @returns Product of a and b
   * @throws {Error} If arguments are invalid
   */
  multiply(a: number, b: number): number;

  /**
   * Divides first number by second
   * @param a - Dividend
   * @param b - Divisor
   * @returns Quotient of a and b
   * @throws {Error} If arguments are invalid or b is zero
   */
  divide(a: number, b: number): number;
}

export = Calculator;
```

### JSDoc Definitions

```javascript
/**
 * @typedef {Object} Calculator
 * @property {function(number, number): number} add - Adds two numbers
 * @property {function(number, number): number} subtract - Subtracts two numbers
 * @property {function(number, number): number} multiply - Multiplies two numbers
 * @property {function(number, number): number} divide - Divides two numbers
 */
```

---

## Examples by Category

### Basic Arithmetic

```javascript
const calc = new Calculator();

// Four operations
calc.add(5, 3);        // 8
calc.subtract(10, 4);  // 6
calc.multiply(6, 7);   // 42
calc.divide(20, 4);    // 5
```

### Working with Decimals

```javascript
calc.add(0.1, 0.2);       // 0.30000000000000004
calc.subtract(5.5, 2.5);  // 3
calc.multiply(2.5, 4);    // 10
calc.divide(7, 2);        // 3.5
```

### Working with Negatives

```javascript
calc.add(-5, 3);          // -2
calc.subtract(-5, -3);    // -2
calc.multiply(-3, 4);     // -12
calc.divide(-20, 4);      // -5
```

### Chaining Operations

```javascript
const step1 = calc.add(10, 5);          // 15
const step2 = calc.multiply(step1, 2);  // 30
const result = calc.divide(step2, 3);   // 10
```

### Error Handling

```javascript
try {
  calc.divide(10, 0);
} catch (error) {
  console.error(error.message);  // "Division by zero is not allowed"
}
```

---

## Method Comparison Table

| Method | Operation | Symbol | Returns | Can Throw Division Error |
|--------|-----------|--------|---------|--------------------------|
| `add` | Addition | + | Sum | No |
| `subtract` | Subtraction | - | Difference | No |
| `multiply` | Multiplication | × | Product | No |
| `divide` | Division | ÷ | Quotient | Yes (div by zero) |

---

## Performance Characteristics

All methods have **O(1)** time complexity:

| Method | Time Complexity | Space Complexity |
|--------|----------------|------------------|
| `add` | O(1) | O(1) |
| `subtract` | O(1) | O(1) |
| `multiply` | O(1) | O(1) |
| `divide` | O(1) | O(1) |
| `_validateNumbers` | O(1) | O(1) |

---

**API Version:** 1.0.0  
**Last Updated:** 2025-12-10  
**Status:** Stable
