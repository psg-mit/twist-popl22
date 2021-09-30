fun f (q : qubit<M>) : qubit<M> = q
fun g (q : qubit<P>) : qubit<P> = cast<P>(f (cast<M>(q)))

fun main () : unit = ()
