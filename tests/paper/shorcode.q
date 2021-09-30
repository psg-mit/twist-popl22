(* A program for encoding a single qubit in the nine-qubit Shor code. The
 * bit-flip and phase-flip encoding functions are generic over purity,
 * demonstrating how pure-to-pure functions can be built by composing functions
 * acting on intermediate mixed states. *)

type triple_p = (qubit & (qubit & qubit))<P>

type triple_m = (qubit & (qubit & qubit))<M>


(* Pure and mixed types for the nine codeword bits of the Shor code *)

type nonuple_p = ((qubit & (qubit & qubit)) &
                 ((qubit & (qubit & qubit)) &
                  (qubit & (qubit & qubit))))<P>

type nonuple_m = ((qubit & (qubit & qubit)) &
                 ((qubit & (qubit & qubit)) &
                  (qubit & (qubit & qubit))))<M>


(* Encoding functions *)

(* Encode a qubit with the three-qubit bit-flip code *)
fun enc_bit (q : qubit<'p>) : (qubit & (qubit & qubit))<'p> =
    let (a1 : qubit<M>) = qinit () in
    let (a2 : qubit<M>) = qinit () in
    let (q : qubit<M>, a2 : qubit<M>) = (CNOT (q, a2)) in
    let (q : qubit<M>, a1 : qubit<M>) = (CNOT (q, a1)) in 
    let (out : (qubit & (qubit & qubit))<M>) = (q, (a1, a2)) in
    cast<'p>(out)

(* Encode a qubit with the three-qubit phase-flip code *)
fun enc_phase (q : qubit<'p>) : (qubit & (qubit & qubit))<'p> =
    let (x : qubit<M>, (y : qubit<M>, z : qubit<M>)) = (enc_bit (q)) in
    let (out : (qubit & (qubit & qubit))<M>) = (H x, (H y, H z)) in
    cast<'p>(out)

(* Encode a qubit with the nine-qubit Shor code by concatenating the bit- and
 * phase-flip codes *)
fun enc_shor (q : qubit<P>) : nonuple_p =
    let (x : qubit<M>, (y : qubit<M>, z : qubit<M>)) = (enc_phase (cast<M>q)) in
    let (out : nonuple_m) = (enc_bit (x), (enc_bit (y), enc_bit (z))) in
    cast<P>(out)


(* Decoding functions *)

(* Decode the three-qubit bit-flip code *)
fun dec_bit (enc : (qubit & (qubit & qubit))<'p>) : (qubit & (qubit & qubit))<'p> =
    let (q0 : qubit<M>, tail : (qubit & qubit)<M>) = enc in
    let (q1 : qubit<M>, q2 : qubit<M>) = tail in
    let (q0 : qubit<M>, q1 : qubit<M>) = (CNOT (q0, q1)) in
    let (q0 : qubit<M>, q2 : qubit<M>) = (CNOT (q0, q2)) in
    let (q2 : qubit<M>, (q1 : qubit<M>, q0 : qubit<M>)) = TOF (q2, (q1, q0)) in
    let env : (qubit & qubit)<M> = entangle<M>(q1, q2) in
    let out : (qubit & (qubit & qubit))<M> = entangle<M>(q0, env) in
    cast<'p>out

(* Decode the three-qubit phase-flip code *)
fun dec_phase (enc : (qubit & (qubit & qubit))<'p>) : (qubit & (qubit & qubit))<'p> =
    let (x : qubit<M>, (y : qubit<M>, z : qubit<M>)) = enc in
    let qs : (qubit & (qubit & qubit))<M> = (H x, (H y, H z)) in
    let out : (qubit & (qubit & qubit))<'p> = dec_bit (cast<'p>qs) in
    out

(* Decode the Shor code, without discarding the extra bits *)
fun dec_shor (enc : nonuple_p) : nonuple_p =
    let (x : triple_m, (y : triple_m, z : triple_m)) = enc in
    let (x : triple_m, (y : triple_m, z : triple_m)) =
        (dec_bit (x), (dec_bit (y), dec_bit(z))) in

    let (x0 : qubit<M>, (x1 : qubit<M>, x2 : qubit<M>)) = x in
    let (y0 : qubit<M>, (y1 : qubit<M>, y2 : qubit<M>)) = y in
    let (z0 : qubit<M>, (z1 : qubit<M>, z2 : qubit<M>)) = z in
    let heads : triple_m = (x0, (y0, z0)) in
    let (x0 : qubit<M>, (y0 : qubit<M>, z0 : qubit<M>)) =
        dec_phase (heads) in

    let x = (x0, (x1, x2)) in
    let y = (y0, (y1, y2)) in
    let z = (z0, (z1, z2)) in
    let dec : nonuple_m = (x, (y, z)) in
    cast<P>dec

fun test_bitflip (q : qubit<P>) : qubit<P> =
    let (q0 : qubit<M>, tail : (qubit & qubit)<M>) = enc_bit (q) in
    let (q1 : qubit<M>, q2 : qubit<M>) = tail in
    let qs : (qubit & (qubit & qubit))<M> = (q0, (q1, q2)) in
    let (q : qubit<P>, env : (qubit & qubit)<P>) = dec_bit (cast<P>qs) in
    q

(* Accept a qubit and a noise operation. Encode the qubit, apply the given noise
 * operation on the physical qubits, then decode and discard the extra bits. *)
fun shor_ecc (qop : (qubit<P> * (nonuple_p -> nonuple_p))) : qubit<P> =
    (* Encode the qubit *)
    let (q : qubit<P>, op : nonuple_p -> nonuple_p) = qop in
    let enc = enc_shor (q) in

    (* Disturb the encoded state with the noise operation *)
    let enc = op (enc) in

    (* Decode and discard the parity bits *)
    let dec = dec_shor (enc) in
    let (x : triple_p, (y : triple_p, z : triple_p)) = dec in
    let (dec : qubit<P>, others : (qubit & qubit)<P>) = x in
    dec


(* Noise gates *)

(* A unitary channel that does nothing *)
fun id_channel (enc : nonuple_p) : nonuple_p =
    enc

(* A unitary channel that produces a single bit error *)
fun bitflip_channel (enc : nonuple_p) : nonuple_p =
    let (x : triple_m, (y : triple_m, z : triple_m)) = enc in
    let (x0 : qubit<M>, x_tail : (qubit & qubit)<M>) = x in
    let x0 = X x0 in
    let x : triple_m = entangle<M>(x0, x_tail) in
    let enc : nonuple_p = entangle<M>(x, entangle<M>(y, z)) in
    cast<P>enc

(* A unitary channel that produces a single phase flip *)
fun phaseflip_channel (enc : nonuple_p) : nonuple_p =
    let (x : triple_m, (y : triple_m, z : triple_m)) = enc in
    let (x0 : qubit<M>, x_tail : (qubit & qubit)<M>) = x in
    let x0 = Z x0 in
    let x : triple_m = entangle<M>(x0, x_tail) in
    let enc : nonuple_p = entangle<M>(x, entangle<M>(y, z)) in
    cast<P>enc

(* A unitary channel that produces two errors, and cannot be decoded *)
fun two_error_channel (enc : nonuple_p) : nonuple_p =
    let (x : triple_m, (y : triple_m, z : triple_m)) = enc in
    let (x0 : qubit<M>, (x1 : qubit<M>, x2 : qubit<M>)) = x in
    let x1 = X x1 in
    let x2 = X x2 in
    let x : triple_m = entangle<M>(x0, entangle<M>(x1, x2)) in
    let enc : nonuple_p = entangle<M>(x, entangle<M>(y, z)) in
    cast<P>enc


(* Test noise gates by replacing the second argument with your favorite
 * nine-qubit unitary function. *)
fun main () : qubit<P> =
    let state = shor_ecc ((H (qinit ()), phaseflip_channel)) in
    state
