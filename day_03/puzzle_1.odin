package main

import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"

main :: proc() {
	puzzle_input, read_ok := os.read_entire_file_from_filename("input.txt", context.allocator)
	assert(read_ok)
	defer delete(puzzle_input)

	total_joltage := 0

	input_str := string(puzzle_input)
	for battery_bank in strings.split_lines_iterator(&input_str) {
		if len(battery_bank) < 2 do continue

		max_bank_joltage := 0
		for i := 0; i < len(battery_bank) - 1; i += 1 {
			for j := i + 1; j < len(battery_bank); j += 1 {
				first_battery := int(battery_bank[i]) // - '0'
				second_battery := int(battery_bank[j])

				joltage_str := fmt.tprintf("%c%c", first_battery, second_battery)
				joltage_value, parse_ok := strconv.parse_int(joltage_str, 10)
				assert(parse_ok)

				if joltage_value > max_bank_joltage {
					max_bank_joltage = joltage_value
				}
			}
		}

		total_joltage += max_bank_joltage

		free_all(context.temp_allocator)
	}

	fmt.printfln("Solution 1: %i", total_joltage)
}
