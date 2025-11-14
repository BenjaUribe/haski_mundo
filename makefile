all:
	ghc -package gloss -o game Main.hs Game.hs

clean:
	rm -f *.hi *.o game