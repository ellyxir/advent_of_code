
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

  calculate = eq: 
    true;
    
  # return [+ * + +], ordered list of operations that when applied
  # equals the total passed in
  solveEquation = {total, numbers}: 
    let
      top = builtins.head numbers;
      rest = builtins.tail numbers;
    in
    solveEquationHelper { inherit total; numbers = rest; trying = [top]; };
       
  # trying is the list of operators and numbers that we are currently trying
  # [ 3 * 5 + 2 + 5 ]
  solveEquationHelper = {total, numbers, trying}:
  let
    top = builtins.head numbers;
    rest = builtins.tail numbers;
    addSol = solveEquationHelper {
      inherit total;
      trying = (trying ++ ["add"] ++ [top]);
      numbers = rest;
    };
    mulSol = solveEquationHelper {
      inherit total;
      trying = (trying ++ ["mul"] ++ [top]);        
      numbers = rest;
    };
    solve = true;
  in
    if (numbers == []) && solved then
      ([addSol] ++ [mulSol])
    else
      [];
      
  solvePart1 = p:
    let
      f = readFile p;
      puzzle = getPuzzle f;
    in
    map (eq: solveEquation eq) puzzle;
in
solvePart1 ./test_input
