# Calculator API Reference

Complete API reference for the Calculator module.

---

## Module: `src.calculator`

### Type Definitions

```python
from typing import Union

Number = Union[int, float]
```

**Number**: Type alias for values that can be either integers or floats.

---

## Class: `Calculator`

```python
class Calculator:
    """
    A simple calculator class that supports basic arithmetic operations.
    
    This class provides methods for addition, subtraction, multiplication,
    and division with proper error handling for edge cases like division by zero.
    """
```

### Constructor

```python
Calculator()
```

Creates a new Calculator instance.

**Parameters**: None

**Returns**: A new `Calculator` object

**Example**:
```python
from src.calculator import Calculator

calc = Calculator()
```

**Note**: The Calculator class is stateless, so you can create multiple instances or reuse a single instance throughout your application.

---

### Method: `add`

```python
def add(self, a: Number, b: Number) -> Number
```

Add two numbers together.

**Parameters**:
- `a` (int or float): The first number
- `b` (int or float): The second number

**Returns**: 
- (int or float): The sum of `a` and `b`

**Raises**: None

**Type Behavior**:
- `int + int → int`
- `float + float → float`
- `int + float → float`

**Examples**:
```python
calc = Calculator()

# Integers
calc.add(5, 3)        # Returns: 8

# Floats
calc.add(5.5, 3.2)    # Returns: 8.7

# Mixed types
calc.add(5, 3.5)      # Returns: 8.5

# Negative numbers
calc.add(-10, 5)      # Returns: -5
calc.add(-5, -3)      # Returns: -8

# With zero
calc.add(0, 5)        # Returns: 5
calc.add(5, 0)        # Returns: 5
```

---

### Method: `subtract`

```python
def subtract(self, a: Number, b: Number) -> Number
```

Subtract the second number from the first.

**Parameters**:
- `a` (int or float): The number to subtract from (minuend)
- `b` (int or float): The number to subtract (subtrahend)

**Returns**: 
- (int or float): The difference `a - b`

**Raises**: None

**Type Behavior**:
- `int - int → int`
- `float - float → float`
- `int - float → float`

**Examples**:
```python
calc = Calculator()

# Integers
calc.subtract(10, 3)      # Returns: 7

# Floats
calc.subtract(7.5, 2.5)   # Returns: 5.0

# Mixed types
calc.subtract(10, 3.5)    # Returns: 6.5

# Negative numbers
calc.subtract(-5, -3)     # Returns: -2
calc.subtract(10, -5)     # Returns: 15

# With zero
calc.subtract(5, 0)       # Returns: 5
calc.subtract(0, 5)       # Returns: -5

# Result is zero
calc.subtract(5, 5)       # Returns: 0
```

---

### Method: `multiply`

```python
def multiply(self, a: Number, b: Number) -> Number
```

Multiply two numbers together.

**Parameters**:
- `a` (int or float): The first factor
- `b` (int or float): The second factor

**Returns**: 
- (int or float): The product `a * b`

**Raises**: None

**Type Behavior**:
- `int * int → int`
- `float * float → float`
- `int * float → float`

**Examples**:
```python
calc = Calculator()

# Integers
calc.multiply(4, 5)       # Returns: 20

# Floats
calc.multiply(2.5, 4.0)   # Returns: 10.0

# Mixed types
calc.multiply(5, 2.5)     # Returns: 12.5

# Negative numbers
calc.multiply(-4, 5)      # Returns: -20
calc.multiply(-4, -5)     # Returns: 20

# Multiplication by zero
calc.multiply(5, 0)       # Returns: 0
calc.multiply(0, 5)       # Returns: 0

# Identity (multiply by one)
calc.multiply(5, 1)       # Returns: 5
calc.multiply(-5, 1)      # Returns: -5
```

---

### Method: `divide`

```python
def divide(self, a: Number, b: Number) -> Number
```

Divide the first number by the second.

**Parameters**:
- `a` (int or float): The dividend (number to be divided)
- `b` (int or float): The divisor (number to divide by)

**Returns**: 
- (float): The quotient `a / b` (always returns float)

**Raises**: 
- `ValueError`: If `b` is zero (division by zero)

**Type Behavior**:
- Always returns `float`, regardless of input types
- `10 / 2 → 5.0` (not `5`)

**Examples**:
```python
calc = Calculator()

# Integers (returns float)
calc.divide(10, 2)        # Returns: 5.0
calc.divide(7, 2)         # Returns: 3.5

# Floats
calc.divide(7.5, 2.5)     # Returns: 3.0

# Mixed types
calc.divide(10, 2.5)      # Returns: 4.0

# Negative numbers
calc.divide(-10, 2)       # Returns: -5.0
calc.divide(10, -2)       # Returns: -5.0
calc.divide(-10, -2)      # Returns: 5.0

# Zero as dividend
calc.divide(0, 5)         # Returns: 0.0

# Identity (divide by one)
calc.divide(5, 1)         # Returns: 5.0

# Division by zero (raises error)
try:
    calc.divide(10, 0)
except ValueError as e:
    print(e)  # "Cannot divide by zero"
```

**Error Message**: `"Cannot divide by zero"`

---

## Function: `calculate`

```python
def calculate(operation: str, a: Number, b: Number) -> Number
```

Perform a calculation based on the specified operation. This is a convenience function that provides a functional interface to the Calculator class.

**Parameters**:
- `operation` (str): The operation to perform. Must be one of:
  - `'add'` - Addition
  - `'subtract'` - Subtraction
  - `'multiply'` - Multiplication
  - `'divide'` - Division
- `a` (int or float): The first operand
- `b` (int or float): The second operand

**Returns**: 
- (int or float): The result of the operation

**Raises**: 
- `ValueError`: If `operation` is not recognized
- `ValueError`: If division by zero occurs (when `operation='divide'` and `b=0`)

**Important Notes**:
- Operation names are **case-sensitive** and must be lowercase
- Each call creates a new Calculator instance internally
- For multiple operations, consider using the Calculator class directly for better performance

**Valid Operations**:
| Operation | Description | Example |
|-----------|-------------|---------|
| `'add'` | Addition | `calculate('add', 5, 3) → 8` |
| `'subtract'` | Subtraction | `calculate('subtract', 5, 3) → 2` |
| `'multiply'` | Multiplication | `calculate('multiply', 5, 3) → 15` |
| `'divide'` | Division | `calculate('divide', 6, 3) → 2.0` |

**Examples**:
```python
from src.calculator import calculate

# Basic operations
calculate('add', 10, 5)       # Returns: 15
calculate('subtract', 10, 5)  # Returns: 5
calculate('multiply', 10, 5)  # Returns: 50
calculate('divide', 10, 5)    # Returns: 2.0

# With floats
calculate('add', 5.5, 3.2)    # Returns: 8.7
calculate('divide', 7.5, 2.5) # Returns: 3.0

# With negative numbers
calculate('add', -5, 3)       # Returns: -2
calculate('multiply', -4, 5)  # Returns: -20

# Dynamic operation selection
operation = 'add'
result = calculate(operation, 10, 5)

# Error: Division by zero
try:
    calculate('divide', 10, 0)
except ValueError as e:
    print(e)  # "Cannot divide by zero"

# Error: Invalid operation
try:
    calculate('power', 2, 3)
except ValueError as e:
    print(e)  # "Unknown operation: power. Valid operations are: add, subtract, multiply, divide"

# Error: Case sensitivity
try:
    calculate('ADD', 5, 3)  # Must be lowercase
except ValueError as e:
    print(e)  # "Unknown operation: ADD. Valid operations are: add, subtract, multiply, divide"
```

**Error Messages**:
- Invalid operation: `"Unknown operation: {operation}. Valid operations are: add, subtract, multiply, divide"`
- Division by zero: `"Cannot divide by zero"`

---

## Usage Patterns

### Pattern 1: Class-Based (Multiple Operations)

Use the Calculator class when performing multiple operations:

```python
from src.calculator import Calculator

calc = Calculator()

# Perform multiple operations
result1 = calc.add(10, 5)
result2 = calc.subtract(result1, 3)
result3 = calc.multiply(result2, 2)
final = calc.divide(result3, 4)
```

**Advantages**:
- Create the calculator instance once
- Clearer object-oriented style
- Better performance for multiple operations

### Pattern 2: Functional (Single Operations)

Use the calculate() function for single operations or dynamic operation selection:

```python
from src.calculator import calculate

# Single operation
total = calculate('add', 10, 5)

# Dynamic operation
operation = user_input()  # Gets 'add', 'subtract', etc.
result = calculate(operation, 10, 5)
```

**Advantages**:
- More concise for single operations
- Easy to use with dynamic operation names
- Functional programming style

### Pattern 3: Error Handling

Always handle potential errors:

```python
from src.calculator import calculate

def safe_calculate(operation, a, b):
    """Wrapper with error handling."""
    try:
        return calculate(operation, a, b)
    except ValueError as e:
        print(f"Error: {e}")
        return None

result = safe_calculate('divide', 10, 0)
if result is not None:
    print(f"Result: {result}")
```

---

## Type Information

### Type Hints

All functions include complete type hints:

```python
from typing import Union

Number = Union[int, float]

class Calculator:
    def add(self, a: Number, b: Number) -> Number: ...
    def subtract(self, a: Number, b: Number) -> Number: ...
    def multiply(self, a: Number, b: Number) -> Number: ...
    def divide(self, a: Number, b: Number) -> Number: ...

def calculate(operation: str, a: Number, b: Number) -> Number: ...
```

### Type Behavior Summary

| Method | Input Types | Return Type | Notes |
|--------|-------------|-------------|-------|
| `add()` | `int`, `int` | `int` | |
| `add()` | `float`, `float` | `float` | |
| `add()` | `int`, `float` | `float` | |
| `subtract()` | `int`, `int` | `int` | |
| `subtract()` | `float`, `float` | `float` | |
| `subtract()` | `int`, `float` | `float` | |
| `multiply()` | `int`, `int` | `int` | |
| `multiply()` | `float`, `float` | `float` | |
| `multiply()` | `int`, `float` | `float` | |
| `divide()` | Any | `float` | Always returns float |

---

## Error Reference

### ValueError: Cannot divide by zero

**Cause**: Attempting to divide by zero

**Raised by**: 
- `Calculator.divide(a, 0)`
- `calculate('divide', a, 0)`

**Example**:
```python
calc.divide(10, 0)  # Raises ValueError
```

**Solution**: Validate divisor before dividing or use try-except

---

### ValueError: Unknown operation

**Cause**: Invalid operation name passed to `calculate()`

**Raised by**: `calculate(invalid_operation, a, b)`

**Example**:
```python
calculate('power', 2, 3)  # Raises ValueError
calculate('ADD', 5, 3)    # Raises ValueError (case-sensitive)
```

**Solution**: Use valid operation names: `'add'`, `'subtract'`, `'multiply'`, `'divide'`

---

## Performance Notes

- All operations are O(1) constant time
- The Calculator class has no state, so instances are lightweight
- The `calculate()` function creates a new Calculator instance on each call
- For multiple operations, use the Calculator class directly to avoid repeated instantiation

---

## Compatibility

- **Python Version**: 3.6+ (requires type hints support)
- **Dependencies**: None (uses only Python standard library)
- **Operating Systems**: Cross-platform (Windows, macOS, Linux)

---

## See Also

- [CALCULATOR.md](CALCULATOR.md) - Complete user guide with examples
- [TEST_REPORT.md](../TEST_REPORT.md) - Detailed test results
- [Source Code](../src/calculator.py) - Implementation with inline documentation

---

*Last Updated: 2025-12-10*  
*Version: 1.0.0*
