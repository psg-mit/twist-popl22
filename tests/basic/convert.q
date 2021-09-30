fun main () : ((qubit<M> * qubit<M>) * (qubit<P> * (qubit & qubit)<P>)) =
    let q1 : qubit<M> = qinit () in
    let (q2 : qubit<M>, q3 : qubit<P>) = entangle<P>(qinit (), qinit ()) in
    let qs : (qubit & qubit)<P> = (cast<M>(qinit ()), cast<M>(qinit ())) in
    ((q1, q2), (q3, qs))
