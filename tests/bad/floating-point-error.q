(* This counterexample demonstrates a limitation of the present system:
 * due to the use of finite-precision floating point circuit simulation, some
 * correct programs will fail to pass the dynamic check.
 *
 * It may even be possible, in principle, to construct very large programs
 * that should not pass, but in fact do. *)

fun cphase0 (qs : (qubit & qubit)<P>) : (qubit & qubit)<P> =
    CPHASE 1.0 (qs)


(* Let's use a branching factor of 2, to find something close to the
 * smallest-possible example *)

fun cphase1 (qs : (qubit & qubit)<P>) : (qubit & qubit)<P> =
    let qs = cphase0 (qs) in
    cphase0 (qs)

fun cphase2 (qs : (qubit & qubit)<P>) : (qubit & qubit)<P> =
    let qs = cphase1 (qs) in
    cphase1 (qs)

fun cphase3 (qs : (qubit & qubit)<P>) : (qubit & qubit)<P> =
    let qs = cphase2 (qs) in
    cphase2 (qs)

fun cphase4 (qs : (qubit & qubit)<P>) : (qubit & qubit)<P> =
    let qs = cphase3 (qs) in
    cphase3 (qs)

fun cphase5 (qs : (qubit & qubit)<P>) : (qubit & qubit)<P> =
    let qs = cphase4 (qs) in
    cphase4 (qs)

fun cphase6 (qs : (qubit & qubit)<P>) : (qubit & qubit)<P> =
    let qs = cphase5 (qs) in
    cphase5 (qs)

fun cphase7 (qs : (qubit & qubit)<P>) : (qubit & qubit)<P> =
    let qs = cphase6 (qs) in
    cphase6 (qs)

fun cphase8 (qs : (qubit & qubit)<P>) : (qubit & qubit)<P> =
    let qs = cphase7 (qs) in
    cphase7 (qs)


fun main () : (qubit<P> * qubit<P>) =
   let qs = entangle<P>(H qinit (), H qinit ()) in
   let qs = split<P>(cphase8 (qs)) in
   qs
