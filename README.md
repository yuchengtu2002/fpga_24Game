# FPGA 24 Game

An FPGA-based implementation of the classic 24 game.

**Project Overview**

This project is the final assignment for the course ECE241 at the Department of Electrical and Computer Engineering, University of Toronto. It involves designing an FPGA-based version of the classic 24 game.

## Description

The FPGA 24 Game challenges players to use four given integers to form an expression that evaluates to 24, using basic arithmetic operations and brackets. The game is implemented using an Arithmetic Logic Unit (ALU) and a Finite State Machine (FSM). It offers three puzzles, each with increasing difficulty levels.

### Game Features

- **Title Screen:**
  - Upon starting the game, the user enters the title screen.
  - At any point in the game, the user can return to the title screen by pressing `Key[0]`.
  - To begin the first puzzle, the user presses `Key[2]` and can then use a PS2 keyboard for input.

- **Puzzle Gameplay:**
  - The user is presented with four numbers and must create an expression using all four numbers exactly once, along with arithmetic operators, to achieve a total of 24.
  - **Input Method:**
    - Operators are represented by specific characters: 
      - Add: `a`
      - Subtract: `s`
      - Multiply: `m`
      - Divide: `d`
      - Open Bracket: `o`
      - Close Bracket: `c`
    - Example Input: To express \(4 \times 6 \times (2 - 1)\), the user inputs `4m6mo2s1c` and presses enter to confirm.

### Input Restrictions

Certain inputs are not allowed to ensure valid operations:

- Entering numbers that are not provided or using unreserved characters.
- Using any number more times than given.
- Failing to use all provided numbers.
- Performing non-integer division or dividing by zero.
- Mismatched parentheses.
- Invalid operations (e.g., `5+*6` represented as `5am6`).

### Evaluation and Feedback

- If the user inputs a valid operation, the result is displayed on `HEX4` and `HEX5`.
- If the result is not 24, the game enters a fail state. The user can press `Key[1]` to retry.
- If the user successfully achieves 24, the game enters a success screen. The user can press `Key[1]` to try another approach or `Key[2]` to proceed to the next puzzle.

## Authors

- Yucheng Tu
- George Li
