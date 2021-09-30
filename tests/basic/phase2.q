fun main () : (qubit & qubit)<P> =
    let (q1 : qubit<P>, q2 : qubit<P>) = (H (qinit ()), H (qinit())) in
    (CPHASE 3.1415926 (q1, q2))
