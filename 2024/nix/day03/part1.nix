with import <nixpkgs> {};
let
  # pure functions
  # ["3" "4"] -> [3 4]
  listToNum = l: map lib.toInt l;

  #[3 4 3] -> 12
  multList = l: lib.foldl' (acc: e: acc * e) 1 l; 

  # sum a list up
  sum = l: lib.foldl' (acc: e: acc + e) 0 l;
   
  # part1 solve
  # takes in a string that we need to find mul(n,n) in and 
  # perfoms the multiplication
  decode = s: 
    let
      muls = lib.split "mul[(]([0-9]{1,3}),([0-9]{1,3})[)]" s;
      m1 = lib.filter lib.isList muls;
      m2 = map listToNum m1;
    in 
      map multList m2;
    
  part1_solve = sum (decode (lib.readFile ./part1_input));

  # dirty non pure manipulations
  file = lib.readFile ./part1_input;

  # [ "xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)un" "?mul(8,5))\n" ]
  # each element begins with a do, but may contain donts
  tmpDoList = lib.splitString "do()" file;

  # remove don't() to end of string
  # string -> string
  removeDont = s: lib.head (lib.split "don't[(][)]" s);
  
  # list of only enabled mul() fragments, just need to process them
  codeFragments = map removeDont tmpDoList;
in
  {
    part1 = part1_solve;
    part2 = sum (lib.flatten (map decode codeFragments));
  }
