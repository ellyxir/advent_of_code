
let
  nixpkgs = fetchTarball "https://github.com/NixOS/nixpkgs/archive/689fed12a013f56d4c4d3f612489634267d86529.tar.gz";
  pkgs = import nixpkgs {};
  inherit (pkgs) lib;
  puzzle_input_string = builtins.readFile ./puzzle_input;
  puzzle_input_string_clean = lib.strings.removeSuffix "\n" puzzle_input_string;
  puzzle_input_split = lib.strings.splitString "," puzzle_input_string_clean;
  puzzle_input = map lib.toInt puzzle_input_split;
  opcodes = {
    "99" = halt_opcode;
    "1" = add_opcode;
    "2" = multiply_opcode;
  };
  halt_opcode = {input, ...}:
    input;

  add_opcode = {input, pos, arg1, arg2, storePos, ...}:
    let
      sum = arg1 + arg2;
    in
      replace input storePos sum;

  multiply_opcode = {input, pos, arg1, arg2, storePos, ...}:
    let
      sum = arg1 * arg2;
    in
      replace input storePos sum;

  process = l: pos:
    let
      opcode = toString (builtins.elemAt l pos);
      arg1_pos = builtins.elemAt l (pos+1);
      arg2_pos = builtins.elemAt l (pos+2);
      store_pos = builtins.elemAt l (pos+3);
      new_list = opcodes.${opcode} {
        input = l;
        pos = pos;
        arg1 = builtins.elemAt l arg1_pos;
        arg2 = builtins.elemAt l arg2_pos;
        storePos = store_pos;
      };
    in
      if opcode == "99" then
        new_list
      else
        process new_list (pos+4);

  replace = l: pos: new_elem:
    let 
      len = builtins.length l; 
      front = lib.lists.take pos l;
      rest = lib.lists.sublist (pos+1) (len - pos - 1) l;
    in 
      front ++ [new_elem] ++ rest;
in
  process puzzle_input 0
