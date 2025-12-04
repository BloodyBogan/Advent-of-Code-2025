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

	total_removed_rolls := 0

	input_str := string(puzzle_input)
	grid_lines, split_err := strings.split_lines(input_str)
	assert(split_err == nil)
	defer delete(grid_lines)

	grid_buffer := make([][]u8, len(grid_lines))
	for line, row in grid_lines {
		buffer_line := make([]u8, len(line))
		for char, col in line {
			buffer_line[col] = u8(char)
		}
		grid_buffer[row] = buffer_line
	}
	defer {
		for line in grid_buffer {
			delete(line)
		}
		delete(grid_buffer)
	}

	rolls_removed_this_iteration := true
	for rolls_removed_this_iteration {
		rolls_removed_this_iteration = false

		for row := 0; row < len(grid_buffer); row += 1 {
			for col := 0; col < len(grid_buffer[row]); col += 1 {
				neighbor_count := 0

				switch Cell(grid_buffer[row][col]) {
				case .EMPTY:
					continue
				case .PAPER_ROLL:
					if row - 1 >= 0 && grid_buffer[row - 1][col] == u8(Cell.PAPER_ROLL) do neighbor_count += 1
					if row + 1 < len(grid_buffer) && grid_buffer[row + 1][col] == u8(Cell.PAPER_ROLL) do neighbor_count += 1
					if col - 1 >= 0 && grid_buffer[row][col - 1] == u8(Cell.PAPER_ROLL) do neighbor_count += 1
					if col + 1 < len(grid_buffer[row]) && grid_buffer[row][col + 1] == u8(Cell.PAPER_ROLL) do neighbor_count += 1
					if row - 1 >= 0 && col - 1 >= 0 && grid_buffer[row - 1][col - 1] == u8(Cell.PAPER_ROLL) do neighbor_count += 1
					if row - 1 >= 0 && col + 1 < len(grid_buffer[row]) && grid_buffer[row - 1][col + 1] == u8(Cell.PAPER_ROLL) do neighbor_count += 1
					if row + 1 < len(grid_buffer) && col - 1 >= 0 && grid_buffer[row + 1][col - 1] == u8(Cell.PAPER_ROLL) do neighbor_count += 1
					if row + 1 < len(grid_buffer) && col + 1 < len(grid_buffer[row]) && grid_buffer[row + 1][col + 1] == u8(Cell.PAPER_ROLL) do neighbor_count += 1

					if neighbor_count <= MAX_ACCESSIBLE_NEIGHBORS {
						total_removed_rolls += 1
						rolls_removed_this_iteration = true
						grid_buffer[row][col] = u8(Cell.EMPTY)
					}
				case:
					panic("Unknown character in grid")
				}
			}
		}
	}

	fmt.printfln("Solution 2: %v", total_removed_rolls)
}
