with import <nixpkgs> {};
let
  sum = l: builtins.foldl' (acc: e: acc + e) 0 l;

  # returns the second element of a list
  second = l: builtins.elemAt l 1;

  isOdd = n: (n - (n / 2 * 2) == 1);
  isEven = n: ! (isOdd n);
  
  # returns the middle element of a list
  middle = l: 
    let
      len = builtins.length l;
      midIndex = ((len - 1) / 2);
    in
    if isEven len then 
      throw "cannot get middle of odd length list: list=${builtins.toString l}" 
    else
      builtins.elemAt l midIndex;

  getPuzzleFile = p: lib.readFile p;

  # parses puzzle input 
  # returns attr set: { orderingRules = [ [int int] ... ]; updates = [ [int ...] ... ] }
  toPuzzle = s: 
    let
      l = lib.splitString "\n\n" s;
      or1 = builtins.head l;
      or2 = lib.splitString "\n" or1;
      or3 = map (e: lib.splitString "|" e) or2;
      orRules = map (e: [(lib.toInt (builtins.head e)) (lib.toInt (builtins.elemAt e 1))]) or3;

      up1 = builtins.elemAt l 1;
      up2 = lib.splitString "\n" up1;
      up3 = lib.init up2; # drop the empty line
      up4 = map (e: lib.splitString "," e) up3;
      up = map (update: 
          (map (e: lib.toInt e) update)
        ) up4;  
    in
      { 
        orderingRules = orRules;
        updates = up;
      };

  
  # given a page number, what page numbers are not allowed after it
  # returns a list of page numbers [int ...]
  pagesNotAllowedAfter = page: orderingRules:
    # construct all pages that must be before `first`
    builtins.foldl' (acc: orderPair: if ((second orderPair) == page) then ([(builtins.head orderPair)] ++ acc) else acc) [] orderingRules;

  # give pages 'page' and 'after', is 'after' allowed after 'page' according to orderingRules
  pageOrderAllowed = page: after: orderingRules:
    let
      illegalPagesAfter = pagesNotAllowedAfter page orderingRules;
      isIllegal = builtins.elem after illegalPagesAfter;
    in
      ! isIllegal;

  # returns if a given update 'l' is legal or not according to orderingRules
  checkUpdate = l: orderingRules:
    if ((builtins.length l) <= 1) then true else
    let
      firstPage = builtins.head l;
      rest = builtins.tail l;
      firstPageLegal = builtins.foldl' (acc: otherPage: ((pageOrderAllowed firstPage otherPage orderingRules) && acc)) true rest;
    in
      firstPageLegal && checkUpdate rest orderingRules;
                 
  # constructs a "legal" update from the passed in list of pages
  constructUpdate = l: orderingRules:
    let 
      new_update = constructUpdateHelper l [] orderingRules;
    in
    new_update;
    
  # parameter 'sorted' passes checkUpdate
  # returns a correctly ordered of l
  constructUpdateHelper = l: sorted: orderingRules:
    if l == [] then
      sorted
    else
      let
        page = builtins.head l;
        tail = builtins.tail l;
        updated_sorted = insertPage page sorted orderingRules;  
      in
        constructUpdateHelper tail updated_sorted orderingRules;

  # inserts a page to an existing update such that the update is still valid
  insertPage = page: l: orderingRules:
    insertPageHelper page [] l orderingRules;
  
  insertPageHelper = page: l1: l2: orderingRules:
    let
      # try inserting it to the beginning of l2 and see if l1++l2 is valid
      possible_update = l1 ++ [page] ++ l2;
      is_valid = checkUpdate possible_update orderingRules;
    in
    if is_valid then
      possible_update
    else
      if (l2 == []) then 
        throw "illegal" 
      else
        insertPageHelper page (l1 ++ [(builtins.head l2)]) (builtins.tail l2) orderingRules;
    
  solvePart1 = p:
    let
      testsPassed = builtins.all (e: e) tests;
      puzzle = toPuzzle (getPuzzleFile p);
      passingPuzzles = builtins.filter (e: checkUpdate e puzzle.orderingRules) puzzle.updates;
      middles = map middle passingPuzzles;
    in
      if testsPassed then
        sum middles
      else
        builtins.throw "tests failed"; 

  solvePart2 = p:
    let
      testsPassed = builtins.all (e: e) tests;
      puzzle = toPuzzle (getPuzzleFile p);
      fixed_updates = builtins.foldl' 
        (acc: update: 
          if checkUpdate update puzzle.orderingRules then
            acc
          else
            [(constructUpdate update puzzle.orderingRules)] ++ acc
        ) 
        [] 
        puzzle.updates;
      middles = map middle fixed_updates;
    in
    if testsPassed then
      sum middles
    else
      builtins.throw "tests failed";
      
  # cheap unit testing
  tests = [
    #((constructUpdate [25 10 15] [[10 15] [15 25]]))
    ((insertPage 3 [1 4 10] [[3 10][4 3][1 4] [4 10] [1 10]]) == [1 4 3 10])
    ((insertPage 3 [1 4 10] [[3 10][1 4] [4 10] [1 10]]) == [3 1 4 10])
    ((sum [1 2 3 4]) == 10)
    ((middle [1 20 3]) == 20) ((middle [1]) == 1)
    (! (isOdd 4)) (! (isOdd 0)) (isOdd 5) 
    (checkUpdate [ 1 2 3 ] [[1 2] [2 3]])
    (!(checkUpdate [10 2 3 1] [[1 2][10 2]]))
    ((pagesNotAllowedAfter 2 [[10 2] [5 2] [ 7 7 ] [12 2]]) == [12 5 10])
    (pageOrderAllowed 3 4 [[1 10][10 4][3 4][2 10]])
    (!(pageOrderAllowed 4 3 [[1 10][10 4][3 4][2 10]]))
  ];

in
  {
    part1 = solvePart1 ./input;
    part2 = solvePart2 ./input;
  }
