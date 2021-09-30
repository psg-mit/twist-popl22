type t = (qubit & qubit)<P>

fun main () : (((t * t) * (t * t)) * ((t * qubit<P>) * qubit<P>)) = 
    let x1 = entangle<P>(qinit (), qinit ()) in
    let x2 = entangle<P>(qinit (), qinit ()) in
    let x3 = entangle<P>(qinit (), qinit ()) in
    let x6 = CNOT(entangle<P>(qinit (), qinit ())) in
    let x4 = entangle<P>(qinit (), qinit ()) in
    let x5 = entangle<P>(qinit (), qinit ()) in
    let (x9 : qubit<P>, x10 : qubit<P>) = x6 in
    (((x1, x2), (x3, x4)), ((x5, x9), x10))
