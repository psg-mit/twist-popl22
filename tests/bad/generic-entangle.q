fun main () : (qubit & qubit)<'a> =
    entangle<'a>(qinit (), qinit ())
