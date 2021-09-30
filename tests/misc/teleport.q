fun bell_pair () : (qubit & qubit)<P> =
    let q1 : qubit<P> = qinit () in
    let q1 : qubit<P> = H (q1) in
    let q2 : qubit<P> = qinit () in
    CNOT (entangle<P>(q1, q2))

fun teleport (q1 : qubit<P>) : qubit<P> =
    let (q2 : qubit<M>, q3 : qubit<M>) = split<M>(cast<M>(bell_pair ())) in
    let (q1 : qubit<M>, q2 : qubit<M>) = split<M>(CNOT (entangle<M>(cast<M>(q1), q2))) in
    let q1 : qubit<M> = H (q1) in
    let (q2 : qubit<M>, q3 : qubit<M>) = split<M>(CNOT (entangle<M>(q2, q3))) in
    let (q1 : qubit<M>, q3 : qubit<M>) = split<M>(CZ (entangle<M>(q1, q3))) in
    let all : ((qubit & qubit) & qubit)<P> = cast<P>(entangle<M>(entangle<M>(q1, q2), q3)) in
    let (discard : (qubit & qubit)<P>, q3 : qubit<P>) = split<P>(all) in
    let discard : (bool * bool) = measure (discard) in
    q3

fun main () : qubit<P> = teleport (H (qinit ()))
