# Game of Life (Assembly)

## Overview
This project is an implementation of **Conway's Game of Life** in assembly language, built to run on a self-designed CPU architecture created in **VHDL**. The Game of Life is a cellular automaton, where cells evolve based on simple rules, simulating patterns of life and death on a grid.

By combining the assembly code for the game with a custom CPU, this project explores both low-level software development and hardware design.

## Technical Highlights
- **Assembly Language**: The game is written entirely in assembly, designed to run efficiently on the self-made CPU.
- **Custom CPU Architecture**: The game operates on a CPU designed using VHDL, which includes core components necessary for executing assembly instructions.
- **Cellular Automaton**: Simulates the life and death of cells based on predefined rules, updating the grid in each iteration.
- **Optimized Performance**: Assembly ensures tight control of resources, while the VHDL-based CPU is tailored to the game’s computational needs.
  
## Features
- Simulation of Conway's Game of Life, where cells evolve based on:
  - Underpopulation: Any live cell with fewer than two live neighbors dies.
  - Overpopulation: Any live cell with more than three live neighbors dies.
  - Reproduction: Any dead cell with exactly three live neighbors becomes a live cell.
- Real-time grid updates with efficient assembly-level processing on a custom CPU.

## Contributing
This project was developed as part of the EPFL curriculum. Special thanks to **EPFL** for the project guidelines and to **Temi Messmer**, my teammate, for their invaluable contributions throughout the development process.
