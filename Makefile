all:
	happy mongo.y
	ghc mongo-ir.hs mongo-codegen.hs mongo.hs

clean:
	rm *.o *.hi mongo mongo.hs