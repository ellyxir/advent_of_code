with import <nixpkgs> {};
let
  #
  # utility functions
  #
  boolToString = b: if b then "true" else "false";
  bottomHalf = {x,y}: y >= x;  
  bottomHalf' = {x,y,width}: y >= width - 1 - x;

  #
  # pure functions
  #
  getLinesFromFile = p: 
    let
      file = builtins.readFile p; 
    in
      lib.init (lib.splitString "\n" file);

  scanXmasLine = line: 
    let
      lines_split = lib.splitString "XMAS" line;
      len = builtins.length lines_split;
    in
      len - 1;

  # lineGenerator = puzzle: 
  #   let
  #     new_puzzle = puzzle;
  #   in
  #     new_puzzle;

  # takes in the puzzle and the x,y coordinate and returns the character
  # in that position
  getXY = puzzle: {x, y}:
    let
      row = builtins.elemAt puzzle y;
    in
      lib.strings.substring x 1 row;

  # functions tells you about the character in the current position
  # and gives you the x,y for the next position
  # {
  #   char = "X";
  #   nextPos = {x=3; y=0;};
  #   newLine = false;
  #   isEnd = false;
  # }
  charGenFn = puzzle: incFn: {x,y}: 
    let
      curCharInfo = incFn puzzle {inherit x y;};
      result = {
        char = getXY puzzle {inherit x y;};
        inherit (curCharInfo) nextPos newLine isEnd;
        __toString = self: "[charGenFn nextChar=${self.char} nextPos=${builtins.toString self.nextPos.x},${builtins.toString self.nextPos.y} newLine=${boolToString self.newLine} isEnd=${boolToString self.isEnd}]";
      };
    in
      result;
      
  # charGen that returns us the currentCharacter from position passed in
  # along with flags for the character (new line, end, next pos)
  genPuzzleVariant = origPuzzle: startPosFn: charGenFn: incFn:
    let
      startPos = startPosFn origPuzzle;
      startCharInfo = charGenFn origPuzzle incFn startPos;
      initialList = [startCharInfo.char] ;
    in
      #builtins.trace "startCharInfo=${builtins.toString startCharInfo} initialList=${builtins.toString initialList}" 
      (genPuzzleVariantHelper origPuzzle initialList charGenFn incFn startCharInfo);

  genPuzzleVariantHelper = origPuzzle: updatedPuzzle: charGenFn: incFn: {char, nextPos, newLine, isEnd, ...}:
  if isEnd then
    updatedPuzzle
  else
    let
      updatedCharInfo = charGenFn origPuzzle incFn nextPos; 
      currentString = lib.last updatedPuzzle; 
      updatedString = currentString + updatedCharInfo.char;

      newPuzzle = if newLine then
        updatedPuzzle ++ [updatedCharInfo.char]
      else
        (lib.init updatedPuzzle) ++ [updatedString];
    in
      #builtins.trace "updatedCharInfo=${builtins.toString updatedCharInfo}, newPuzzle=${builtins.toString newPuzzle}"
      (genPuzzleVariantHelper origPuzzle newPuzzle charGenFn incFn updatedCharInfo);
      
  # 
  # puzzle variants code
  #
  # returns the starting position for the puzzle assuming "RtLt"
  # startRtLt = puzzle: 
  #   {
  #     x = (puzzleWidth puzzle) - 1; 
  #     y = 0;
  #   };
  startUpDn = puzzle:
    {
      x = 0;
      y = 0;
    };
  # startDnUp = puzzle:
  #   {
  #     x = 0;
  #     y = (puzzleHeight puzzle) - 1;
  #   };
  startTopLeftBottomRight = puzzle:
    {
      x = (puzzleWidth puzzle) - 1;
      y = 0;
    };
  startTopRightBottomLeft = puzzle:
    {
      x = 0;      
      y = 0;
    };   

  # takes in the puzzle input, the current "position"
  # returns the next position
  # {
  #   nextPos = {x=3; y=0;};
  #   newLine = false;
  #   isEnd = false;
  # }
  # rTLtIncFn = puzzle: {x,y}: 
  #   let
  #     nextx = if x == 0 then ((puzzleWidth puzzle) - 1) else x - 1; 
  #     nexty = if x == 0 then y + 1 else y;
  #     last_row_num = (builtins.length puzzle) - 1;
  #   in
  #   rec {
  #     nextPos = {x=nextx; y=nexty;};
  #     newLine = nextx == 0;
  #     isEnd = (y == last_row_num) && newLine;
  #   };

  uPDnIncFn = puzzle: {x,y}: 
    let
      lastColumnIndex = (puzzleWidth puzzle) - 1;
      lastRowIndex = (puzzleHeight puzzle) - 1;
      nextx = if y == lastRowIndex then x+1 else x;
      nexty = if y == lastRowIndex then 0 else y + 1;
    in
    rec {
      nextPos = {x=nextx; y=nexty;};
      newLine = y == lastRowIndex;
      isEnd = (x == lastColumnIndex) && newLine;
      __toString = self: "[uPDnIncFn nextPos=${builtins.toString self.nextPos.x},${builtins.toString self.nextPos.y} newLine=${boolToString self.newLine} isEnd=${boolToString self.isEnd}]";
    };

  # dNUPIncFn = puzzle: {x,y}: 
  #   let
  #     lastColumnIndex = (puzzleWidth puzzle) - 1;
  #     lastRowIndex = 0;
  #     nextx = if y == lastRowIndex then x+1 else x;
  #     nexty = if y == lastRowIndex then ((puzzleHeight puzzle) - 1) else y - 1;
  #     result = rec {
  #       nextPos = {x=nextx; y=nexty;};
  #       newLine = nexty == lastRowIndex;
  #       isEnd = (x == lastColumnIndex) && newLine;
  #       __toString = self: "[dNUPIncFn nextPos=${builtins.toString self.nextPos.x},${builtins.toString self.nextPos.y} newLine=${boolToString self.newLine} isEnd=${boolToString self.isEnd}]";
  #     };
  #   in
  #   #builtins.trace "dNUPIncFc=${builtins.toString result}"
  #   result;

   topLeftBottomRightIncFn = puzzle: {x,y}: 
     let
      lastColumnIndex = (puzzleWidth puzzle) - 1;
      num_rows = builtins.length puzzle;
      isBottomHalf = bottomHalf {inherit x y;};
      
      nextx = 
        if isBottomHalf then
          if (y == (num_rows - 1)) then 0 else x + 1
        else
          if x == lastColumnIndex then (lib.max (x - (y + 1)) 0) else x + 1;
      
      nexty = 
        if isBottomHalf then
          if (y == num_rows - 1) then 
            (lastColumnIndex - x) + 1
          else
            y + 1        
        else
          if (x == lastColumnIndex) then 0 else y + 1;

      result = {
        nextPos = {x=nextx; y=nexty;};
        newLine = if isBottomHalf then (y == num_rows - 1) else (x == lastColumnIndex);
        isEnd = (x == 0) && (y == builtins.length puzzle - 1);
        __toString = self: "[dNUPIncFn isBottom=${boolToString isBottomHalf} num_rows=${builtins.toString num_rows} curX=${builtins.toString x} curY=${builtins.toString y} nextPos=${builtins.toString self.nextPos.x},${builtins.toString self.nextPos.y} newLine=${boolToString self.newLine} isEnd=${boolToString self.isEnd}]";
      };
    in
    #builtins.trace "diagonal=${builtins.toString result}"
    result;

   topRightBottomLeftIncFn = puzzle: {x,y}: 
     let
      numRows = builtins.length puzzle;
      width = puzzleWidth puzzle;
      isBottomHalf = bottomHalf' {inherit x y; width=width;};
      
      nextx = 
        if isBottomHalf then
          if y == numRows - 1 then width - 1 else x - 1
        else
          if x == 0 then y + 1 else x - 1;
      
      nexty = 
        if isBottomHalf then
          if (y == numRows - 1) then 
            x + 1
          else
            y + 1        
        else
          if (x == 0) then 0 else y + 1;

      result = {
        nextPos = {x=nextx; y=nexty;};
        newLine = if isBottomHalf then (y == numRows - 1) else (x == 0);
        isEnd = (y == numRows - 1) && (x == builtins.length puzzle - 1);
        __toString = self: "[isBottom=${boolToString isBottomHalf} num_rows=${builtins.toString numRows} curX=${builtins.toString x} curY=${builtins.toString y} nextPos=${builtins.toString self.nextPos.x},${builtins.toString self.nextPos.y} newLine=${boolToString self.newLine} isEnd=${boolToString self.isEnd}]";
      };
    in
    #builtins.trace "diagonal=${builtins.toString result}"
    result;

    
  puzzleWidth = puzzle: 
    builtins.stringLength (builtins.head puzzle);

  puzzleHeight = puzzle:
    builtins.length puzzle;
    
  #
  # manipulations
  #
  origPuzzle = getLinesFromFile ./input_part1;

  reverseString = s: 
    if s == "" then
      s
    else
      let
        len = builtins.stringLength s;
        firstChar = builtins.substring 0 1 s;      
        rest = builtins.substring 1 (len - 1) s; 
      in
      (reverseString rest) + firstChar;

  allWays =  rec {
    ltRt = origPuzzle;
    rTLt = map reverseString origPuzzle;
    uPDn = genPuzzleVariant origPuzzle startUpDn charGenFn uPDnIncFn;
    dnUp = map reverseString uPDn;
    diag1 = genPuzzleVariant origPuzzle startTopRightBottomLeft charGenFn topRightBottomLeftIncFn;
    diag2 = map reverseString diag1;
    diag3 = genPuzzleVariant origPuzzle startTopLeftBottomRight charGenFn topLeftBottomRightIncFn; 
    diag4 = map reverseString diag3;
  };

  allWaysFlattened = lib.flatten (lib.attrsets.attrValues allWays);

  sum = l: builtins.foldl' (acc: n: n + acc) 0 l;
  part1solve = sum (map scanXmasLine allWaysFlattened);

  allPos = size: 
    builtins.foldl' (acc: yPos: 
        acc ++ builtins.genList (p: {x=p; y=yPos;}) size
      ) 
      []
      (builtins.genList (x: x) size);

  letterGrid = size: map (pos: 
    {
      inherit (pos) x y;
      letter = (getXY origPuzzle pos);
    }) 
    (allPos size); 
    
  legalPos = {x,y}: size:
    x >= 0 && x <= (size - 1) && y >= 0 && y <= (size - 1);

  topLeft = {x,y}: origPuzzle: 
    let 
      newPos = {x=(x - 1); y=(y - 1);};
      size = builtins.length origPuzzle;
      c = 
        if (legalPos newPos size) then
          getXY origPuzzle newPos 
        else
          ".";
    in
      c;
  topRight = {x,y}: origPuzzle: 
    let 
      newPos = {x=(x + 1); y=(y - 1);};
      size = builtins.length origPuzzle;
      c = 
        if (legalPos newPos size) then
          getXY origPuzzle newPos 
        else
          ".";
    in
      #builtins.trace "topRight: posX=${builtins.toString x} posY=${builtins.toString y} c=${c}"
      c;

  bottomLeft = {x,y}: origPuzzle: 
    let 
      newPos = {x=(x - 1); y=(y + 1);};
      size = builtins.length origPuzzle;
      c = 
        if (legalPos newPos size) then
          getXY origPuzzle newPos 
        else
          ".";
    in
      c;
  bottomRight = {x,y}: origPuzzle: 
    let 
      newPos = {x=(x + 1); y=(y + 1);};
      size = builtins.length origPuzzle;
      c = 
        if (legalPos newPos size) then
          getXY origPuzzle newPos 
        else
          ".";
    in
      c;

  allAPos = builtins.filter ({x,y,letter}: letter == "A") (letterGrid (puzzleWidth origPuzzle));

  aboutPos = {x,y}: origPuzzle: 
    (topLeft {inherit x y;} origPuzzle) + 
    (topRight {inherit x y;} origPuzzle) +
    (bottomLeft {inherit x y;} origPuzzle) +
    (bottomRight {inherit x y;} origPuzzle);

  isAMas = {x,y}: origPuzzle:
    let 
      aboutString = aboutPos {inherit x y;} origPuzzle;
    in
      # builtins.trace "pos=${builtins.toString x},${builtins.toString y}--${aboutString}"
      (aboutString == "MSMS") ||  
      (aboutString == "MMSS") ||  
      (aboutString == "SMSM") ||  
      (aboutString == "SSMM");

  countBooleans = l: sum (map (e: if e then 1 else 0) l); 
in
  {
    part1 = part1solve;
    part2 = countBooleans (map ({letter,x,y}: isAMas {inherit x y;} origPuzzle) allAPos);
  }
