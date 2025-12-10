/**
 * Example usage of the Calculator module
 */

const Calculator = require('./calculator');

// Create a new calculator instance
const calc = new Calculator();

console.log('=== Calculator Examples ===\n');

// Addition
console.log('Addition:');
console.log(`5 + 3 = ${calc.add(5, 3)}`);
console.log(`-10 + 25 = ${calc.add(-10, 25)}`);
console.log(`0.1 + 0.2 = ${calc.add(0.1, 0.2)}`);

// Subtraction
console.log('\nSubtraction:');
console.log(`10 - 4 = ${calc.subtract(10, 4)}`);
console.log(`5 - 12 = ${calc.subtract(5, 12)}`);

// Multiplication
console.log('\nMultiplication:');
console.log(`6 * 7 = ${calc.multiply(6, 7)}`);
console.log(`-3 * 4 = ${calc.multiply(-3, 4)}`);

// Division
console.log('\nDivision:');
console.log(`20 / 4 = ${calc.divide(20, 4)}`);
console.log(`7 / 2 = ${calc.divide(7, 2)}`);

// Error handling examples
console.log('\n=== Error Handling Examples ===\n');

// Division by zero
try {
  console.log('Attempting to divide by zero:');
  calc.divide(10, 0);
} catch (error) {
  console.log(`Error: ${error.message}`);
}

// Invalid input types
try {
  console.log('\nAttempting to add string and number:');
  calc.add('5', 3);
} catch (error) {
  console.log(`Error: ${error.message}`);
}

// NaN handling
try {
  console.log('\nAttempting to use NaN:');
  calc.multiply(NaN, 5);
} catch (error) {
  console.log(`Error: ${error.message}`);
}

// Infinity handling
try {
  console.log('\nAttempting to use Infinity:');
  calc.add(Infinity, 5);
} catch (error) {
  console.log(`Error: ${error.message}`);
}
