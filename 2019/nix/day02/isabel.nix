
let
  lib = import <nixpkgs/lib>;

  inherit (builtins) elemAt;

  raw = builtins.readFile ./puzzle_input;
  raw_clean = lib.removeSuffix "\n" raw;
  input = lib.splitString "," raw_clean;
  numbers = builtins.map lib.toInt input;

  process =
    list: pos:
    let
      opcode = elemAt list pos;
      arg1 = elemAt list (elemAt list (pos + 1));
      arg2 = elemAt list (elemAt list (pos + 2));
      store = elemAt list (pos + 3);
    in
    if opcode == 99 then
      "halt"
    else if opcode == 1 then
      let
        sum = arg1 + arg2;
      in
      replace list store sum
    else if opcode == 2 then
      let
        product = arg1 * arg2;
      in
      replace list store product
    else
      opcode;

  replace =
    list: pos: value:
    let
      len = builtins.length list;
      front = lib.take pos list;
      back = lib.sublist (pos + 1) (len - pos - 1) list;
    in
    front ++ [ value ] ++ back;

  run =
    pos: list:
    let
      result = process list pos;
    in
    if result == "halt" then list else run (pos + 4) result;

  result = run 0 numbers;

  res = builtins.concatStringsSep "," (map toString result);
in
res
