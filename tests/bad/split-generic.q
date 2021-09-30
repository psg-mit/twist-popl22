fun main () : (qubit<'a> * qubit<'a>) =
    split<'a>(entangle<P>(qinit (), qinit ()))
