module LESSON-12-CONCAT-SYNTAX
  imports STRING-SYNTAX

  syntax Strings ::= List{String,","}
endmodule

module LESSON-12-CONCAT
  imports LESSON-12-CONCAT-SYNTAX
  imports STRING

  syntax String ::= concat(Strings) [function]
  rule concat(S:String) => S
  rule concat(S1:String, S2:String, Ss:Strings) => concat(S1 +String S2, Ss)
endmodule