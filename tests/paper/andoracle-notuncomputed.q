fun and_oracle (p0 : qubit<P>, p1 : qubit<P>) : (qubit & qubit)<P> =
    let x = qinit () in
    let (p0 : qubit<M>, (p1 : qubit<M>, x : qubit<M>)) = TOF (p0, (p1, x)) in
    let p0 = Z (p0) in
    let _ = measure x in
    entangle<P>(p0, p1)

fun main () : unit = ()
