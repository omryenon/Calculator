# Calculator:
This project is an implementation of simple Calculator, written entirely in assembly language. It contains calls for C standard library functions from the assembly code. This project was written in Linux.
** Input and output operands are in octal representation.
** Any input number is pushed onto an operand stack. Each operation is performed on operands which are popped from the operand stack.

# Operations:

"q" - quit

"+" - unsigned addition. Pop two operands from operand stack, and push the result, their sum

"p" - Pop one operand from the operand stack, and print its value to stdout

"d" - duplicate: push a copy of the top of the operand stack onto the top of the operand stack

"&" - bitwise AND, X&Y with X being the top of operand stack and Y the element next to x in the operand stack. pop two operands from the operand stack, and push the result.

"n" - number of bytes the number is taking. pop one operand from the operand stack, and push one result.


# Run the program

compile the assembly file:

nasm -f elf calc.s -o calc.o
gcc -m32 -Wall -g calc.o -o calc

then run:

./calc NUM 
(where NUM is the octal input of the stack size which the program will start with)
