with builtins; rec {
  abs = x: if x > 0 then x else x * (-1);

  diff = l1: l2: 
    if l1 == [] then 
      0
    else 
      abs(head(l1) - head(l2)) + (diff (tail(l1)) (tail(l2)));

  count = e: xs: 
    if xs == [] then
      0
    else
      if head(xs) == e then 
        1 + (count e (tail xs))
      else
        count e (tail xs);
}
