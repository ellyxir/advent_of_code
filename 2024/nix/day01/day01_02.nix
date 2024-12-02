with builtins;
with import <nixpkgs> {};
with import ./util.nix;
let result = lib.pipe (readFile ./input) [
    # remove ending newline
    (lib.strings.removeSuffix "\n")

    (lib.splitString "\n")

    (map (lib.splitString "   "))

    (map (l: [(lib.toInt (head l)) (lib.toInt (elemAt l 1))]))

    (foldl' 
      ({left, right}: e: 
        { left = [(head e)] ++ left; right = [(elemAt e 1)] ++ right; }
      ) 
      { left = []; right = []; }
    )
];
  similarity_score = left: right: 
    foldl' 
      (
        {count_list, score}: e: 
          let
            c = count e count_list;
            val = e * c;
          in
          {count_list=count_list; score=score + val ;}
      ) 
      {count_list=right;score=0;} 
      left;
in
(similarity_score result.left result.right).score
