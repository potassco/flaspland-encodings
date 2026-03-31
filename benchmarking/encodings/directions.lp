    dir(n).           dir(s).          dir(w).           dir(e).
inverse(n,s).     inverse(s,n).    inverse(w,e).     inverse(e,w).
   left(n,w).        left(s,e).       left(w,s).        left(e,n).
  right(n,e).       right(s,w).      right(w,n).       right(e,s).
 offset(n,-1,0).   offset(s,1,0).   offset(w,0,-1).   offset(e,0,1).
