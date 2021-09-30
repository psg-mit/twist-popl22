fun main () : (qubit & qubit)<P> =
  let x : qubit<P> = qinit () in
  let y : qubit<P> = qinit () in
  cast<P>(CNOT (entangle<M>(x, y)))
