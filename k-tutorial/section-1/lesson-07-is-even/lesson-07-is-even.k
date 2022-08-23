module LESSON-07-IS-EVEN-SYNTAX
    import INT-SYNTAX
    import BOOL-SYNTAX

    syntax Bool ::= isEven(Int) [function]
endmodule

module LESSON-07-IS-EVEN
    import LESSON-07-IS-EVEN-SYNTAX
    import INT

    rule isEven(I) => true requires I modInt 2 ==Int 0
    rule isEven(_) => false [owise]
endmodule