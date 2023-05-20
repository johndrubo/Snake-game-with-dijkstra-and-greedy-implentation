# Snake-game with dijkstra and greedy Implentation
Snake Game is a classic arcade game where the player controls a snake to eat food and grow longer. This is a project contains the source code and implementation of the autonomous Snake Game which uses Dijkstra and greedy algorithm to reach its food.

## Table of Contents
- [Introduction](#introduction)
- [Installation](#installation)
- [Usage](#usage)
- [Game Controls](#game-controls)
- [Documentation](#documentation)
- [Contributing](#contributing)
- [License](#license)

## Introduction

Snake Game is implemented using the Processing programming language, a platform for creating interactive graphics and applications. The game environment is rendered on a Processing sketch window, and the player controls the snake using arrow keys. The objective is to eat food items to grow longer and avoid colliding with the boundaries or the snake's own body.

## Installation

1. Download and install Processing from the official website: [https://processing.org/](https://processing.org/)
2. Clone or download this repository.
3. Open the `SnakeAi.pde` file in Processing.
4. Click the "Run" button or press `Ctrl + R` to start the game.

## Usage

1. Once the game is running, the snake will start moving automatically.
2. it will move automatically to find the food by mapping every squares as a pixel and will give value
3. with the value 0 as the head and i as the value of the body of the snake
3. Eat the food items to grow longer.
4. Avoid colliding with the boundaries or the snake's own body.
5. The game ends when the snake collides with a boundary or its own body.

## Game Controls

- D: use only Dijkstra's search, R: show search, K: pause, J: slow down, L: speed up

For detailed information about the code structure, variables, and functions, please refer to the inline code comments.

## Contributing

Contributions to the Snake Game project are welcome! If you find any issues or have suggestions for improvements, please open an issue or submit a pull request.

## License

This project is licensed under the [MIT License](LICENSE).
