fun main () : (qubit & qubit)<P> =
    let q1 : qubit<P> = qinit () in
    let q1 : qubit<P> = H (q1) in
    let q2 : qubit<P> = qinit () in
    CNOT (entangle<P>(q1, q2))
