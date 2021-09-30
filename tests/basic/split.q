fun main () : (qubit<P> * qubit<P>) =
  let x = X (qinit ()) in
  let y = qinit () in
  let xy = CNOT (x, y) in
  split<P>(xy)
