fun main () : qubit<M> =
  let x : qubit<P> = qinit () in
  let y : qubit<P> = qinit () in
  if measure (qinit ()) then x else y
