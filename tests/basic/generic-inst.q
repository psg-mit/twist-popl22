fun f (x : qubit<'q>) : qubit<'q> = x
fun main () : qubit<P> =
    let x : qubit<P> = f (qinit ()) in
    let y : qubit<M> = f (cast<M>(qinit ())) in
    cast<P>(y)
