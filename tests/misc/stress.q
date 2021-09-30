type t = (((qubit & qubit) & (qubit & qubit)) & ((qubit & qubit) & (qubit & qubit)))<P>

fun main () : (t * t) = 
    let x1 = entangle<P>(qinit (), qinit ()) in
    let x2 = entangle<P>(qinit (), qinit ()) in
    let x3 = entangle<P>(qinit (), qinit ()) in
    let x4 = entangle<P>(qinit (), qinit ()) in
    let x5 = entangle<P>(qinit (), qinit ()) in
    let x6 = CNOT(entangle<P>(H (qinit ()), qinit ())) in
    let x7 = entangle<P>(qinit (), qinit ()) in
    let x8 = entangle<P>(qinit (), qinit ()) in
    split<P>(entangle<P>(entangle<P>(entangle<P>(x1, x2), entangle<P>(x3, x4)), entangle<P>(entangle<P>(x5, x6), entangle<P>(x7, x8))))
