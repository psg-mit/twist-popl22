fun f (x : (qubit<'p> * qubit<'q>)) : (qubit<'q> * qubit<'p>) = let (x : qubit<'p>, y : qubit<'q>) = x in (y, x)
fun main () : (qubit<'p> * qubit<'q>) -> (qubit<'q> * qubit<'p>) = f
