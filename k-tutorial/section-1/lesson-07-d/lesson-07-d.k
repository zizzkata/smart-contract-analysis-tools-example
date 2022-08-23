module LESSON-07-D
  imports BOOL
  imports INT

  syntax Grade ::= "letter-A" 
                 | "letter-B"
                 | "letter-C"
                 | "letter-D"
                 | "letter-F"
                 | gradeFromPercentile(Int) [function]

  rule gradeFromPercentile(I) => letter-A requires I >=Int 90 [priority(50)]
  rule gradeFromPercentile(I) => letter-B requires I >=Int 80 [priority(51)]
  rule gradeFromPercentile(I) => letter-C requires I >=Int 70 [priority(52)]
  rule gradeFromPercentile(I) => letter-D requires I >=Int 60 [priority(53)]
  rule gradeFromPercentile(_) => letter-F                     [priority(54)]
endmodule