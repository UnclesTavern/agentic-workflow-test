/**
 * Comprehensive test suite for Calculator module
 * Tests cover core operations, error scenarios, edge cases, and boundary conditions
 */

const Calculator = require('./calculator');

describe('Calculator', () => {
  let calc;

  beforeEach(() => {
    calc = new Calculator();
  });

  describe('Addition', () => {
    describe('Core functionality', () => {
      test('should add two positive integers', () => {
        expect(calc.add(5, 3)).toBe(8);
      });

      test('should add two negative integers', () => {
        expect(calc.add(-5, -3)).toBe(-8);
      });

      test('should add positive and negative integers', () => {
        expect(calc.add(-10, 25)).toBe(15);
        expect(calc.add(10, -5)).toBe(5);
      });

      test('should add decimal numbers', () => {
        expect(calc.add(0.1, 0.2)).toBeCloseTo(0.3, 10);
        expect(calc.add(1.5, 2.5)).toBe(4);
      });

      test('should add zero to a number', () => {
        expect(calc.add(0, 5)).toBe(5);
        expect(calc.add(5, 0)).toBe(5);
        expect(calc.add(0, 0)).toBe(0);
      });
    });

    describe('Edge cases', () => {
      test('should handle very large numbers', () => {
        expect(calc.add(Number.MAX_SAFE_INTEGER - 1, 1)).toBe(Number.MAX_SAFE_INTEGER);
      });

      test('should handle very small numbers', () => {
        expect(calc.add(Number.MIN_SAFE_INTEGER + 1, -1)).toBe(Number.MIN_SAFE_INTEGER);
      });

      test('should handle very small decimal numbers', () => {
        expect(calc.add(0.000001, 0.000002)).toBeCloseTo(0.000003, 10);
      });

      test('should handle negative zero', () => {
        expect(calc.add(-0, 5)).toBe(5);
        expect(calc.add(5, -0)).toBe(5);
      });
    });
  });

  describe('Subtraction', () => {
    describe('Core functionality', () => {
      test('should subtract two positive integers', () => {
        expect(calc.subtract(10, 4)).toBe(6);
      });

      test('should subtract two negative integers', () => {
        expect(calc.subtract(-5, -3)).toBe(-2);
      });

      test('should subtract negative from positive', () => {
        expect(calc.subtract(5, 12)).toBe(-7);
      });

      test('should subtract with decimal numbers', () => {
        expect(calc.subtract(5.5, 2.2)).toBeCloseTo(3.3, 10);
      });

      test('should subtract zero from a number', () => {
        expect(calc.subtract(5, 0)).toBe(5);
        expect(calc.subtract(0, 5)).toBe(-5);
      });
    });

    describe('Edge cases', () => {
      test('should handle subtracting equal numbers', () => {
        expect(calc.subtract(5, 5)).toBe(0);
        expect(calc.subtract(-5, -5)).toBe(0);
      });

      test('should handle very large numbers', () => {
        expect(calc.subtract(Number.MAX_SAFE_INTEGER, 1)).toBe(Number.MAX_SAFE_INTEGER - 1);
      });

      test('should handle very small numbers', () => {
        expect(calc.subtract(Number.MIN_SAFE_INTEGER, -1)).toBe(Number.MIN_SAFE_INTEGER + 1);
      });
    });
  });

  describe('Multiplication', () => {
    describe('Core functionality', () => {
      test('should multiply two positive integers', () => {
        expect(calc.multiply(6, 7)).toBe(42);
      });

      test('should multiply two negative integers', () => {
        expect(calc.multiply(-3, -4)).toBe(12);
      });

      test('should multiply positive and negative integers', () => {
        expect(calc.multiply(-3, 4)).toBe(-12);
        expect(calc.multiply(3, -4)).toBe(-12);
      });

      test('should multiply decimal numbers', () => {
        expect(calc.multiply(2.5, 4)).toBe(10);
        expect(calc.multiply(0.5, 0.5)).toBe(0.25);
      });

      test('should multiply by zero', () => {
        expect(calc.multiply(5, 0)).toBe(0);
        expect(calc.multiply(0, 5)).toBe(0);
        expect(calc.multiply(0, 0)).toBe(0);
      });

      test('should multiply by one', () => {
        expect(calc.multiply(5, 1)).toBe(5);
        expect(calc.multiply(1, 5)).toBe(5);
      });

      test('should multiply by negative one', () => {
        expect(calc.multiply(5, -1)).toBe(-5);
        expect(calc.multiply(-1, 5)).toBe(-5);
      });
    });

    describe('Edge cases', () => {
      test('should handle very large numbers', () => {
        expect(calc.multiply(1000000, 1000000)).toBe(1000000000000);
      });

      test('should handle very small decimal numbers', () => {
        expect(calc.multiply(0.0001, 0.0001)).toBeCloseTo(0.00000001, 10);
      });

      test('should handle fractional multiplication', () => {
        expect(calc.multiply(0.1, 0.1)).toBeCloseTo(0.01, 10);
      });
    });
  });

  describe('Division', () => {
    describe('Core functionality', () => {
      test('should divide two positive integers', () => {
        expect(calc.divide(20, 4)).toBe(5);
      });

      test('should divide two negative integers', () => {
        expect(calc.divide(-20, -4)).toBe(5);
      });

      test('should divide positive by negative', () => {
        expect(calc.divide(20, -4)).toBe(-5);
        expect(calc.divide(-20, 4)).toBe(-5);
      });

      test('should divide with decimal results', () => {
        expect(calc.divide(7, 2)).toBe(3.5);
        expect(calc.divide(1, 3)).toBeCloseTo(0.333333, 5);
      });

      test('should divide zero by a number', () => {
        expect(calc.divide(0, 5)).toBe(0);
        expect(calc.divide(0, -5)).toBe(-0);
      });

      test('should divide by one', () => {
        expect(calc.divide(5, 1)).toBe(5);
        expect(calc.divide(-5, 1)).toBe(-5);
      });

      test('should divide by negative one', () => {
        expect(calc.divide(5, -1)).toBe(-5);
        expect(calc.divide(-5, -1)).toBe(5);
      });
    });

    describe('Edge cases', () => {
      test('should handle very large numbers', () => {
        expect(calc.divide(1000000, 0.001)).toBe(1000000000);
      });

      test('should handle very small decimal numbers', () => {
        expect(calc.divide(0.001, 1000)).toBeCloseTo(0.000001, 10);
      });

      test('should handle division resulting in repeating decimals', () => {
        expect(calc.divide(10, 3)).toBeCloseTo(3.333333, 5);
      });
    });

    describe('Division by zero error', () => {
      test('should throw error when dividing by zero', () => {
        expect(() => calc.divide(10, 0)).toThrow('Division by zero is not allowed');
      });

      test('should throw error when dividing zero by zero', () => {
        expect(() => calc.divide(0, 0)).toThrow('Division by zero is not allowed');
      });

      test('should throw error when dividing negative number by zero', () => {
        expect(() => calc.divide(-10, 0)).toThrow('Division by zero is not allowed');
      });
    });
  });

  describe('Input Validation', () => {
    describe('Type validation', () => {
      test('should reject string inputs in add', () => {
        expect(() => calc.add('5', 3)).toThrow('Both arguments must be numbers');
        expect(() => calc.add(5, '3')).toThrow('Both arguments must be numbers');
        expect(() => calc.add('5', '3')).toThrow('Both arguments must be numbers');
      });

      test('should reject string inputs in subtract', () => {
        expect(() => calc.subtract('10', 5)).toThrow('Both arguments must be numbers');
        expect(() => calc.subtract(10, '5')).toThrow('Both arguments must be numbers');
      });

      test('should reject string inputs in multiply', () => {
        expect(() => calc.multiply('3', 4)).toThrow('Both arguments must be numbers');
        expect(() => calc.multiply(3, '4')).toThrow('Both arguments must be numbers');
      });

      test('should reject string inputs in divide', () => {
        expect(() => calc.divide('20', 4)).toThrow('Both arguments must be numbers');
        expect(() => calc.divide(20, '4')).toThrow('Both arguments must be numbers');
      });

      test('should reject null inputs', () => {
        expect(() => calc.add(null, 5)).toThrow('Both arguments must be numbers');
        expect(() => calc.add(5, null)).toThrow('Both arguments must be numbers');
      });

      test('should reject undefined inputs', () => {
        expect(() => calc.add(undefined, 5)).toThrow('Both arguments must be numbers');
        expect(() => calc.add(5, undefined)).toThrow('Both arguments must be numbers');
      });

      test('should reject object inputs', () => {
        expect(() => calc.add({}, 5)).toThrow('Both arguments must be numbers');
        expect(() => calc.add(5, {})).toThrow('Both arguments must be numbers');
      });

      test('should reject array inputs', () => {
        expect(() => calc.add([], 5)).toThrow('Both arguments must be numbers');
        expect(() => calc.add(5, [])).toThrow('Both arguments must be numbers');
      });

      test('should reject boolean inputs', () => {
        expect(() => calc.add(true, 5)).toThrow('Both arguments must be numbers');
        expect(() => calc.add(5, false)).toThrow('Both arguments must be numbers');
      });
    });

    describe('NaN validation', () => {
      test('should reject NaN in add', () => {
        expect(() => calc.add(NaN, 5)).toThrow('Arguments cannot be NaN');
        expect(() => calc.add(5, NaN)).toThrow('Arguments cannot be NaN');
        expect(() => calc.add(NaN, NaN)).toThrow('Arguments cannot be NaN');
      });

      test('should reject NaN in subtract', () => {
        expect(() => calc.subtract(NaN, 5)).toThrow('Arguments cannot be NaN');
        expect(() => calc.subtract(5, NaN)).toThrow('Arguments cannot be NaN');
      });

      test('should reject NaN in multiply', () => {
        expect(() => calc.multiply(NaN, 5)).toThrow('Arguments cannot be NaN');
        expect(() => calc.multiply(5, NaN)).toThrow('Arguments cannot be NaN');
      });

      test('should reject NaN in divide', () => {
        expect(() => calc.divide(NaN, 5)).toThrow('Arguments cannot be NaN');
        expect(() => calc.divide(5, NaN)).toThrow('Arguments cannot be NaN');
      });
    });

    describe('Infinity validation', () => {
      test('should reject Infinity in add', () => {
        expect(() => calc.add(Infinity, 5)).toThrow('Arguments must be finite numbers');
        expect(() => calc.add(5, Infinity)).toThrow('Arguments must be finite numbers');
        expect(() => calc.add(Infinity, Infinity)).toThrow('Arguments must be finite numbers');
      });

      test('should reject negative Infinity in add', () => {
        expect(() => calc.add(-Infinity, 5)).toThrow('Arguments must be finite numbers');
        expect(() => calc.add(5, -Infinity)).toThrow('Arguments must be finite numbers');
      });

      test('should reject Infinity in subtract', () => {
        expect(() => calc.subtract(Infinity, 5)).toThrow('Arguments must be finite numbers');
        expect(() => calc.subtract(5, Infinity)).toThrow('Arguments must be finite numbers');
      });

      test('should reject Infinity in multiply', () => {
        expect(() => calc.multiply(Infinity, 5)).toThrow('Arguments must be finite numbers');
        expect(() => calc.multiply(5, Infinity)).toThrow('Arguments must be finite numbers');
      });

      test('should reject Infinity in divide', () => {
        expect(() => calc.divide(Infinity, 5)).toThrow('Arguments must be finite numbers');
        expect(() => calc.divide(5, Infinity)).toThrow('Arguments must be finite numbers');
      });
    });
  });

  describe('Return Value Validation', () => {
    test('add should return a number', () => {
      expect(typeof calc.add(5, 3)).toBe('number');
    });

    test('subtract should return a number', () => {
      expect(typeof calc.subtract(10, 4)).toBe('number');
    });

    test('multiply should return a number', () => {
      expect(typeof calc.multiply(6, 7)).toBe('number');
    });

    test('divide should return a number', () => {
      expect(typeof calc.divide(20, 4)).toBe('number');
    });

    test('operations should not return NaN for valid inputs', () => {
      expect(isNaN(calc.add(5, 3))).toBe(false);
      expect(isNaN(calc.subtract(10, 4))).toBe(false);
      expect(isNaN(calc.multiply(6, 7))).toBe(false);
      expect(isNaN(calc.divide(20, 4))).toBe(false);
    });

    test('operations should not return Infinity for valid inputs', () => {
      expect(isFinite(calc.add(5, 3))).toBe(true);
      expect(isFinite(calc.subtract(10, 4))).toBe(true);
      expect(isFinite(calc.multiply(6, 7))).toBe(true);
      expect(isFinite(calc.divide(20, 4))).toBe(true);
    });
  });

  describe('Multiple Operations', () => {
    test('should handle chained operations', () => {
      const result1 = calc.add(5, 3);
      const result2 = calc.multiply(result1, 2);
      expect(result2).toBe(16);
    });

    test('should handle complex calculations', () => {
      // (10 + 5) * 2 - 8 / 4
      const sum = calc.add(10, 5);
      const product = calc.multiply(sum, 2);
      const quotient = calc.divide(8, 4);
      const result = calc.subtract(product, quotient);
      expect(result).toBe(28);
    });

    test('should maintain state independence between operations', () => {
      calc.add(5, 3);
      calc.multiply(10, 2);
      const result = calc.subtract(15, 5);
      expect(result).toBe(10);
    });
  });

  describe('Boundary Conditions', () => {
    test('should handle Number.MAX_SAFE_INTEGER', () => {
      expect(calc.add(Number.MAX_SAFE_INTEGER, 0)).toBe(Number.MAX_SAFE_INTEGER);
      expect(calc.subtract(Number.MAX_SAFE_INTEGER, 0)).toBe(Number.MAX_SAFE_INTEGER);
      expect(calc.multiply(Number.MAX_SAFE_INTEGER, 1)).toBe(Number.MAX_SAFE_INTEGER);
      expect(calc.divide(Number.MAX_SAFE_INTEGER, 1)).toBe(Number.MAX_SAFE_INTEGER);
    });

    test('should handle Number.MIN_SAFE_INTEGER', () => {
      expect(calc.add(Number.MIN_SAFE_INTEGER, 0)).toBe(Number.MIN_SAFE_INTEGER);
      expect(calc.subtract(Number.MIN_SAFE_INTEGER, 0)).toBe(Number.MIN_SAFE_INTEGER);
      expect(calc.multiply(Number.MIN_SAFE_INTEGER, 1)).toBe(Number.MIN_SAFE_INTEGER);
      expect(calc.divide(Number.MIN_SAFE_INTEGER, 1)).toBe(Number.MIN_SAFE_INTEGER);
    });

    test('should handle Number.EPSILON', () => {
      expect(calc.add(Number.EPSILON, Number.EPSILON)).toBeCloseTo(Number.EPSILON * 2, 20);
    });

    test('should handle numbers close to zero', () => {
      const verySmall = 1e-10;
      expect(calc.add(verySmall, verySmall)).toBeCloseTo(2e-10, 15);
      expect(calc.multiply(verySmall, 2)).toBeCloseTo(2e-10, 15);
    });
  });

  describe('Floating Point Precision', () => {
    test('should handle known floating point precision issues', () => {
      // JavaScript floating point quirk: 0.1 + 0.2 !== 0.3
      expect(calc.add(0.1, 0.2)).toBeCloseTo(0.3, 10);
    });

    test('should handle decimal multiplication precision', () => {
      expect(calc.multiply(0.1, 0.1)).toBeCloseTo(0.01, 10);
    });

    test('should handle decimal division precision', () => {
      expect(calc.divide(1, 3)).toBeCloseTo(0.333333, 5);
    });
  });

  describe('Calculator Instance', () => {
    test('should create independent calculator instances', () => {
      const calc1 = new Calculator();
      const calc2 = new Calculator();
      
      const result1 = calc1.add(5, 3);
      const result2 = calc2.add(10, 20);
      
      expect(result1).toBe(8);
      expect(result2).toBe(30);
    });

    test('should have all required methods', () => {
      expect(typeof calc.add).toBe('function');
      expect(typeof calc.subtract).toBe('function');
      expect(typeof calc.multiply).toBe('function');
      expect(typeof calc.divide).toBe('function');
    });
  });
});
