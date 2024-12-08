with builtins;
with import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/689fed12a013f56d4c4d3f612489634267d86529.tar.gz") {};
let
  sum = l: builtins.foldl' (acc: e: e + acc) 0 l;
  
  # how many times is c in the string s
  countChar = s: c: 
    builtins.foldl' 
      (acc: i: 
        if (builtins.substring i 1 s) == c then 
          acc + 1 
        else 
          acc
      ) 
      0 
      (
        lib.range 
          0 
          ((builtins.stringLength s) - 1)
      );
    
  getGridFile = p: lib.readFile p;

  # type grid.
  # takes a string and returns a grid, grid is a list of strings,
  # each string is a row. grid is rectangle:  [ string ]
  getGrid = s:
    lib.init (lib.splitString "\n" s);

  # direction is an attr set with x y increments ie {x=-1;y=0;} means left
  # returns direction based on the guard character
  getDirection = s:
    let
      dirMap = 
        [
          ["^" {x=0;    y=(-1);}]
          [">" {x=1;    y=0;}]
          ["v" {x=0;    y=1;}]
          ["<" {x=(-1); y=0;}]
        ];
      match = builtins.filter (e: (builtins.head e) == s) dirMap;
    in
      builtins.elemAt (builtins.head match) 1; 

  # pass in guard token, return new token that is 90 degree turn
  turn90 = s:
    let
      m = builtins.filter (e: (builtins.head e) == s)  [ ["^" ">"] [">" "v"] ["v" "<"] ["<" "^"] ];
    in 
    builtins.elemAt (builtins.head m) 1;
    
  # returns the character (as string) in the grid at the passed in position
  # x y must be in bounds or will throw exception
  getXY = {x,y}: grid: 
    let
      row = builtins.elemAt grid y;
    in
      builtins.substring x 1 row;
      
  # places char into the grid, replacing existing character
  putXY = {x,y}: c: grid:
    foldl' 
      (acc: e: 
        if e == y then
          (acc ++ [(replaceChar (builtins.elemAt grid e) x c)])
        else
          (acc ++ [(builtins.elemAt grid e)])
        )
      []
      (lib.range 0 ((getGridHeight grid) - 1));
    
  replaceChar = s: index: c: 
    let
      len = builtins.stringLength s;
      before = builtins.substring 0 index s;
      after = builtins.substring (index + 1) (len - index) s;  
    in
      before + c + after;
        
  # adds pos + dir and returns a new position
  moveXY = pos: dir:
   {x = (pos.x + dir.x); y = (pos.y + dir.y); };
    
  getGridWidth = grid: builtins.stringLength (builtins.head grid);
  getGridHeight = grid: builtins.length grid;
  isValidPos = {x,y}: grid: 
    (x >= 0) && (x < getGridWidth grid) && (y >= 0) && (y < getGridHeight grid);
      
  # type gridstate, {grid, guardPos}
  getGridState = grid:
    rec {
      inherit grid;
      guardPos = getGuardPos grid;
      guardInMap = (guardPos != -1);
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
      (i: builtins.any (e: (builtins.substring i 1 s) == e) ["^" ">" "v" "<"])
      (-1)
      (lib.range 0 ((builtins.stringLength s) - 1));

  # generate next state 
  # returns gridState
  tick = gridState: 
    let
      guard = getXY gridState.guardPos gridState.grid;
      aheadDir = getDirection guard;
      aheadPos = moveXY gridState.guardPos aheadDir;
      aheadValid = isValidPos aheadPos gridState.grid;
      isWall = aheadValid && ((getXY aheadPos gridState.grid) == "#");

      # we move ahead if no wall, other we dont move (we turn right instead)
      # allow walking off map
      updatedGuardPos = if (!isWall) then aheadPos else gridState.guardPos;
      updatedGuard = if isWall then turn90 guard else guard;
      updatedGuardDir = getDirection updatedGuard;

      updatedGrid = 
        if updatedGuardPos != gridState.guardPos then
          # we've moved, mark old position with X the put guard in new position
          let
            markedX = putXY gridState.guardPos "X" gridState.grid; 
          in
          putXY updatedGuardPos updatedGuard markedX
        else
          # we didnt move, update the guard marker
          putXY updatedGuardPos updatedGuard gridState.grid;
    in 
      {grid = updatedGrid; guardPos = updatedGuardPos; guardInMap = (isValidPos updatedGuardPos gridState.grid);};

  # calls ticks until the guard is no longer in the map
  runTicks = gridState: prevGridState: 
    if (! gridState.guardInMap) then
      gridState
    else
      let
        nextState = tick gridState;
      in
        runTicks nextState gridState;  

  solvePart1 = p:
    let
      gridFile = getGridFile p;
      grid = getGrid gridFile;
      gridState = getGridState grid; 
      ticks = runTicks gridState [];
      finalGridState = ticks; 
    in
      sum (map (e: countChar e "X") finalGridState.grid);

  # in part two, we want to see if the guard ever comes back to the same point 
  # with the same orientation, that means he's in a loop

in
 solvePart1 ./input
