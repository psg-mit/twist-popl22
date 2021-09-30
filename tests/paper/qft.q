(* "Recursively"-defined quantum Fourier transform sub-blocks *)

fun qft_sub_1 (q : qubit<'p>) : qubit<'p> =
    (H q)

fun qft_sub_2 (qs : (qubit & qubit)<'p>) : (qubit & qubit)<'p> =
    let (q0 : qubit<M>, q1 : qubit<M>) = cast<M>qs in
    let q0 = qft_sub_1 (q0) in
    (* Controlled phase of 2 pi / 2 ** 2 *)
    let (qs : (qubit & qubit)<M>) = CPHASE 0.250 (q1, q0) in
    let (q1 : qubit<M>, q0 : qubit<M>) = qs in
    let (qs : (qubit & qubit)<M>) = (q0, q1) in
    cast<'p>qs

fun qft_sub_3 (qs : ((qubit & qubit) & qubit)<'p>) : ((qubit & qubit) & qubit)<'p> =
    let (qs : (qubit & qubit)<M>, q2 : qubit<M>) = qs in
    let qs = qft_sub_2 (qs) in
    let (q0 : qubit<M> , q1 : qubit<M>) = qs in
    (* Controlled phase of 2 pi / 2 ** 3 *)
    let (q2 : qubit<M>, q0 : qubit<M>) = CPHASE 0.125 (q2, q0) in
    let (qs : ((qubit & qubit) & qubit)<M>) = ((q0, q1), q2) in
    cast<'p>qs


(* Whole quantum Fourier transforms from sub-blocks *)

fun qft_1 (q : qubit<'p>) : qubit<'p> =
    qft_sub_1 (q)

fun qft_2 (qs : (qubit & qubit)<'p>) : (qubit & qubit)<'p> =
    let qs = qft_sub_2 (qs) in
    let (q0 : qubit<M>, q1 : qubit<M>) = qs in
    let q1 = qft_1 (q1) in
    let (qs: (qubit & qubit)<M>) = (q0, q1) in
    cast<'p>qs

fun qft_3 (qs : ((qubit & qubit) & qubit)<'p>) : ((qubit & qubit) & qubit)<'p> =
    let qs = qft_sub_3 (qs) in
    let ((q0 : qubit<M>, q1 : qubit<M>), q2 : qubit<M>) = qs in
    let tail : (qubit & qubit)<M> = (q1, q2) in
    let (q1 : qubit<M>, q2 : qubit<M>) = qft_2 (tail) in
    let (qs: ((qubit & qubit) & qubit)<M>) = ((q0, q1), q2) in
    cast<'p>qs

fun main () : ((qubit & qubit) & qubit)<P> =
    let qs = entangle<P>(entangle<P>(qinit(), X qinit()), qinit()) in
    let qs = qft_3 (qs) in
    qs
