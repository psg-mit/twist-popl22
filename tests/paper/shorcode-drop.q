(* A program for encoding a single qubit in the nine-qubit Shor code. The
 * bit-flip and phase-flip encoding functions are generic over purity,
 * demonstrating how pure-to-pure functions can be built by composing functions
 * acting on intermediate mixed states. *)

type nonuple_p = ((((qubit & qubit) & qubit) &
                 ((qubit & qubit) & qubit)) &
                 ((qubit & qubit) & qubit))<P>

type nonuple_m = ((((qubit & qubit) & qubit) &
                 ((qubit & qubit) & qubit)) &
                 ((qubit & qubit) & qubit))<M>

(* Encode a qubit with the three-qubit bit-flip code *)
fun enc_bit (q : qubit<'p>) : ((qubit & qubit) & qubit)<'p> =
    let (a1 : qubit<M>) = qinit () in
    let (a2 : qubit<M>) = qinit () in
    let (q : qubit<M>) = qinit () in
    let (q : qubit<M>, a2 : qubit<M>) = (CNOT (q, a2)) in
    let (q : qubit<M>, a1 : qubit<M>) = (CNOT (q, a1)) in 
    let (out : ((qubit & qubit) & qubit)<M>) = ((q, a1), a2) in
    cast<'p>(out)

(* Encode a qubit with the three-qubit phase-flip code *)
fun enc_phase (q : qubit<'p>) : ((qubit & qubit) & qubit)<'p> =
    let ((x : qubit<M>, y : qubit<M>), z : qubit<M>) = (enc_bit (q)) in
    let (out : ((qubit & qubit) & qubit)<M>) = ((H x, H y), H z) in
    cast<'p>(out)

(* Encode a qubit with the nine-qubit Shor code by concatenating the bit- and
 * phase-flip codes *)
fun enc_shor (q : qubit<P>) : nonuple_p =
    let ((x : qubit<M>, y : qubit<M>), z : qubit<M>) = (enc_bit (cast<M>q)) in
    let (out : nonuple_m) = ((enc_phase (x), enc_phase (y)), enc_phase (z)) in
    cast<P>(out)

fun main () : nonuple_p =
    let state = (H (qinit ())) in
    enc_shor (state)
