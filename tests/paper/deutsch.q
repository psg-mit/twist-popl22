fun deutsch (uf : (qubit & qubit)<P> -> (qubit & qubit)<P>) : bool =
    let input : (qubit & qubit)<P> = (H (qinit ()), H (X (qinit ()))) in
    let (x : qubit<P>, _ : qubit<P>) = uf (input) in
    measure (H (x))

fun cnot (xy : (qubit & qubit)<P>) : (qubit & qubit)<P> = CNOT (xy)

fun always_true (xy : (qubit & qubit)<P>) : (qubit & qubit)<P> =
    let (x : qubit<M>, y : qubit<M>) = xy in
    cast<P>(entangle<M>(x, X (y)))

fun always_false (xy : (qubit & qubit)<P>) : (qubit & qubit)<P> = xy

fun main () : ((bool * bool) * bool) = ((deutsch (always_false), deutsch (always_true)), deutsch (cnot))
