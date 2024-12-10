
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

    
  # returns a list of equations, an equation is a list of operators and numbers
  genEquations = numbers:
  if numbers == [] then
    [ [] ]
  else if (builtins.length numbers) == 1 then
    [ numbers ] 
  else
    let
      top = builtins.head numbers;
      rest = builtins.tail numbers;
      retVal = builtins.foldl' (acc: e: 
        [([top] ++ [builtins.mul] ++ e )] ++ 
        [([top] ++ [builtins.add] ++ e )] ++ 
        [([top] ++ [concat] ++ e )] ++ 
        acc) [] (genEquations rest);
    in
    retVal;

  solveEquation = {total, numbers}:
    let
      equations = genEquations numbers;
      allEq = map calculate equations;
      totals = map (e: e == total) allEq;
    in
    if (builtins.any (e: e) totals) then
      [total]
    else
      [];
    
        
  solvePart1 = p:
    let
      f = readFile p;
      puzzle = getPuzzle f;
      allEquations = map solveEquation puzzle;
    in
    sum (lib.flatten allEquations);
in
solvePart1 ./new_input
