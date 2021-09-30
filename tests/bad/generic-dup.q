fun f (x : (qubit<'p> * qubit<'p>)) : (qubit<'p> * qubit<'p>) = let (x : qubit<'p>, y : qubit<'p>) = x in (x, y)
fun main () : unit = ()
