module LESSON-04-D

  syntax Boolean ::= "true" [literal] | "false" [literal]
                   | "(" Boolean ")" [atom, bracket]
                   | "!" Boolean [not, function]
                   | Boolean "&&" Boolean [and, function]
                   | Boolean "^" Boolean [xor, function]
                   | Boolean "|" Boolean [or, function]

  syntax priorities literal atom > not > and > xor > or
  syntax left and
  syntax left xor
  syntax left or
endmodule