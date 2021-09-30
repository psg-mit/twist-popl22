all:
	rm -f ./twist; dune build && ln -s ./_build/default/src/main.exe ./twist

clean:
	dune clean && rm -f ./twist

check:
	./twist -no_print tests/paper/teleport.q
	./twist -no_print tests/paper/teleport-noCZ.q || true
	./twist -no_print tests/paper/teleport-measure.q || true
	./twist -no_print tests/paper/andoracle.q
	./twist -no_print tests/paper/andoracle-notuncomputed.q || true
	./twist -no_print tests/paper/bell-ghz.q || true
	./twist -no_print tests/paper/deutsch.q
	./twist -no_print tests/paper/deutsch-missingH.q || true
	./twist -no_print tests/paper/deutschjozsa.q
	./twist -no_print tests/paper/deutschjozsa-mixedinit.q || true
	./twist -no_print tests/paper/grover.q
	./twist -no_print tests/paper/grover-badoracle.q || true
	./twist -no_print tests/paper/qft.q
	./twist -no_print tests/paper/shorcode.q
	./twist -no_print tests/paper/shorcode-drop.q || true
	./twist -no_print tests/multiply/multiply4.q
	./twist -no_print tests/multiply/multiply4-notinverse.q || true
	./twist -no_print tests/multiply/multiply12.q
	./twist -no_print tests/multiply/multiply12-notinverse.q || true
