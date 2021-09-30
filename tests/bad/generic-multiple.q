fun f (x : (qubit<'p> * qubit<'q>)) : (qubit<'q> * qubit<'p>) = let (x : qubit<'p>, y : qubit<'q>) = x in (x, y)
fun main () : unit = ()
