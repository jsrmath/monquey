all:
	happy monquey.y
	ghc monquey-ir.hs monquey-codegen.hs monquey.hs monquey-lexer.hs

clean:
	rm *.o *.hi monquey monquey.hs
