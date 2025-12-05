package main

import "core:fmt"
import "core:os/os2"
import "core:strconv"
import "core:strings"

Parse_Mode :: enum {
	RANGES,
	FRESH,
}

@(private = "file")
parse_ranges :: proc(ranges: ^[dynamic]int, line: string) {
	ranges_arr, split_err := strings.split(line, "-", context.temp_allocator)
	assert(split_err == nil)

	min, min_ok := strconv.parse_int(ranges_arr[0], 10); assert(min_ok)
	max, max_ok := strconv.parse_int(ranges_arr[1], 10); assert(max_ok)

	append(ranges, min)
	append(ranges, max)
}

is_fresh :: proc(ranges: [dynamic]int, line: string) -> bool {
	val, val_ok := strconv.parse_int(line); assert(val_ok)

	found := false
	for x := 0; x < len(ranges) - 1; x += 2 {
		lower, upper := ranges[x], ranges[x + 1]
		if val >= lower && val <= upper {
			found = true
			break
		}
	}

	return found
}

main :: proc() {
	puzzle_input, read_err := os2.read_entire_file("input.txt", context.allocator)
	assert(read_err == nil)
	defer delete(puzzle_input)

	result := 0

	ranges := make([dynamic]int, 390)
	defer delete(ranges)

	curr_parse_mode := Parse_Mode.RANGES

	input_str := string(puzzle_input)
	for line in strings.split_lines_iterator(&input_str) {
		if len(line) == 0 {
			curr_parse_mode = Parse_Mode.FRESH
			continue
		}

		switch curr_parse_mode {
		case .RANGES:
			parse_ranges(&ranges, line)
			assert(len(ranges) % 2 == 0)
		case .FRESH:
			if is_fresh(ranges, line) do result += 1
		}

		free_all(context.temp_allocator)
	}

	fmt.printfln("Solution 1: %v", result)
}
