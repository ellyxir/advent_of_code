with builtins;
with import <nixpkgs> {};
let
	split_input = split "\n" (readFile ./puzzle_input);
	filtered_input = filter (e: e != [] && e != "") split_input;
	integer_list = map lib.strings.toInt filtered_input;
	fuel_calc_list = map (m: m / 3 - 2) integer_list;
in
	foldl' (x: y: x + y) 0 fuel_calc_list
