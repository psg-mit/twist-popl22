(* controlled multiply by 7 mod 15, using negation followed by three controlled swaps *)
fun mult7 (cqs : (qubit & (((qubit & qubit) & qubit) & qubit))<P>) : (qubit & (((qubit & qubit) & qubit) & qubit))<P> =
    let (c : qubit<M>, qs : (((qubit & qubit) & qubit) & qubit)<M>) = cqs in
    let (((q1 : qubit<M>, q2 : qubit<M>), q3 : qubit<M>), q4 : qubit<M>) = qs in
    let (c : qubit<M>, q1 : qubit<M>) = CNOT (c, q1) in
    let (c : qubit<M>, q2 : qubit<M>) = CNOT (c, q2) in
    let (c : qubit<M>, q3 : qubit<M>) = CNOT (c, q3) in
    let (c : qubit<M>, q4 : qubit<M>) = CNOT (c, q4) in
    let (c : qubit<M>, (q2 : qubit<M>, q3 : qubit<M>)) = FRED (c, (q2, q3)) in
    let (c : qubit<M>, (q1 : qubit<M>, q2 : qubit<M>)) = FRED (c, (q1, q2)) in
    let (c : qubit<M>, (q1 : qubit<M>, q4 : qubit<M>)) = FRED (c, (q1, q4)) in
    let res : (qubit & (((qubit & qubit) & qubit) & qubit))<P> = (c, (((q1, q2), q3), q4)) in
    res

(* controlled multiply by 13 mod 15 *)
fun mult13 (cqs : (qubit & (((qubit & qubit) & qubit) & qubit))<P>) : (qubit & (((qubit & qubit) & qubit) & qubit))<P> =
    let (c : qubit<M>, qs : (((qubit & qubit) & qubit) & qubit)<M>) = cqs in
    let (((q1 : qubit<M>, q2 : qubit<M>), q3 : qubit<M>), q4 : qubit<M>) = qs in
    let (c : qubit<M>, q1 : qubit<M>) = CNOT (c, q1) in
    let (c : qubit<M>, q2 : qubit<M>) = CNOT (c, q2) in
    let (c : qubit<M>, q3 : qubit<M>) = CNOT (c, q3) in
    let (c : qubit<M>, q4 : qubit<M>) = CNOT (c, q4) in
    let (c : qubit<M>, (q1 : qubit<M>, q4 : qubit<M>)) = FRED (c, (q1, q4)) in
    let (c : qubit<M>, (q1 : qubit<M>, q3 : qubit<M>)) = FRED (c, (q1, q3)) in (* THIS IS WRONG *)
    let (c : qubit<M>, (q2 : qubit<M>, q3 : qubit<M>)) = FRED (c, (q2, q3)) in
    let res : (qubit & (((qubit & qubit) & qubit) & qubit))<P> = (c, (((q1, q2), q3), q4)) in
    res

fun z () : qubit<P> = qinit ()

fun o () : qubit<P> = H (qinit ())

fun g () : (((qubit & qubit) & qubit) & qubit)<P> =
  let c = o () in
  let num : (((qubit & qubit) & qubit) & qubit)<P> = ((((o ()), z ()), z ()), o ()) in
  (* 0b0011 = 3 = 9 * 7 mod 15 *)
  let (c : qubit<P>, rest : (((qubit & qubit) & qubit) & qubit)<P>) = mult7 (entangle<P>(c, num)) in
  rest

fun main () : (qubit<P> * (((qubit & qubit) & qubit) & qubit)<P>) =
  let c = o () in
  (* 0b1001 = 9 *)
  let num : (((qubit & qubit) & qubit) & qubit)<P> = ((((o ()), z ()), z ()), o ()) in
  let (c : qubit<P>, rest : (((qubit & qubit) & qubit) & qubit)<P>) = mult13 (mult7 (entangle<P>(c, num))) in
  (* restored to 0b1001 *)
  (c, rest)
