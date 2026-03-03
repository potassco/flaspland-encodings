% end(Z,C,LAT).
% drive(Z,C',C,N)

% assuming we visit the goal cell once and only once
delay(Z, N-LAT) :- end(Z, C, LAT), drive(Z, _, C, N), N > LAT.
delay(Z, 0)     :- end(Z, C, LAT), drive(Z, _, C, N), N <= LAT.

% minimize over all individual delays
#minimize { D, Z : delay(Z, D) }.