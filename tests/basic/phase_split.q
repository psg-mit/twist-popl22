fun main () : (qubit<P> * qubit<P>) =
    let (q1 : qubit<P>, q2 : qubit<P>) = (H (qinit ()), H (qinit())) in
    let (q1 : qubit<M>, q2 : qubit<M>) = CPHASE 1.0 (q1, q2) in
    let (qs : (qubit & qubit)<P>) = (q1, q2) in
    split<P>(qs)
