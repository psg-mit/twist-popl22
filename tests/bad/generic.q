fun f (x : qubit<'q>) : qubit<'q> = let _ = measure (x) in qinit ()
fun main () : unit = ()
