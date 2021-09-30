type five = (qubit & (((qubit & qubit) & qubit) & qubit))<P>
type four_m = (((qubit & qubit) & qubit) & qubit)<M>
type four_p = (((qubit & qubit) & qubit) & qubit)<P>
type qp = qubit<P>
type qm = qubit<M>

(* controlled multiply by 7 mod 15, using negation followed by three controlled swaps *)
fun mult7 (cqs : five) : five =
    let (c : qm, qs : four_m) = cqs in
    let (((q1 : qm, q2 : qm), q3 : qm), q4 : qm) = qs in
    let (c : qm, q1 : qm) = CNOT (c, q1) in
    let (c : qm, q2 : qm) = CNOT (c, q2) in
    let (c : qm, q3 : qm) = CNOT (c, q3) in
    let (c : qm, q4 : qm) = CNOT (c, q4) in
    let (c : qm, (q2 : qm, q3 : qm)) = FRED (c, (q2, q3)) in
    let (c : qm, (q1 : qm, q2 : qm)) = FRED (c, (q1, q2)) in
    let (c : qm, (q1 : qm, q4 : qm)) = FRED (c, (q1, q4)) in
    let res : five = (c, (((q1, q2), q3), q4)) in
    res

(* controlled multiply by 13 mod 15 *)
fun mult13 (cqs : five) : five =
    let (c : qm, qs : four_m) = cqs in
    let (((q1 : qm, q2 : qm), q3 : qm), q4 : qm) = qs in
    let (c : qm, q1 : qm) = CNOT (c, q1) in
    let (c : qm, q2 : qm) = CNOT (c, q2) in
    let (c : qm, q3 : qm) = CNOT (c, q3) in
    let (c : qm, q4 : qm) = CNOT (c, q4) in
    let (c : qm, (q1 : qm, q4 : qm)) = FRED (c, (q1, q4)) in
    let (c : qm, (q1 : qm, q2 : qm)) = FRED (c, (q1, q2)) in
    let (c : qm, (q2 : qm, q3 : qm)) = FRED (c, (q2, q3)) in
    let res : five = (c, (((q1, q2), q3), q4)) in
    res

fun z () : qp = qinit ()

fun o () : qp = H (qinit ())

fun g () : four_p =
  let c = o () in
  let num : four_p = ((((o ()), z ()), z ()), o ()) in
  (* 0b0011 = 3 = 9 * 7 mod 15 *)
  let (c : qp, rest : four_p) = mult7 (entangle<P>(c, num)) in
  rest

fun main () : (qp * four_p) =
  let c = o () in
  (* 0b1001 = 9 *)
  let num : four_p = ((((o ()), z ()), z ()), o ()) in
  let (c : qp, rest : four_p) = mult13 (mult7 (entangle<P>(c, num))) in
  (* restored to 0b1001 *)
  (c, rest)
