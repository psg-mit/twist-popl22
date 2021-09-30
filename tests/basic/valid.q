fun f () : (qubit & qubit)<P> =
  let x : qubit<P> = qinit () in
  let y : qubit<P> = qinit () in
  CNOT (entangle<P>(x, y))

fun main () : (qubit & qubit)<P> = f ()
