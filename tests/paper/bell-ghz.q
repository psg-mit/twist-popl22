fun main () : (qubit & qubit)<P> =
  let q1 = H (qinit ()) in
  let (q1 : qubit<M>, q2 : qubit<M>) = CNOT (q1, qinit ()) in
  let (q1 : qubit<M>, q3 : qubit<M>) = CNOT (q1, qinit ()) in
  let _ = measure q3 in
  entangle<P>(q1, q2)
