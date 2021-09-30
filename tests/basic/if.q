fun f () : qubit<M> =
  let x : qubit<P> = qinit () in
  if measure (qinit ()) then x else X (x)

fun main () : qubit<M> = f ()
