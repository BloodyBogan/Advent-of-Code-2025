package main

import "core:fmt"
import "core:os/os2"
import "core:sort"
import "core:strconv"
import "core:strings"

Range :: [2]int

@(private = "file")
parse_ranges :: proc(ranges: ^[dynamic]Range, line: string) {
	ranges_arr, split_err := strings.split(line, "-", context.temp_allocator)
	assert(split_err == nil)

	lo, lo_ok := strconv.parse_int(ranges_arr[0], 10); assert(lo_ok)
	hi, hi_ok := strconv.parse_int(ranges_arr[1], 10); assert(hi_ok)

	append(ranges, Range{lo, hi})
}

collapse_ranges :: proc(ranges: ^[dynamic]Range) -> [dynamic]Range {
	sort.quick_sort_proc(ranges[:], proc(a: Range, b: Range) -> int {
		return -1 if a.x < b.x else 1
	})

	merged := make([dynamic]Range)
	append(&merged, ranges[0])

	for x := 1; x < len(ranges); x += 1 {
		if ranges[x].x > merged[len(merged) - 1].y {
			append(&merged, ranges[x])
		} else {
			merged[len(merged) - 1].y = max(merged[len(merged) - 1].y, ranges[x].y)
		}
	}

	return merged
}

count_fresh :: proc(ranges: [dynamic]Range, line: string) -> int {
	sum := 0

	for range in ranges {
		sum += range.y - range.x + 1
	}

	return sum
}

main :: proc() {
	puzzle_input, read_err := os2.read_entire_file("input.txt", context.allocator)
	assert(read_err == nil)
	defer delete(puzzle_input)

	result := 0

	ranges := make([dynamic]Range)
	defer delete(ranges)

	input_str := string(puzzle_input)
	for line in strings.split_lines_iterator(&input_str) {
		if len(line) == 0 {
			collapsed_ranges := collapse_ranges(&ranges)
			defer delete(collapsed_ranges)

			result += count_fresh(collapsed_ranges, line)
			break
		}

		parse_ranges(&ranges, line)

		free_all(context.temp_allocator)
	}

	fmt.printfln("Solution 2: %v", result)
}
