fun f () : (qubit & qubit)<M> =
  let x : qubit<P> = qinit () in
  let y : qubit<P> = qinit () in
  CNOT (entangle<P>(x, y))

fun main () : unit = ()
