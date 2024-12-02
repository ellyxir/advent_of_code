with builtins;
with import <nixpkgs> {};
with import ./util.nix;
lib.pipe (readFile ./input) [
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

    ({left, right}: {left = sort lessThan left; right = sort lessThan right;})

    ({left, right}: diff left right) 
]
