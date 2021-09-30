fun main () : qubit<P> =
  let x : qubit<P> = qinit () in
  let x : qubit<M> = cast<M>(x) in
  cast<P>(x)
