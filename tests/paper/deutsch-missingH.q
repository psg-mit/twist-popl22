fun deutsch (uf : (qubit & qubit)<P> -> (qubit & qubit)<P>) : bool =
    let (x : qubit<P>, y : qubit<P>) = uf (entangle<P>(H (qinit ()), (X (qinit ())))) in
    let _ = measure (y) in
    measure (H (x))

fun cnot (xy : (qubit & qubit)<P>) : (qubit & qubit)<P> = CNOT (xy)

fun always_true (xy : (qubit & qubit)<P>) : (qubit & qubit)<P> =
    let (x : qubit<M>, y : qubit<M>) = xy in
    cast<P>(entangle<M>(x, X (y)))

fun always_false (xy : (qubit & qubit)<P>) : (qubit & qubit)<P> = xy

fun main () : ((bool * bool) * bool) = ((deutsch (always_false), deutsch (always_true)), deutsch (cnot))
