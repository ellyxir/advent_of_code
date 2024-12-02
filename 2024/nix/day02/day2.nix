with import <nixpkgs> {};
let
  # FUNCTIONS

  # absolute value
  abs = n: if n >= 0 then n else -n;

  # [ "7 2 3" "3 2 1"]
  splitlines = file: lib.init (lib.splitString "\n" file);

  # take in a string containing numbers return a list of numbers
  # "7 2 3" -> [7 2 3]
  numToList = s: map lib.toInt (lib.splitString " " s);

  # [3 2 1]
  # pred: (a -> a -> bool)
  checklist = pred: xs: builtins.elemAt (lib.foldl' 
    (
      # acc [ prev_elem bool ]
      acc: e: 
        let
          last_elem = builtins.head acc;
          isPred = builtins.elemAt acc 1;
        in
          if last_elem == "sentinel" then
            [e true]
          else
            [e (isPred && (pred last_elem e))]
    )
    ["sentinel" true] 
    xs
  ) 1;

  # predicate to use with checklist
  withinRange = x: y: abs(x - y) >= 1 && abs(x - y) <= 3; 

  # functions that run on reports
  isDecreasing = xs: checklist (x: y: x > y) xs;
  isIncreasing = xs: checklist builtins.lessThan xs; 
  isWithinRange = xs: checklist withinRange xs;
  checkReport = xs: 
    ( (isDecreasing xs) || (isIncreasing xs) ) &&
    isWithinRange xs;

  # returns permutations for reports by removing each element once 
  reportPermutations = xs : (builtins.foldl' 
    ({left, right, acc}: e: 
      let
        withoutElem = left ++ (builtins.tail right);
        new_left = left ++ [e]; 
        new_right = builtins.tail right;
        new_acc = acc ++ [withoutElem];
      in
        {
          left = new_left;
          right = new_right;
          acc = new_acc;
        }
    ) 
    {
      left = [];
      right = xs;
      acc = [xs];
    }
    xs).acc;
  
  # [
  #    [ [7 2 1] [7 2] [2 1] [7 1] ]
  #    [ [4 2 1] [4 2] [2 1] [4 1] ]
  # ]
  allPermutations = map reportPermutations reportslist;

  checkReportPermutations = reports: 
    lib.any 
      (v: v)
      (map (report: checkReport report) reports);

  # MANIPULATIONS
  file = lib.readFile ./puzzle_input_day2_1;

  # [ [7 2 3] [3 2 1] ]
  reportslist = map numToList (splitlines file);
  part1_result = lib.count (x: x) (map checkReport reportslist);
  part2_result = lib.count (x: x) (map checkReportPermutations allPermutations);
in
{
  part1 = part1_result;
  part2 = part2_result;
}
