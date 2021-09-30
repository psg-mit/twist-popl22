fun main () : (qubit & qubit)<P> =
  let x : qubit<P> = qinit () in
  let y : qubit<P> = qinit () in
  let (x : qubit<M>, y : qubit<M>) = split<M>(cast<M>(CNOT(entangle<P>(x, y)))) in
  let xy : (qubit & qubit)<M> = entangle<M>(x, y) in
  cast<P>(xy)
