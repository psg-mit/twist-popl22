fun f (x : qubit<'q>) : qubit<'q> = let _ = measure (x) in cast<'q>(qinit ())
fun main () : unit = ()
