package main

import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"

NUM_BATTERIES :: 12

main :: proc() {
	puzzle_input, read_ok := os.read_entire_file_from_filename("input.txt", context.allocator)
	assert(read_ok)
	defer delete(puzzle_input)

	total_joltage := 0

	input_str := string(puzzle_input)
	for battery_bank in strings.split_lines_iterator(&input_str) {
		if len(battery_bank) < NUM_BATTERIES do continue

		batteries_remaining := NUM_BATTERIES
		last_selected_idx := -1
		highest_available_digit: u8 = 0
		selected_digits: [NUM_BATTERIES]byte

		for batteries_remaining > 0 {
			current_best_idx := last_selected_idx
			for x := len(battery_bank) - batteries_remaining; x > last_selected_idx; x -= 1 {
				if battery_bank[x] >= highest_available_digit {
					highest_available_digit = battery_bank[x]
					current_best_idx = x
				}
			}

			selected_digits[NUM_BATTERIES - batteries_remaining] = highest_available_digit
			highest_available_digit = 0
			last_selected_idx = current_best_idx
			batteries_remaining -= 1
		}

		joltage_str, clone_ok := strings.clone_from_bytes(
			selected_digits[:],
			context.temp_allocator,
		)
		assert(clone_ok == nil)
		joltage_value, parse_ok := strconv.parse_int(joltage_str, 10)
		assert(parse_ok)

		total_joltage += joltage_value

		free_all(context.temp_allocator)
	}

	fmt.printfln("Solution 2: %i", total_joltage)
}
