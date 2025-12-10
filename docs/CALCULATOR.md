# Calculator Module Documentation

## Overview

The Calculator module provides a simple, robust implementation of basic arithmetic operations in Python. It offers both an object-oriented interface (via the `Calculator` class) and a functional interface (via the `calculate()` function), allowing you to choose the style that best fits your needs.

### Key Features

✅ **Four Basic Operations**: Addition, subtraction, multiplication, and division  
✅ **Dual Interface**: Choose between class-based or functional approach  
✅ **Type Flexibility**: Works seamlessly with integers, floats, and mixed types  
✅ **Error Safety**: Proper handling of division by zero and invalid operations  
✅ **Fully Typed**: Complete type hints for better IDE support  
✅ **Well Tested**: 100% test coverage with 38 comprehensive tests

---

## Quick Start

### Installation

No installation required! The calculator module is part of this repository. Simply import it:

```python
from src.calculator import Calculator, calculate
```

### Basic Usage

#### Class-Based Approach

```python
from src.calculator import Calculator

# Create a calculator instance
calc = Calculator()

# Perform operations
result = calc.add(10, 5)        # 15
result = calc.subtract(10, 5)   # 5
result = calc.multiply(10, 5)   # 50
result = calc.divide(10, 5)     # 2.0
```

#### Functional Approach

```python
from src.calculator import calculate

# Perform operations directly
result = calculate('add', 10, 5)       # 15
result = calculate('subtract', 10, 5)  # 5
result = calculate('multiply', 10, 5)  # 50
result = calculate('divide', 10, 5)    # 2.0
```

---

## Complete Usage Guide

### The Calculator Class

The `Calculator` class provides an object-oriented interface for arithmetic operations. Each operation is a method that takes two numbers and returns the result.

#### Creating a Calculator

```python
from src.calculator import Calculator

calc = Calculator()
```

The calculator has no state, so you can create one instance and reuse it throughout your application, or create new instances as needed.

#### Addition

Add two numbers together:

```python
calc.add(5, 3)       # 8
calc.add(-10, 5)     # -5
calc.add(2.5, 3.7)   # 6.2
calc.add(5, 3.5)     # 8.5 (mixed int/float)
```

#### Subtraction

Subtract the second number from the first:

```python
calc.subtract(10, 3)    # 7
calc.subtract(-5, -3)   # -2
calc.subtract(7.5, 2.5) # 5.0
calc.subtract(10, 3.5)  # 6.5
```

#### Multiplication

Multiply two numbers together:

```python
calc.multiply(4, 5)     # 20
calc.multiply(-4, 5)    # -20
calc.multiply(2.5, 4)   # 10.0
calc.multiply(3, 2.5)   # 7.5
```

#### Division

Divide the first number by the second:

```python
calc.divide(10, 2)     # 5.0
calc.divide(7, 2)      # 3.5
calc.divide(-10, 2)    # -5.0
calc.divide(7.5, 2.5)  # 3.0
```

**Important**: Division always returns a float, even when dividing integers that result in a whole number.

### The calculate() Function

The `calculate()` function provides a functional interface that's useful when you want to perform a single operation or when the operation type is determined dynamically.

#### Syntax

```python
calculate(operation, a, b)
```

- **operation** (str): The operation to perform: `'add'`, `'subtract'`, `'multiply'`, or `'divide'`
- **a** (int or float): The first operand
- **b** (int or float): The second operand
- **returns**: The result of the operation

#### Examples

```python
from src.calculator import calculate

# Basic usage
calculate('add', 10, 5)       # 15
calculate('subtract', 10, 5)  # 5
calculate('multiply', 10, 5)  # 50
calculate('divide', 10, 5)    # 2.0

# Dynamic operation selection
operations = ['add', 'subtract', 'multiply', 'divide']
for op in operations:
    result = calculate(op, 10, 5)
    print(f"{op}: {result}")

# User input
operation = input("Enter operation: ")  # User enters 'add'
num1 = float(input("First number: "))   # User enters 10
num2 = float(input("Second number: "))  # User enters 5
result = calculate(operation, num1, num2)
```

---

## Type System

The calculator supports both integers and floats and handles them seamlessly.

### Supported Types

```python
# Integers
calc.add(5, 3)          # ✓ Works

# Floats
calc.add(5.5, 3.2)      # ✓ Works

# Mixed types
calc.add(5, 3.5)        # ✓ Works
calc.multiply(3, 2.5)   # ✓ Works
```

### Return Types

- **Addition, Subtraction, Multiplication**: Returns the natural result type
  - Integer + Integer = Integer
  - Float + Float = Float
  - Integer + Float = Float

- **Division**: Always returns a float
  ```python
  calc.divide(10, 2)  # Returns 5.0 (float)
  calc.divide(7, 2)   # Returns 3.5 (float)
  ```

### Type Hints

All functions include proper type hints for better IDE support:

```python
from typing import Union

Number = Union[int, float]

def add(self, a: Number, b: Number) -> Number:
    ...
```

---

## Error Handling

The calculator provides robust error handling with clear, descriptive error messages.

### Division by Zero

Attempting to divide by zero raises a `ValueError`:

```python
from src.calculator import Calculator

calc = Calculator()

try:
    result = calc.divide(10, 0)
except ValueError as e:
    print(f"Error: {e}")
    # Output: Error: Cannot divide by zero
```

This applies to both the class method and the functional interface:

```python
from src.calculator import calculate

try:
    result = calculate('divide', 10, 0)
except ValueError as e:
    print(f"Error: {e}")
    # Output: Error: Cannot divide by zero
```

### Invalid Operations

The `calculate()` function raises a `ValueError` for invalid operation names:

```python
from src.calculator import calculate

try:
    result = calculate('power', 2, 3)
except ValueError as e:
    print(f"Error: {e}")
    # Output: Error: Unknown operation: power. Valid operations are: add, subtract, multiply, divide
```

**Note**: Operation names are case-sensitive and must be lowercase:

```python
calculate('add', 5, 3)   # ✓ Works
calculate('ADD', 5, 3)   # ✗ Raises ValueError
calculate('Add', 5, 3)   # ✗ Raises ValueError
```

### Error Handling Best Practices

Always wrap division operations in try-except blocks when the divisor might be zero:

```python
def safe_divide(a, b):
    """Safely divide two numbers with error handling."""
    try:
        return calc.divide(a, b)
    except ValueError as e:
        print(f"Division error: {e}")
        return None

# Usage
result = safe_divide(10, 0)  # Prints error, returns None
if result is not None:
    print(f"Result: {result}")
```

For the functional interface, validate operation names before calling:

```python
def safe_calculate(operation, a, b):
    """Safely perform calculations with validation."""
    valid_ops = ['add', 'subtract', 'multiply', 'divide']
    
    if operation not in valid_ops:
        print(f"Invalid operation. Choose from: {', '.join(valid_ops)}")
        return None
    
    try:
        return calculate(operation, a, b)
    except ValueError as e:
        print(f"Calculation error: {e}")
        return None
```

---

## Common Use Cases

### Building a Command-Line Calculator

```python
from src.calculator import calculate

def cli_calculator():
    """Interactive command-line calculator."""
    print("Calculator - Enter 'quit' to exit")
    print("Operations: add, subtract, multiply, divide")
    
    while True:
        operation = input("\nOperation: ").lower()
        
        if operation == 'quit':
            break
        
        if operation not in ['add', 'subtract', 'multiply', 'divide']:
            print("Invalid operation!")
            continue
        
        try:
            a = float(input("First number: "))
            b = float(input("Second number: "))
            
            result = calculate(operation, a, b)
            print(f"Result: {result}")
            
        except ValueError as e:
            print(f"Error: {e}")
        except Exception as e:
            print(f"Invalid input: {e}")

if __name__ == "__main__":
    cli_calculator()
```

### Processing Multiple Calculations

```python
from src.calculator import Calculator

calc = Calculator()

# Process a list of calculations
calculations = [
    ('add', 10, 5),
    ('subtract', 20, 8),
    ('multiply', 7, 6),
    ('divide', 100, 4),
]

results = []
for operation, a, b in calculations:
    result = calculate(operation, a, b)
    results.append(result)
    print(f"{operation}({a}, {b}) = {result}")
```

### Data Processing Pipeline

```python
from src.calculator import Calculator

calc = Calculator()

def process_data(values):
    """Process a list of values with various operations."""
    # Calculate sum
    total = values[0]
    for val in values[1:]:
        total = calc.add(total, val)
    
    # Calculate average
    count = len(values)
    average = calc.divide(total, count)
    
    return {
        'sum': total,
        'count': count,
        'average': average
    }

# Usage
data = [10, 20, 30, 40, 50]
stats = process_data(data)
print(f"Sum: {stats['sum']}, Average: {stats['average']}")
```

### Building a Calculator API

```python
from src.calculator import calculate
from flask import Flask, request, jsonify

app = Flask(__name__)

@app.route('/calculate', methods=['POST'])
def api_calculate():
    """API endpoint for calculations."""
    data = request.json
    
    operation = data.get('operation')
    a = data.get('a')
    b = data.get('b')
    
    if not all([operation, a is not None, b is not None]):
        return jsonify({'error': 'Missing parameters'}), 400
    
    try:
        result = calculate(operation, float(a), float(b))
        return jsonify({'result': result})
    except ValueError as e:
        return jsonify({'error': str(e)}), 400

if __name__ == '__main__':
    app.run(debug=True)
```

---

## Edge Cases and Limitations

### Floating Point Precision

Due to floating-point arithmetic limitations, some decimal operations may have small rounding errors:

```python
calc.add(0.1, 0.2)  # Returns 0.30000000000000004

# For precise decimal calculations, consider using Python's decimal module
from decimal import Decimal
a = Decimal('0.1')
b = Decimal('0.2')
result = a + b  # Exact: 0.3
```

### Very Large Numbers

The calculator supports very large numbers but is limited by Python's float precision:

```python
calc.multiply(10**308, 2)  # Works
calc.multiply(10**309, 2)  # May result in infinity
```

### Integer vs Float Division

Division always returns a float, which may be unexpected if you're used to integer division:

```python
calc.divide(10, 2)  # Returns 5.0, not 5

# If you need integer division, use Python's // operator separately
result = 10 // 2  # Returns 5 (integer)
```

### Case Sensitivity

The `calculate()` function is case-sensitive:

```python
calculate('add', 5, 3)   # ✓ Works
calculate('ADD', 5, 3)   # ✗ Raises ValueError
```

---

## Testing

The calculator module has been thoroughly tested with 38 comprehensive tests covering:

- ✅ All four operations with various number types
- ✅ Positive and negative numbers
- ✅ Zero handling
- ✅ Mixed integer and float operations
- ✅ Division by zero error handling
- ✅ Invalid operation error handling
- ✅ Edge cases (very large/small numbers)
- ✅ Type system validation

### Running Tests

```bash
# Install test dependencies
pip install -r requirements-test.txt

# Run all tests
pytest

# Run with coverage
pytest --cov=src --cov-report=html

# Run specific test file
pytest tests/test_calculator.py -v
```

### Test Coverage

- **Total Tests**: 38
- **Pass Rate**: 100%
- **Code Coverage**: 100%

See [TEST_REPORT.md](../TEST_REPORT.md) for detailed test results.

---

## Troubleshooting

### Common Issues

#### Issue: Import Error

```
ModuleNotFoundError: No module named 'src'
```

**Solution**: Make sure you're running Python from the repository root:

```bash
cd /path/to/agentic-workflow-test
python -c "from src.calculator import Calculator"
```

#### Issue: Division by Zero

```
ValueError: Cannot divide by zero
```

**Solution**: Always validate that the divisor is not zero before dividing, or wrap in try-except:

```python
if b != 0:
    result = calc.divide(a, b)
else:
    print("Cannot divide by zero")
```

#### Issue: Unknown Operation

```
ValueError: Unknown operation: power. Valid operations are: add, subtract, multiply, divide
```

**Solution**: Ensure you're using one of the four valid operation names (lowercase):

```python
# Valid operations
calculate('add', 5, 3)
calculate('subtract', 5, 3)
calculate('multiply', 5, 3)
calculate('divide', 5, 3)
```

---

## Next Steps

- See [API_REFERENCE.md](API_REFERENCE.md) for complete API documentation
- Check [TEST_REPORT.md](../TEST_REPORT.md) for detailed test results
- Review [examples/](../examples/) for more code samples

---

## Support

For questions, issues, or contributions:
- Review the test suite in `tests/test_calculator.py` for usage examples
- Check the inline documentation in `src/calculator.py`
- See the main [README.md](../README.md) for repository information

---

*Last Updated: 2025-12-10*  
*Version: 1.0.0*  
*Test Coverage: 100% (38/38 tests passing)*
