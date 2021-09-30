type sixteen_m = (((((((((((((((qubit & qubit) & qubit) & qubit) & qubit) & qubit) & qubit) & qubit) & qubit) & qubit) & qubit) & qubit) & qubit) & qubit) & qubit) & qubit)<M>
type sixteen_p = (((((((((((((((qubit & qubit) & qubit) & qubit) & qubit) & qubit) & qubit) & qubit) & qubit) & qubit) & qubit) & qubit) & qubit) & qubit) & qubit) & qubit)<P>

type all = (qubit & (((((((((((((((qubit & qubit) & qubit) & qubit) & qubit) & qubit) & qubit) & qubit) & qubit) & qubit) & qubit) & qubit) & qubit) & qubit) & qubit) & qubit))<P>

type qp = qubit<P>
type qm = qubit<M>

fun mult32767 (cqs : all) : all =
    let (c : qm, qs : sixteen_m) = cqs in
    let (((((((((((((((q1 : qm, q2 : qm), q3 : qm), q4 : qm), q5 : qm), q6 : qm), q7 : qm), q8 : qm), q9 : qm), q10 : qm), q11 : qm), q12 : qm), q13 : qm), q14 : qm), q15 : qm), q16 : qm) = qs in
    let (c : qm, q1 : qm) = CNOT (c, q1) in
    let (c : qm, q2 : qm) = CNOT (c, q2) in
    let (c : qm, q3 : qm) = CNOT (c, q3) in
    let (c : qm, q4 : qm) = CNOT (c, q4) in
    let (c : qm, q5 : qm) = CNOT (c, q5) in
    let (c : qm, q6 : qm) = CNOT (c, q6) in
    let (c : qm, q7 : qm) = CNOT (c, q7) in
    let (c : qm, q8 : qm) = CNOT (c, q8) in
    let (c : qm, q9 : qm) = CNOT (c, q9) in
    let (c : qm, q10 : qm) = CNOT (c, q10) in
    let (c : qm, q11 : qm) = CNOT (c, q11) in
    let (c : qm, q12 : qm) = CNOT (c, q12) in
    let (c : qm, q13 : qm) = CNOT (c, q13) in
    let (c : qm, q14 : qm) = CNOT (c, q14) in
    let (c : qm, q15 : qm) = CNOT (c, q15) in
    let (c : qm, q16 : qm) = CNOT (c, q16) in
    let (c : qm, (q14 : qm, q15 : qm)) = FRED (c, (q14, q15)) in
    let (c : qm, (q13 : qm, q14 : qm)) = FRED (c, (q13, q14)) in
    let (c : qm, (q12 : qm, q13 : qm)) = FRED (c, (q12, q13)) in
    let (c : qm, (q11 : qm, q12 : qm)) = FRED (c, (q11, q12)) in
    let (c : qm, (q10 : qm, q11 : qm)) = FRED (c, (q10, q11)) in
    let (c : qm, (q9 : qm, q10 : qm)) = FRED (c, (q9, q10)) in
    let (c : qm, (q8 : qm, q9 : qm)) = FRED (c, (q8, q9)) in
    let (c : qm, (q7 : qm, q8 : qm)) = FRED (c, (q7, q8)) in
    let (c : qm, (q6 : qm, q7 : qm)) = FRED (c, (q6, q7)) in
    let (c : qm, (q5 : qm, q6 : qm)) = FRED (c, (q5, q6)) in
    let (c : qm, (q4 : qm, q5 : qm)) = FRED (c, (q4, q5)) in
    let (c : qm, (q3 : qm, q4 : qm)) = FRED (c, (q3, q4)) in
    let (c : qm, (q2 : qm, q3 : qm)) = FRED (c, (q2, q3)) in
    let (c : qm, (q1 : qm, q2 : qm)) = FRED (c, (q1, q2)) in
    let (c : qm, (q1 : qm, q16 : qm)) = FRED (c, (q1, q16)) in
    let res : all = (c, (((((((((((((((q1, q2), q3), q4), q5), q6), q7), q8), q9), q10), q11), q12), q13), q14), q15), q16)) in
    res

fun mult6923 (cqs : all) : all =
    let (c : qm, qs : sixteen_m) = cqs in
    let (((((((((((((((q1 : qm, q2 : qm), q3 : qm), q4 : qm), q5 : qm), q6 : qm), q7 : qm), q8 : qm), q9 : qm), q10 : qm), q11 : qm), q12 : qm), q13 : qm), q14 : qm), q15 : qm), q16 : qm) = qs in
    let (c : qm, q1 : qm) = CNOT (c, q1) in
    let (c : qm, q2 : qm) = CNOT (c, q2) in
    let (c : qm, q3 : qm) = CNOT (c, q3) in
    let (c : qm, q4 : qm) = CNOT (c, q4) in
    let (c : qm, q5 : qm) = CNOT (c, q5) in
    let (c : qm, q6 : qm) = CNOT (c, q6) in
    let (c : qm, q7 : qm) = CNOT (c, q7) in
    let (c : qm, q8 : qm) = CNOT (c, q8) in
    let (c : qm, q9 : qm) = CNOT (c, q9) in
    let (c : qm, q10 : qm) = CNOT (c, q10) in
    let (c : qm, q11 : qm) = CNOT (c, q11) in
    let (c : qm, q12 : qm) = CNOT (c, q12) in
    let (c : qm, q13 : qm) = CNOT (c, q13) in
    let (c : qm, q14 : qm) = CNOT (c, q14) in
    let (c : qm, q15 : qm) = CNOT (c, q15) in
    let (c : qm, q16 : qm) = CNOT (c, q16) in
    let (c : qm, (q1 : qm, q16 : qm)) = FRED (c, (q1, q16)) in
    let (c : qm, (q1 : qm, q2 : qm)) = FRED (c, (q1, q2)) in
    let (c : qm, (q2 : qm, q3 : qm)) = FRED (c, (q2, q3)) in
    let (c : qm, (q3 : qm, q4 : qm)) = FRED (c, (q3, q4)) in
    let (c : qm, (q4 : qm, q5 : qm)) = FRED (c, (q4, q5)) in
    let (c : qm, (q5 : qm, q6 : qm)) = FRED (c, (q5, q6)) in
    let (c : qm, (q6 : qm, q7 : qm)) = FRED (c, (q6, q7)) in
    let (c : qm, (q7 : qm, q8 : qm)) = FRED (c, (q7, q8)) in
    let (c : qm, (q8 : qm, q9 : qm)) = FRED (c, (q8, q9)) in
    let (c : qm, (q9 : qm, q10 : qm)) = FRED (c, (q9, q10)) in
    let (c : qm, (q10 : qm, q11 : qm)) = FRED (c, (q10, q11)) in
    let (c : qm, (q11 : qm, q12 : qm)) = FRED (c, (q11, q12)) in
    let (c : qm, (q12 : qm, q13 : qm)) = FRED (c, (q12, q13)) in
    let (c : qm, (q13 : qm, q14 : qm)) = FRED (c, (q13, q14)) in
    let (c : qm, (q14 : qm, q15 : qm)) = FRED (c, (q14, q15)) in
    let res : all = (c, (((((((((((((((q1, q2), q3), q4), q5), q6), q7), q8), q9), q10), q11), q12), q13), q14), q15), q16)) in
    res

fun z () : qp = qinit ()

fun o () : qp = H (qinit ())

fun main () : (qp * sixteen_p) =
  let c = o () in
  let num : sixteen_p = ((((((((((((((((o ()), z ()), z ()), o ()), o ()), z ()), z ()), o ()), z ()), z ()), z ()), z ()), o ()), o ()), z ()), o ()) in
  let (c : qp, rest : sixteen_p) = mult6923 (mult32767 (entangle<P>(c, num))) in
  (c, rest)
