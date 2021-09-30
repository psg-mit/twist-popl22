fun main () : (bool * qubit<P>) = 
    let q1 = H (qinit ()) in
    let q2 = Y (H (qinit ())) in
    (measure (q1), q2)
