fun main () : qubit<M> = let x = H (qinit ()) in if measure (x) then let y = X (qinit ()) in let z = H (qinit ()) in let _ = measure(y) in z else qinit ()
