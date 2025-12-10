/**
 * Comprehensive test suite for Calculator module
 * Tests cover core operations, error scenarios, edge cases, and boundary conditions
 */

const { add, subtract, multiply, divide } = require('./calculator');

describe('Calculator', () => {

  describe('Addition', () => {
    describe('Core functionality', () => {
      test('should add two positive integers', () => {
        expect(add(5, 3)).toBe(8);
      });

      test('should add two negative integers', () => {
        expect(add(-5, -3)).toBe(-8);
      });

      test('should add positive and negative integers', () => {
        expect(add(-10, 25)).toBe(15);
        expect(add(10, -5)).toBe(5);
      });

      test('should add decimal numbers', () => {
        expect(add(0.1, 0.2)).toBeCloseTo(0.3, 10);
        expect(add(1.5, 2.5)).toBe(4);
      });

      test('should add zero to a number', () => {
        expect(add(0, 5)).toBe(5);
        expect(add(5, 0)).toBe(5);
        expect(add(0, 0)).toBe(0);
      });
    });

    describe('Edge cases', () => {
      test('should handle very large numbers', () => {
        expect(add(Number.MAX_SAFE_INTEGER - 1, 1)).toBe(Number.MAX_SAFE_INTEGER);
      });

      test('should handle very small numbers', () => {
        expect(add(Number.MIN_SAFE_INTEGER + 1, -1)).toBe(Number.MIN_SAFE_INTEGER);
      });

      test('should handle very small decimal numbers', () => {
        expect(add(0.000001, 0.000002)).toBeCloseTo(0.000003, 10);
      });

      test('should handle negative zero', () => {
        expect(add(-0, 5)).toBe(5);
        expect(add(5, -0)).toBe(5);
      });
    });
  });

  describe('Subtraction', () => {
    describe('Core functionality', () => {
      test('should subtract two positive integers', () => {
        expect(subtract(10, 4)).toBe(6);
      });

      test('should subtract two negative integers', () => {
        expect(subtract(-5, -3)).toBe(-2);
      });

      test('should subtract negative from positive', () => {
        expect(subtract(5, 12)).toBe(-7);
      });

      test('should subtract with decimal numbers', () => {
        expect(subtract(5.5, 2.2)).toBeCloseTo(3.3, 10);
      });

      test('should subtract zero from a number', () => {
        expect(subtract(5, 0)).toBe(5);
        expect(subtract(0, 5)).toBe(-5);
      });
    });

    describe('Edge cases', () => {
      test('should handle subtracting equal numbers', () => {
        expect(subtract(5, 5)).toBe(0);
        expect(subtract(-5, -5)).toBe(0);
      });

      test('should handle very large numbers', () => {
        expect(subtract(Number.MAX_SAFE_INTEGER, 1)).toBe(Number.MAX_SAFE_INTEGER - 1);
      });

      test('should handle very small numbers', () => {
        expect(subtract(Number.MIN_SAFE_INTEGER, -1)).toBe(Number.MIN_SAFE_INTEGER + 1);
      });
    });
  });

  describe('Multiplication', () => {
    describe('Core functionality', () => {
      test('should multiply two positive integers', () => {
        expect(multiply(6, 7)).toBe(42);
      });

      test('should multiply two negative integers', () => {
        expect(multiply(-3, -4)).toBe(12);
      });

      test('should multiply positive and negative integers', () => {
        expect(multiply(-3, 4)).toBe(-12);
        expect(multiply(3, -4)).toBe(-12);
      });

      test('should multiply decimal numbers', () => {
        expect(multiply(2.5, 4)).toBe(10);
        expect(multiply(0.5, 0.5)).toBe(0.25);
      });

      test('should multiply by zero', () => {
        expect(multiply(5, 0)).toBe(0);
        expect(multiply(0, 5)).toBe(0);
        expect(multiply(0, 0)).toBe(0);
      });

      test('should multiply by one', () => {
        expect(multiply(5, 1)).toBe(5);
        expect(multiply(1, 5)).toBe(5);
      });

      test('should multiply by negative one', () => {
        expect(multiply(5, -1)).toBe(-5);
        expect(multiply(-1, 5)).toBe(-5);
      });
    });

    describe('Edge cases', () => {
      test('should handle very large numbers', () => {
        expect(multiply(1000000, 1000000)).toBe(1000000000000);
      });

      test('should handle very small decimal numbers', () => {
        expect(multiply(0.0001, 0.0001)).toBeCloseTo(0.00000001, 10);
      });

      test('should handle fractional multiplication', () => {
        expect(multiply(0.1, 0.1)).toBeCloseTo(0.01, 10);
      });
    });
  });

  describe('Division', () => {
    describe('Core functionality', () => {
      test('should divide two positive integers', () => {
        expect(divide(20, 4)).toBe(5);
      });

      test('should divide two negative integers', () => {
        expect(divide(-20, -4)).toBe(5);
      });

      test('should divide positive by negative', () => {
        expect(divide(20, -4)).toBe(-5);
        expect(divide(-20, 4)).toBe(-5);
      });

      test('should divide with decimal results', () => {
        expect(divide(7, 2)).toBe(3.5);
        expect(divide(1, 3)).toBeCloseTo(0.333333, 5);
      });

      test('should divide zero by a number', () => {
        expect(divide(0, 5)).toBe(0);
        expect(divide(0, -5)).toBe(-0);
      });

      test('should divide by one', () => {
        expect(divide(5, 1)).toBe(5);
        expect(divide(-5, 1)).toBe(-5);
      });

      test('should divide by negative one', () => {
        expect(divide(5, -1)).toBe(-5);
        expect(divide(-5, -1)).toBe(5);
      });
    });

    describe('Edge cases', () => {
      test('should handle very large numbers', () => {
        expect(divide(1000000, 0.001)).toBe(1000000000);
      });

      test('should handle very small decimal numbers', () => {
        expect(divide(0.001, 1000)).toBeCloseTo(0.000001, 10);
      });

      test('should handle division resulting in repeating decimals', () => {
        expect(divide(10, 3)).toBeCloseTo(3.333333, 5);
      });
    });

    describe('Division by zero error', () => {
      test('should throw error when dividing by zero', () => {
        expect(() => divide(10, 0)).toThrow('Division by zero is not allowed');
      });

      test('should throw error when dividing zero by zero', () => {
        expect(() => divide(0, 0)).toThrow('Division by zero is not allowed');
      });

      test('should throw error when dividing negative number by zero', () => {
        expect(() => divide(-10, 0)).toThrow('Division by zero is not allowed');
      });
    });
  });

  describe('Input Validation', () => {
    describe('Type validation', () => {
      test('should reject string inputs in add', () => {
        expect(() => add('5', 3)).toThrow('Both arguments must be numbers');
        expect(() => add(5, '3')).toThrow('Both arguments must be numbers');
        expect(() => add('5', '3')).toThrow('Both arguments must be numbers');
      });

      test('should reject string inputs in subtract', () => {
        expect(() => subtract('10', 5)).toThrow('Both arguments must be numbers');
        expect(() => subtract(10, '5')).toThrow('Both arguments must be numbers');
      });

      test('should reject string inputs in multiply', () => {
        expect(() => multiply('3', 4)).toThrow('Both arguments must be numbers');
        expect(() => multiply(3, '4')).toThrow('Both arguments must be numbers');
      });

      test('should reject string inputs in divide', () => {
        expect(() => divide('20', 4)).toThrow('Both arguments must be numbers');
        expect(() => divide(20, '4')).toThrow('Both arguments must be numbers');
      });

      test('should reject null inputs', () => {
        expect(() => add(null, 5)).toThrow('Both arguments must be numbers');
        expect(() => add(5, null)).toThrow('Both arguments must be numbers');
      });

      test('should reject undefined inputs', () => {
        expect(() => add(undefined, 5)).toThrow('Both arguments must be numbers');
        expect(() => add(5, undefined)).toThrow('Both arguments must be numbers');
      });

      test('should reject object inputs', () => {
        expect(() => add({}, 5)).toThrow('Both arguments must be numbers');
        expect(() => add(5, {})).toThrow('Both arguments must be numbers');
      });

      test('should reject array inputs', () => {
        expect(() => add([], 5)).toThrow('Both arguments must be numbers');
        expect(() => add(5, [])).toThrow('Both arguments must be numbers');
      });

      test('should reject boolean inputs', () => {
        expect(() => add(true, 5)).toThrow('Both arguments must be numbers');
        expect(() => add(5, false)).toThrow('Both arguments must be numbers');
      });
    });

    describe('NaN validation', () => {
      test('should reject NaN in add', () => {
        expect(() => add(NaN, 5)).toThrow('Arguments cannot be NaN');
        expect(() => add(5, NaN)).toThrow('Arguments cannot be NaN');
        expect(() => add(NaN, NaN)).toThrow('Arguments cannot be NaN');
      });

      test('should reject NaN in subtract', () => {
        expect(() => subtract(NaN, 5)).toThrow('Arguments cannot be NaN');
        expect(() => subtract(5, NaN)).toThrow('Arguments cannot be NaN');
      });

      test('should reject NaN in multiply', () => {
        expect(() => multiply(NaN, 5)).toThrow('Arguments cannot be NaN');
        expect(() => multiply(5, NaN)).toThrow('Arguments cannot be NaN');
      });

      test('should reject NaN in divide', () => {
        expect(() => divide(NaN, 5)).toThrow('Arguments cannot be NaN');
        expect(() => divide(5, NaN)).toThrow('Arguments cannot be NaN');
      });
    });

    describe('Infinity validation', () => {
      test('should reject Infinity in add', () => {
        expect(() => add(Infinity, 5)).toThrow('Arguments must be finite numbers');
        expect(() => add(5, Infinity)).toThrow('Arguments must be finite numbers');
        expect(() => add(Infinity, Infinity)).toThrow('Arguments must be finite numbers');
      });

      test('should reject negative Infinity in add', () => {
        expect(() => add(-Infinity, 5)).toThrow('Arguments must be finite numbers');
        expect(() => add(5, -Infinity)).toThrow('Arguments must be finite numbers');
      });

      test('should reject Infinity in subtract', () => {
        expect(() => subtract(Infinity, 5)).toThrow('Arguments must be finite numbers');
        expect(() => subtract(5, Infinity)).toThrow('Arguments must be finite numbers');
      });

      test('should reject Infinity in multiply', () => {
        expect(() => multiply(Infinity, 5)).toThrow('Arguments must be finite numbers');
        expect(() => multiply(5, Infinity)).toThrow('Arguments must be finite numbers');
      });

      test('should reject Infinity in divide', () => {
        expect(() => divide(Infinity, 5)).toThrow('Arguments must be finite numbers');
        expect(() => divide(5, Infinity)).toThrow('Arguments must be finite numbers');
      });
    });
  });

  describe('Return Value Validation', () => {
    test('add should return a number', () => {
      expect(typeof add(5, 3)).toBe('number');
    });

    test('subtract should return a number', () => {
      expect(typeof subtract(10, 4)).toBe('number');
    });

    test('multiply should return a number', () => {
      expect(typeof multiply(6, 7)).toBe('number');
    });

    test('divide should return a number', () => {
      expect(typeof divide(20, 4)).toBe('number');
    });

    test('operations should not return NaN for valid inputs', () => {
      expect(isNaN(add(5, 3))).toBe(false);
      expect(isNaN(subtract(10, 4))).toBe(false);
      expect(isNaN(multiply(6, 7))).toBe(false);
      expect(isNaN(divide(20, 4))).toBe(false);
    });

    test('operations should not return Infinity for valid inputs', () => {
      expect(isFinite(add(5, 3))).toBe(true);
      expect(isFinite(subtract(10, 4))).toBe(true);
      expect(isFinite(multiply(6, 7))).toBe(true);
      expect(isFinite(divide(20, 4))).toBe(true);
    });
  });

  describe('Multiple Operations', () => {
    test('should handle chained operations', () => {
      const result1 = add(5, 3);
      const result2 = multiply(result1, 2);
      expect(result2).toBe(16);
    });

    test('should handle complex calculations', () => {
      // (10 + 5) * 2 - 8 / 4
      const sum = add(10, 5);
      const product = multiply(sum, 2);
      const quotient = divide(8, 4);
      const result = subtract(product, quotient);
      expect(result).toBe(28);
    });

    test('should maintain state independence between operations', () => {
      add(5, 3);
      multiply(10, 2);
      const result = subtract(15, 5);
      expect(result).toBe(10);
    });
  });

  describe('Boundary Conditions', () => {
    test('should handle Number.MAX_SAFE_INTEGER', () => {
      expect(add(Number.MAX_SAFE_INTEGER, 0)).toBe(Number.MAX_SAFE_INTEGER);
      expect(subtract(Number.MAX_SAFE_INTEGER, 0)).toBe(Number.MAX_SAFE_INTEGER);
      expect(multiply(Number.MAX_SAFE_INTEGER, 1)).toBe(Number.MAX_SAFE_INTEGER);
      expect(divide(Number.MAX_SAFE_INTEGER, 1)).toBe(Number.MAX_SAFE_INTEGER);
    });

    test('should handle Number.MIN_SAFE_INTEGER', () => {
      expect(add(Number.MIN_SAFE_INTEGER, 0)).toBe(Number.MIN_SAFE_INTEGER);
      expect(subtract(Number.MIN_SAFE_INTEGER, 0)).toBe(Number.MIN_SAFE_INTEGER);
      expect(multiply(Number.MIN_SAFE_INTEGER, 1)).toBe(Number.MIN_SAFE_INTEGER);
      expect(divide(Number.MIN_SAFE_INTEGER, 1)).toBe(Number.MIN_SAFE_INTEGER);
    });

    test('should handle Number.EPSILON', () => {
      expect(add(Number.EPSILON, Number.EPSILON)).toBeCloseTo(Number.EPSILON * 2, 20);
    });

    test('should handle numbers close to zero', () => {
      const verySmall = 1e-10;
      expect(add(verySmall, verySmall)).toBeCloseTo(2e-10, 15);
      expect(multiply(verySmall, 2)).toBeCloseTo(2e-10, 15);
    });
  });

  describe('Floating Point Precision', () => {
    test('should handle known floating point precision issues', () => {
      // JavaScript floating point quirk: 0.1 + 0.2 !== 0.3
      expect(add(0.1, 0.2)).toBeCloseTo(0.3, 10);
    });

    test('should handle decimal multiplication precision', () => {
      expect(multiply(0.1, 0.1)).toBeCloseTo(0.01, 10);
    });

    test('should handle decimal division precision', () => {
      expect(divide(1, 3)).toBeCloseTo(0.333333, 5);
    });
  });

  describe('Function Module', () => {
    test('should have all required functions', () => {
      expect(typeof add).toBe('function');
      expect(typeof subtract).toBe('function');
      expect(typeof multiply).toBe('function');
      expect(typeof divide).toBe('function');
    });

    test('functions should work independently', () => {
      const result1 = add(5, 3);
      const result2 = add(10, 20);
      
      expect(result1).toBe(8);
      expect(result2).toBe(30);
    });
  });
});
