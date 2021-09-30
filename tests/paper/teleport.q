fun bell_pair () : (qubit & qubit)<P> =
    CNOT (H (qinit ()), qinit ())

fun teleport (q1 : qubit<P>) : qubit<P> =
    let (q2 : qubit<M>, q3 : qubit<M>) = bell_pair () in
    let (q1 : qubit<M>, q2 : qubit<M>) = CNOT (q1, q2) in
    let q1 = H (q1) in
    let (q2 : qubit<M>, q3 : qubit<M>) = CNOT (q2, q3) in
    let (q1 : qubit<M>, q3 : qubit<M>) = CZ (q1, q3) in
    let all : ((qubit & qubit) & qubit)<P> = ((q1, q2), q3) in
    let (_ : (qubit & qubit)<P>, q3 : qubit<P>) = all in
    q3

fun main () : qubit<P> = teleport (H (qinit ()))
