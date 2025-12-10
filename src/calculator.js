/**
 * Calculator module providing basic arithmetic operations
 */

class Calculator {
  /**
   * Adds two numbers
   * @param {number} a - First number
   * @param {number} b - Second number
   * @returns {number} Sum of a and b
   */
  add(a, b) {
    this._validateNumbers(a, b);
    return a + b;
  }

  /**
   * Subtracts second number from first number
   * @param {number} a - First number
   * @param {number} b - Second number
   * @returns {number} Difference of a and b
   */
  subtract(a, b) {
    this._validateNumbers(a, b);
    return a - b;
  }

  /**
   * Multiplies two numbers
   * @param {number} a - First number
   * @param {number} b - Second number
   * @returns {number} Product of a and b
   */
  multiply(a, b) {
    this._validateNumbers(a, b);
    return a * b;
  }

  /**
   * Divides first number by second number
   * @param {number} a - Dividend
   * @param {number} b - Divisor
   * @returns {number} Quotient of a and b
   * @throws {Error} If divisor is zero
   */
  divide(a, b) {
    this._validateNumbers(a, b);
    
    if (b === 0) {
      throw new Error('Division by zero is not allowed');
    }
    
    return a / b;
  }

  /**
   * Validates that inputs are valid numbers
   * @private
   * @param {*} a - First value to validate
   * @param {*} b - Second value to validate
   * @throws {Error} If either value is not a valid number
   */
  _validateNumbers(a, b) {
    if (typeof a !== 'number' || typeof b !== 'number') {
      throw new Error('Both arguments must be numbers');
    }
    
    if (isNaN(a) || isNaN(b)) {
      throw new Error('Arguments cannot be NaN');
    }
    
    if (!isFinite(a) || !isFinite(b)) {
      throw new Error('Arguments must be finite numbers');
    }
  }
}

// Export for CommonJS and ES6 modules
if (typeof module !== 'undefined' && module.exports) {
  module.exports = Calculator;
}

// Export for ES6 modules
if (typeof exports !== 'undefined') {
  exports.Calculator = Calculator;
}
