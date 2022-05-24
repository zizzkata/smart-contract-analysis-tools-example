module LESSON-02-D

    syntax Container ::= Jar(Fruit)
    syntax Fruit ::= Apple() | Peer()

    syntax Fruit ::= contentsOfJar(Container) [function]

    rule contentsOfJar(Jar(F)) => F

endmodule