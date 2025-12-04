# Advent of Code 2025

My solutions to [Advent of Code 2025](https://adventofcode.com/2025) written in the [Odin programming language](https://odin-lang.org/).

## Running Solutions

### Using the Solution Runner

```bash
# Run all solutions for a specific day
odin run . -- day=1
odin run . -- day=04
odin run . -- day=12

# Or build and run the runner
odin build . -out:aoc2025
./aoc2025 -- day=1
```

### Running Individual Solutions

```bash
cd day_XX
odin run .\puzzle_1.odin -file
odin run .\puzzle_2.odin -file
```

**Note:** Add your own `input.txt` file to each day's directory.
