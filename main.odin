package main

import "core:fmt"
import "core:os/os2"
import "core:path/filepath"
import "core:strings"
import "core:text/regex"

print_usage :: proc(executable_path: string) {
	fmt.eprintln("Usage:")
	fmt.eprintln("   odin run . -- day=X")
	fmt.eprintfln("   %s -- day=X", executable_path)
	fmt.eprintln("")
	fmt.eprintln("Examples:")
	fmt.eprintln("   odin run . -- day=1")
	fmt.eprintln("   odin run . -- day=04")
	fmt.eprintln("   odin run . -- day=12")
}

main :: proc() {
	command_args := os2.args
	if len(command_args) < 2 {
		print_usage(command_args[0])
		return
	}

	day_pattern, pattern_err := regex.create_by_user("/day=0?(\\d+)/i")
	assert(pattern_err == nil, "Failed to create regex pattern")
	defer regex.destroy(day_pattern)

	regex_match, is_matched := regex.match(day_pattern, command_args[1])
	defer regex.destroy(regex_match)

	if !is_matched {
		fmt.eprintfln("Invalid argument format: %s", command_args[1])
		print_usage(command_args[0])
		return
	}

	day_number := regex_match.groups[1]

	day_directory, concat_err := strings.concatenate(
		{"day_", "0" if len(day_number) == 1 else "", day_number},
	)
	assert(concat_err == nil, "Failed to create directory name")
	defer delete(day_directory)

	if !os2.exists(day_directory) {
		fmt.eprintfln("Directory '%s' does not exist", day_directory)
		return
	}

	directory_handle, open_err := os2.open(day_directory)
	assert(open_err == nil, "Failed to open directory")
	defer os2.close(directory_handle)

	directory_iterator := os2.read_directory_iterator_create(directory_handle)
	defer os2.read_directory_iterator_destroy(&directory_iterator)

	solutions_executed := 0

	for file_info in os2.read_directory_iterator(&directory_iterator) {
		if filepath.ext(file_info.name) != ".odin" do continue
		if !strings.contains(file_info.name, "puzzle_") do continue

		defer free_all(context.temp_allocator)

		fmt.printfln("Running %s/%s:", day_directory, file_info.name)

		process_result, stdout, stderr, exec_err := os2.process_exec(
			{working_dir = day_directory, command = {"odin", "run", file_info.name, "-file"}},
			context.temp_allocator,
		)

		if exec_err != nil {
			fmt.eprintfln("Execution failed: %s", exec_err)
			continue
		}

		if len(stderr) != 0 {
			fmt.eprintfln("Execution error: %s", stderr)
			continue
		}

		solutions_executed += 1
		fmt.printfln("%s", stdout)
	}

	if solutions_executed == 0 do fmt.eprintfln("No puzzle solutions found in '%s'", day_directory)
}
