# Othello.jl

A simple implementation of the classic **Othello / Reversi** board game written in Julia.

The package provides a terminal-based two-player game on an 8×8 board. Players enter their moves in the Julia REPL and the game handles move validation, piece flipping, turn changes, scoring, and end-of-game detection.

## Requirements

- Julia 1.11

## Installation

Clone the repository and activate the project:

```bash
git clone https://github.com/Juven14s/Othello.jl.git
cd Othello.jl
julia --project=.
```

Then install the project dependencies from the Julia package manager:

```julia
using Pkg
Pkg.instantiate()
```

## Run the game

Start Julia with the project activated, then run:

```julia
using Othello
Othello.jeu()
```

The initial four pieces are placed automatically in the centre of the board.

During a turn, enter a move as two space-separated coordinates:

```text
4 3
```

The board uses values from `1` to `8` for both rows and columns.

## Board symbols

- `X` — black player
- `O` — white player
- `.` — empty square

## Project structure

```text
Othello.jl/
├── src/
│   ├── Othello.jl
│   └── Grilles.jl
├── test/
│   └── runtests.jl
├── .github/
│   └── workflows/
├── Project.toml
└── LICENSE
```

## Testing

Run the test suite with:

```bash
julia --project=. -e 'using Pkg; Pkg.test()'
```

The project currently contains the test harness and is ready for additional gameplay and rules tests.

## Continuous integration

GitHub Actions is configured for continuous integration. The repository also includes Dependabot, CompatHelper, and TagBot configuration to help keep dependencies and package maintenance automated.

## Contributing

Contributions are welcome. If you want to improve the game logic, add tests, enhance the user interface, or improve documentation, open an issue or submit a pull request.

When contributing code, please keep changes focused and add tests for new behaviour whenever possible.

## License

This project is distributed under the terms of the license included in the [`LICENSE`](LICENSE) file.
