module OUTFIT

    syntax Boolean ::= True() | False()
    syntax Color ::= Black() | White()
    syntax ColoredHat ::= Hat(Color)
    syntax ColoredShirt ::= Shirt(Color)
    syntax ColoredPants ::= Pants(Color)
    syntax ColoredShoes ::= Shoes(Color)

    syntax Outfit ::= OutfitParts(ColoredHat, ColoredShirt, ColoredPants, ColoredShoes)
    syntax Boolean ::= outfitMatching(Outfit) [function]

    rule outfitMatching(OutfitParts(Hat(C), Shirt(C), Pants(C), Shoes(C))) => True()

endmodule