module LESSON-10
    imports STRING
    imports INT
    imports BOOL

    syntax String ::= mangle(String) [function]
    syntax String ::= getFirsWord(hayStack : String) [function]

    rule mangle(S) => getFirsWord(S)

    rule getFirsWord(S) => substrString(S, 0, findChar(S, " ", 0)) 
                                +String " " 
                                +String getFirsWord(
                                            substrString(S, findChar(S, ".", 0) +Int 2, lengthString(S))) 
                            requires lengthString(S) >Int findChar(S, ".", 0) +Int 1

    rule getFirsWord(_) => "." [owise]
endmodule