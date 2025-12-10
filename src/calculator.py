"""
Calculator module providing basic arithmetic operations.

This module implements a Calculator class with support for addition, subtraction,
multiplication, and division operations with proper error handling.
"""

from typing import Union

Number = Union[int, float]


class Calculator:
    """
    A simple calculator class that supports basic arithmetic operations.
    
    This class provides methods for addition, subtraction, multiplication,
    and division with proper error handling for edge cases like division by zero.
    """
    
    def add(self, a: Number, b: Number) -> Number:
        """
        Add two numbers together.
        
        Args:
            a: The first number
            b: The second number
            
        Returns:
            The sum of a and b
            
        Example:
            >>> calc = Calculator()
            >>> calc.add(5, 3)
            8
        """
        return a + b
    
    def subtract(self, a: Number, b: Number) -> Number:
        """
        Subtract the second number from the first.
        
        Args:
            a: The number to subtract from
            b: The number to subtract
            
        Returns:
            The difference of a and b
            
        Example:
            >>> calc = Calculator()
            >>> calc.subtract(10, 3)
            7
        """
        return a - b
    
    def multiply(self, a: Number, b: Number) -> Number:
        """
        Multiply two numbers together.
        
        Args:
            a: The first number
            b: The second number
            
        Returns:
            The product of a and b
            
        Example:
            >>> calc = Calculator()
            >>> calc.multiply(4, 5)
            20
        """
        return a * b
    
    def divide(self, a: Number, b: Number) -> Number:
        """
        Divide the first number by the second.
        
        Args:
            a: The dividend (number to be divided)
            b: The divisor (number to divide by)
            
        Returns:
            The quotient of a divided by b
            
        Raises:
            ValueError: If b is zero (division by zero)
            
        Example:
            >>> calc = Calculator()
            >>> calc.divide(10, 2)
            5.0
            >>> calc.divide(10, 0)
            Traceback (most recent call last):
                ...
            ValueError: Cannot divide by zero
        """
        if b == 0:
            raise ValueError("Cannot divide by zero")
        return a / b


def calculate(operation: str, a: Number, b: Number) -> Number:
    """
    Perform a calculation based on the specified operation.
    
    This is a convenience function that provides a functional interface
    to the Calculator class.
    
    Args:
        operation: The operation to perform ('add', 'subtract', 'multiply', 'divide')
        a: The first operand
        b: The second operand
        
    Returns:
        The result of the operation
        
    Raises:
        ValueError: If the operation is not recognized or division by zero occurs
        
    Example:
        >>> calculate('add', 5, 3)
        8
        >>> calculate('divide', 10, 2)
        5.0
        >>> calculate('divide', 10, 0)
        Traceback (most recent call last):
            ...
        ValueError: Cannot divide by zero
    """
    calc = Calculator()
    
    operations = {
        'add': calc.add,
        'subtract': calc.subtract,
        'multiply': calc.multiply,
        'divide': calc.divide,
    }
    
    if operation not in operations:
        raise ValueError(
            f"Unknown operation: {operation}. "
            f"Valid operations are: {', '.join(operations.keys())}"
        )
    
    return operations[operation](a, b)


if __name__ == "__main__":
    # Example usage
    calc = Calculator()
    
    print("Calculator Demo")
    print("=" * 50)
    print(f"Addition: 10 + 5 = {calc.add(10, 5)}")
    print(f"Subtraction: 10 - 5 = {calc.subtract(10, 5)}")
    print(f"Multiplication: 10 * 5 = {calc.multiply(10, 5)}")
    print(f"Division: 10 / 5 = {calc.divide(10, 5)}")
    print()
    
    # Demonstrate error handling
    print("Error Handling Demo")
    print("=" * 50)
    try:
        result = calc.divide(10, 0)
    except ValueError as e:
        print(f"Error caught: {e}")
    
    # Demonstrate functional interface
    print()
    print("Functional Interface Demo")
    print("=" * 50)
    print(f"calculate('add', 7, 3) = {calculate('add', 7, 3)}")
    print(f"calculate('multiply', 4, 6) = {calculate('multiply', 4, 6)}")
