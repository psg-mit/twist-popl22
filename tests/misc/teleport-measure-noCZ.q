fun bell_pair () : (qubit & qubit)<P> =
    let q1 : qubit<P> = qinit () in
    let q1 : qubit<P> = H (q1) in
    let q2 : qubit<P> = qinit () in
    CNOT (entangle<P>(q1, q2))

fun teleport (q1 : qubit<P>) : qubit<P> =
  let (q2 : qubit<M>, q3 : qubit<M>) = bell_pair () in
  let (q1 : qubit<M>, q2 : qubit<M>) = CNOT (q1, q2) in
  let q1 : qubit<M> = H (q1) in
  let q3 = if measure (q2) then X (q3) else q3 in
  let q3 = if measure (q1) then X (q3) else q3 in
  cast<P>(q3)

fun main () : qubit<P> = teleport (H (qinit ()))
