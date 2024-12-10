
with import <nixpkgs> {};
let
  readFile = p: lib.readFile p;
  getPuzzle = s: 
    let
      p0 = lib.splitString "\n" s;
      p1 = lib.init(p0);
      p2 = map (e: lib.splitString ": " e) p1;
      p3 = map 
        (e: 
          {
            total = lib.toInt (builtins.head e);
            numbers = map lib.toInt (lib.splitString " " (builtins.elemAt e 1)); 
          }
        ) 
        p2;
    in
    p3;

  sum = l: builtins.foldl' (acc: e: e + acc) 0 l;

  # takes in two positive integers, concatenates them
  concat = n: m: 
    let
      ns = if (n == 0) then "" else builtins.toString n;
      ms = if (m == 0) then "" else builtins.toString m;
      nsms = ns + ms;
    in
      lib.toInt nsms;
      
  calculate = l: 
    if l == [] then
      0
    else if (builtins.length l) == 1 then
      builtins.head l
    else
      let
        left = builtins.head l;
        op = builtins.elemAt l 1;
        right = builtins.elemAt l 2;
        rest = lib.lists.sublist 3 ((builtins.length l) - 3) l;
        val = op left right;        
      in
        calculate ([val] ++ rest);

  # returns first equation that solves for total or [] if none found
  solveEquation = {total, numbers, curEq, operators}:
    # builtins.trace "solveEquation=curEq=${builtins.toString curEq}" (
    if numbers == [] then
      # we've reached the end, is curEq eq to total
      if total == (calculate curEq) then
        curEq
      else
        []
    else if (builtins.length numbers) == 1 then
      solveEquation {
        inherit total operators;
        numbers = [];
        curEq = curEq ++ [(builtins.head numbers)];
      }
    else if ((builtins.length curEq) > 1) && (calculate (lib.init curEq) > total) then
      []
    else
      # more numbers left
      let
        top = builtins.head numbers;
        results = builtins.foldl' 
          (acc: eq: 
            let
              iterResult = solveEquation {
                inherit total operators;  
                numbers = builtins.tail numbers;
                curEq = curEq ++ [top] ++ [eq]; 
              };
            in
            if iterResult == [] then
              acc
            else
              iterResult
          )
          []
          operators;
      in
      results;
      
  solvePart1 = p:
    let
      f = readFile p;
      puzzle = getPuzzle f;
      totals = map (e: 
        let
          solList = solveEquation {total = e.total; numbers = e.numbers; curEq=[]; operators=[builtins.add builtins.mul];};
        in
          if (lib.flatten solList) == [] then
            0
          else
            e.total
        ) puzzle;
      in
      sum totals;

  solvePart2 = p:
    let
      f = readFile p;
      puzzle = getPuzzle f;
      totals = map (e: 
        let
          solList = builtins.trace "solving: ${builtins.toString e.numbers}" (solveEquation {total = e.total; numbers = e.numbers; curEq=[]; operators=[builtins.add builtins.mul concat];});
        in
          if (lib.flatten solList) == [] then
            0
          else
            e.total
        ) puzzle;
      in
      sum totals;

in
{
  part1 = solvePart1 ./input;
  part2 = solvePart2 ./input;
}
