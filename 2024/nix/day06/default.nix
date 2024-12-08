with builtins;
with import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/689fed12a013f56d4c4d3f612489634267d86529.tar.gz") {};
let
  getGridFile = p: lib.readFile p;

  # type grid.
  # takes a string and returns a grid, grid is a list of strings,
  # each string is a row. grid is rectangle:  [ string ]
  getGrid = s:
    lib.init (lib.splitString "\n" s);

  # type gridstate, {grid, guardPos}
  getGridState = grid:
    {
      inherit grid;
      guardPos = getGuardPos(grid);
    };
   
  # -1 if doesnt exist
  getGuardPos = grid:
    let
      row = lib.findFirst
        (i:
          let
            row = builtins.elemAt grid i;
            guardCol = getGuardColumn row;
          in
            guardCol != -1
        )
        (-1)
        (lib.range 0 ((builtins.length grid) - 1));
    in
    if row == -1 then
      -1
    else
      {
        x = getGuardColumn (builtins.elemAt grid row);
        y = row;
      };

  # returns where in this row the guard is, -1 means not found
  getGuardColumn = s:
    lib.findFirst
      (i: (builtins.substring i 1 s) == "^")
      (-1)
      (lib.range 0 ((builtins.stringLength s) - 1));

  solvePart1 = p:
    let
      gridFile = getGridFile p;
      grid = getGrid gridFile;
      guardPos = getGuardPos grid;
    in
    guardPos;
in
  solvePart1 ./test_input
