"""
Comprehensive test suite for the Calculator module.

This test suite validates all arithmetic operations, edge cases,
error handling, and the functional interface of the calculator.
"""

import pytest
from src.calculator import Calculator, calculate


class TestCalculatorClass:
    """Test suite for the Calculator class."""
    
    def setup_method(self):
        """Set up test fixtures."""
        self.calc = Calculator()
    
    # Addition Tests
    def test_add_positive_integers(self):
        """Test addition of two positive integers."""
        assert self.calc.add(5, 3) == 8
        assert self.calc.add(10, 20) == 30
        assert self.calc.add(1, 1) == 2
    
    def test_add_negative_integers(self):
        """Test addition with negative integers."""
        assert self.calc.add(-5, -3) == -8
        assert self.calc.add(-10, 5) == -5
        assert self.calc.add(10, -5) == 5
    
    def test_add_floats(self):
        """Test addition with floating point numbers."""
        assert self.calc.add(5.5, 3.2) == pytest.approx(8.7)
        assert self.calc.add(0.1, 0.2) == pytest.approx(0.3)
        assert self.calc.add(-2.5, 1.5) == pytest.approx(-1.0)
    
    def test_add_mixed_types(self):
        """Test addition with mixed integer and float types."""
        assert self.calc.add(5, 3.5) == 8.5
        assert self.calc.add(10.5, 2) == 12.5
    
    def test_add_zero(self):
        """Test addition with zero."""
        assert self.calc.add(0, 5) == 5
        assert self.calc.add(5, 0) == 5
        assert self.calc.add(0, 0) == 0
    
    # Subtraction Tests
    def test_subtract_positive_integers(self):
        """Test subtraction of positive integers."""
        assert self.calc.subtract(10, 3) == 7
        assert self.calc.subtract(20, 5) == 15
        assert self.calc.subtract(5, 5) == 0
    
    def test_subtract_negative_integers(self):
        """Test subtraction with negative integers."""
        assert self.calc.subtract(-5, -3) == -2
        assert self.calc.subtract(-10, 5) == -15
        assert self.calc.subtract(10, -5) == 15
    
    def test_subtract_floats(self):
        """Test subtraction with floating point numbers."""
        assert self.calc.subtract(5.5, 3.2) == pytest.approx(2.3)
        assert self.calc.subtract(10.0, 2.5) == pytest.approx(7.5)
        assert self.calc.subtract(-2.5, 1.5) == pytest.approx(-4.0)
    
    def test_subtract_mixed_types(self):
        """Test subtraction with mixed integer and float types."""
        assert self.calc.subtract(10, 3.5) == 6.5
        assert self.calc.subtract(10.5, 2) == 8.5
    
    def test_subtract_zero(self):
        """Test subtraction with zero."""
        assert self.calc.subtract(5, 0) == 5
        assert self.calc.subtract(0, 5) == -5
        assert self.calc.subtract(0, 0) == 0
    
    # Multiplication Tests
    def test_multiply_positive_integers(self):
        """Test multiplication of positive integers."""
        assert self.calc.multiply(4, 5) == 20
        assert self.calc.multiply(10, 3) == 30
        assert self.calc.multiply(2, 2) == 4
    
    def test_multiply_negative_integers(self):
        """Test multiplication with negative integers."""
        assert self.calc.multiply(-4, 5) == -20
        assert self.calc.multiply(-4, -5) == 20
        assert self.calc.multiply(4, -5) == -20
    
    def test_multiply_floats(self):
        """Test multiplication with floating point numbers."""
        assert self.calc.multiply(2.5, 4.0) == pytest.approx(10.0)
        assert self.calc.multiply(0.5, 0.5) == pytest.approx(0.25)
        assert self.calc.multiply(-2.5, 2.0) == pytest.approx(-5.0)
    
    def test_multiply_mixed_types(self):
        """Test multiplication with mixed integer and float types."""
        assert self.calc.multiply(5, 2.5) == 12.5
        assert self.calc.multiply(3.5, 2) == 7.0
    
    def test_multiply_by_zero(self):
        """Test multiplication by zero."""
        assert self.calc.multiply(5, 0) == 0
        assert self.calc.multiply(0, 5) == 0
        assert self.calc.multiply(0, 0) == 0
    
    def test_multiply_by_one(self):
        """Test multiplication by one (identity)."""
        assert self.calc.multiply(5, 1) == 5
        assert self.calc.multiply(1, 5) == 5
        assert self.calc.multiply(-5, 1) == -5
    
    # Division Tests
    def test_divide_positive_integers(self):
        """Test division of positive integers."""
        assert self.calc.divide(10, 2) == 5.0
        assert self.calc.divide(20, 4) == 5.0
        assert self.calc.divide(7, 2) == 3.5
    
    def test_divide_negative_integers(self):
        """Test division with negative integers."""
        assert self.calc.divide(-10, 2) == -5.0
        assert self.calc.divide(10, -2) == -5.0
        assert self.calc.divide(-10, -2) == 5.0
    
    def test_divide_floats(self):
        """Test division with floating point numbers."""
        assert self.calc.divide(5.0, 2.0) == pytest.approx(2.5)
        assert self.calc.divide(7.5, 2.5) == pytest.approx(3.0)
        assert self.calc.divide(1.0, 3.0) == pytest.approx(0.333333, rel=1e-5)
    
    def test_divide_mixed_types(self):
        """Test division with mixed integer and float types."""
        assert self.calc.divide(10, 2.5) == 4.0
        assert self.calc.divide(7.5, 3) == 2.5
    
    def test_divide_by_one(self):
        """Test division by one (identity)."""
        assert self.calc.divide(5, 1) == 5.0
        assert self.calc.divide(-5, 1) == -5.0
        assert self.calc.divide(3.5, 1) == 3.5
    
    def test_divide_zero_by_number(self):
        """Test division of zero by a number."""
        assert self.calc.divide(0, 5) == 0.0
        assert self.calc.divide(0, -5) == 0.0
        assert self.calc.divide(0, 3.5) == 0.0
    
    def test_divide_by_zero_raises_error(self):
        """Test that division by zero raises ValueError."""
        with pytest.raises(ValueError, match="Cannot divide by zero"):
            self.calc.divide(10, 0)
        
        with pytest.raises(ValueError, match="Cannot divide by zero"):
            self.calc.divide(0, 0)
        
        with pytest.raises(ValueError, match="Cannot divide by zero"):
            self.calc.divide(-10, 0)
        
        with pytest.raises(ValueError, match="Cannot divide by zero"):
            self.calc.divide(5.5, 0)


class TestCalculateFunction:
    """Test suite for the calculate() functional interface."""
    
    # Test valid operations
    def test_calculate_add(self):
        """Test calculate function with addition."""
        assert calculate('add', 5, 3) == 8
        assert calculate('add', -5, 3) == -2
        assert calculate('add', 2.5, 1.5) == 4.0
    
    def test_calculate_subtract(self):
        """Test calculate function with subtraction."""
        assert calculate('subtract', 10, 3) == 7
        assert calculate('subtract', -5, 3) == -8
        assert calculate('subtract', 5.5, 2.5) == 3.0
    
    def test_calculate_multiply(self):
        """Test calculate function with multiplication."""
        assert calculate('multiply', 4, 5) == 20
        assert calculate('multiply', -4, 5) == -20
        assert calculate('multiply', 2.5, 4) == 10.0
    
    def test_calculate_divide(self):
        """Test calculate function with division."""
        assert calculate('divide', 10, 2) == 5.0
        assert calculate('divide', -10, 2) == -5.0
        assert calculate('divide', 7.5, 3) == 2.5
    
    # Test error handling
    def test_calculate_division_by_zero(self):
        """Test that calculate function handles division by zero."""
        with pytest.raises(ValueError, match="Cannot divide by zero"):
            calculate('divide', 10, 0)
    
    def test_calculate_invalid_operation(self):
        """Test that calculate function raises error for invalid operations."""
        with pytest.raises(ValueError, match="Unknown operation"):
            calculate('power', 2, 3)
        
        with pytest.raises(ValueError, match="Unknown operation"):
            calculate('modulo', 10, 3)
        
        with pytest.raises(ValueError, match="Unknown operation"):
            calculate('', 5, 3)
    
    def test_calculate_invalid_operation_message(self):
        """Test that invalid operation error includes helpful message."""
        with pytest.raises(ValueError, match="Valid operations are"):
            calculate('invalid', 1, 2)
    
    def test_calculate_case_sensitivity(self):
        """Test that operation names are case-sensitive."""
        # These should fail because operations must be lowercase
        with pytest.raises(ValueError):
            calculate('ADD', 5, 3)
        
        with pytest.raises(ValueError):
            calculate('Add', 5, 3)


class TestEdgeCases:
    """Test suite for edge cases and boundary conditions."""
    
    def setup_method(self):
        """Set up test fixtures."""
        self.calc = Calculator()
    
    def test_very_large_numbers(self):
        """Test operations with very large numbers."""
        large_num = 10**15
        assert self.calc.add(large_num, 1) == large_num + 1
        assert self.calc.multiply(large_num, 2) == large_num * 2
    
    def test_very_small_numbers(self):
        """Test operations with very small decimal numbers."""
        small_num = 0.0000001
        assert self.calc.add(small_num, small_num) == pytest.approx(2 * small_num)
        assert self.calc.multiply(small_num, 2) == pytest.approx(2 * small_num)
    
    def test_negative_zero(self):
        """Test operations with negative zero."""
        assert self.calc.add(-0.0, 0.0) == 0.0
        assert self.calc.subtract(-0.0, 0.0) == 0.0
    
    def test_operations_preserve_type_behavior(self):
        """Test that operations follow Python's type behavior."""
        # Integer division should return float
        assert isinstance(self.calc.divide(10, 2), float)
        
        # Integer operations should return integer when possible
        assert isinstance(self.calc.add(5, 3), int)
        assert isinstance(self.calc.multiply(5, 3), int)


class TestTypeHints:
    """Test that the calculator properly handles types as documented."""
    
    def test_accepts_integers(self):
        """Test that all operations accept integers."""
        calc = Calculator()
        assert calc.add(1, 2) == 3
        assert calc.subtract(5, 2) == 3
        assert calc.multiply(3, 4) == 12
        assert calc.divide(10, 2) == 5.0
    
    def test_accepts_floats(self):
        """Test that all operations accept floats."""
        calc = Calculator()
        assert calc.add(1.5, 2.5) == 4.0
        assert calc.subtract(5.5, 2.5) == 3.0
        assert calc.multiply(3.0, 4.0) == 12.0
        assert calc.divide(10.0, 2.0) == 5.0
    
    def test_calculate_accepts_integers_and_floats(self):
        """Test that calculate function accepts both integers and floats."""
        assert calculate('add', 1, 2) == 3
        assert calculate('add', 1.5, 2.5) == 4.0
        assert calculate('divide', 10, 2) == 5.0
        assert calculate('divide', 10.0, 2.0) == 5.0


if __name__ == "__main__":
    pytest.main([__file__, "-v", "--tb=short"])
