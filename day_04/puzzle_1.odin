package main

import "core:fmt"
import "core:os"
import "core:strings"

@(private = "file")
MAX_ACCESSIBLE_NEIGHBORS :: 3

@(private = "file")
Cell :: enum u8 {
	EMPTY      = 46, // '.'
	PAPER_ROLL = 64, // '@'
}

main :: proc() {
	puzzle_input, read_err := os.read_entire_file_from_filename_or_err("input.txt")
	assert(read_err == nil)
	defer delete(puzzle_input)

	accessible_rolls := 0

	input_str := string(puzzle_input)
	grid_lines, split_err := strings.split_lines(input_str)
	assert(split_err == nil)
	defer delete(grid_lines)

	for row := 0; row < len(grid_lines); row += 1 {
		for col := 0; col < len(grid_lines[row]); col += 1 {
			cell := grid_lines[row][col]

			neighbor_count := 0

			switch Cell(cell) {
			case .EMPTY:
				continue
			case .PAPER_ROLL:
				if row - 1 >= 0 && grid_lines[row - 1][col] == u8(Cell.PAPER_ROLL) do neighbor_count += 1
				if row + 1 < len(grid_lines) && grid_lines[row + 1][col] == u8(Cell.PAPER_ROLL) do neighbor_count += 1
				if col - 1 >= 0 && grid_lines[row][col - 1] == u8(Cell.PAPER_ROLL) do neighbor_count += 1
				if col + 1 < len(grid_lines[row]) && grid_lines[row][col + 1] == u8(Cell.PAPER_ROLL) do neighbor_count += 1
				if row - 1 >= 0 && col - 1 >= 0 && grid_lines[row - 1][col - 1] == u8(Cell.PAPER_ROLL) do neighbor_count += 1
				if row - 1 >= 0 && col + 1 < len(grid_lines[row]) && grid_lines[row - 1][col + 1] == u8(Cell.PAPER_ROLL) do neighbor_count += 1
				if row + 1 < len(grid_lines) && col - 1 >= 0 && grid_lines[row + 1][col - 1] == u8(Cell.PAPER_ROLL) do neighbor_count += 1
				if row + 1 < len(grid_lines) && col + 1 < len(grid_lines[row]) && grid_lines[row + 1][col + 1] == u8(Cell.PAPER_ROLL) do neighbor_count += 1

				if neighbor_count <= MAX_ACCESSIBLE_NEIGHBORS do accessible_rolls += 1
			case:
				panic("Unknown character in grid")
			}
		}
	}

	fmt.printfln("Solution 1: %v", accessible_rolls)
}
