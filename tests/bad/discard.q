fun main () : (qubit & qubit)<P> =
  let x : qubit<P> = qinit () in
  let y : qubit<M> = qinit () in
  cast<P>(CNOT (entangle<P>(x, qinit ())))
