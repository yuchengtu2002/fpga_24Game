# fpga_24Game
An FPGA-based classic 24-game


*This project is the final project for the course ECE241 at ECE, University of Toronto*

This is an FPGA-based design of the classic 24 game. The player(s) will be prompted with four integers displayed by the VGA monitor. They should input a mathematical expression using these numbers, and the game validates the result using an ALU and FSM. The game offers three puzzles in total. In each puzzle, the user is given four numbers, and the main goal is to use all four numbers exactly once, with basic arithmetic operations and brackets, to make 24. The three puzzles have increasing difficulties. 

Title Screen:
- The user enters the title screen upon entering the game. During any point in the game, the user can always return to the title screen by pressing Key[0]
- The user can press Key[2] to enter the first puzzle. Then, the user can use a PS2 keyboard to input.

Puzzle:
- The user is prompted with four numbers. Now the user can input an operation that uses exactly all four numbers and some operators to try to get 24.
- Way to input operation:
  * We use characters to represent operators: [add: a, subtract: s, multiply: m, divide: d, open_bracket: o, closed_bracket: c]
  * Example: 4 * 6 * (2 - 1) is to input "4m6mo2s1c" followed by enter to confirm.

Some inputs are not permitted: 
- Entering any number that is not given, or any character that is not reserved
- Entering a number more than the given amount. 
- Do not use all given numbers
- Division but not whole number division, Divide by 0
- The parenthesis don’t match 
- Operations that don't make sense such as 5+*6  (this is to input "5am6")

- We will evaluate the result if the user enters a valid operation. The result will be displayed on HEX4 and 5.
If the result is not 24, we enter the fail state. Users can enter key[1] to retry.

- If the user gets 24, we enter the success screen. The user can enter key[1] to try another approach or enter key[2] to proceed to the next puzzle.

Author: Yucheng Tu and George Li
