fun main () : qubit<P> =
  let x : qubit<P> = qinit () in
  let x : qubit<M> = if measure (qinit ()) then x else X (x) in
  cast<P>(x)
