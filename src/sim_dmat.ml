open Core
module Gate = Qpp.Gate
module Qpp = Qpp.Stub_dmat

type state = Qpp.state
type qubit = int

let separability_time = ref 0.
let empty = Qpp.empty
let discard = Qpp.discard

let with_state f =
  let s = empty () in
  separability_time := 0.;
  try
    f s;
    discard s;
    !separability_time
  with
  | e ->
    discard s;
    raise e
;;

let qinit = Qpp.qinit

let unitary1 s u q =
  match u with
  | Gate.PHASE p -> Qpp.punitary1 s u q p
  | _ -> Qpp.unitary1 s u q
;;

let unitary2 s u (q1, q2) =
  match u with
  | Gate.CPHASE p -> Qpp.punitary2 s u q1 q2 p
  | _ -> Qpp.unitary2 s u q1 q2
;;

let unitary3 s u (q1, q2, q3) = Qpp.unitary3 s u q1 q2 q3

let measure s q true_case false_case get_qubits =
  let s2 = Qpp.clone s in
  Qpp.measure s q true;
  Qpp.measure s2 q false;
  let v1 = true_case s in
  let v2 = false_case s2 in
  let q1 = get_qubits v1 in
  let q2 = get_qubits v2 in
  let open Ctypes in
  let a1 = CArray.of_list int q1 in
  let a2 = CArray.of_list int q2 in
  Qpp.sum s s2 (CArray.start a1) (CArray.start a2) (CArray.length a1);
  v1
;;

let separable s qs =
  if !Args.no_sep
  then true
  else (
    let s0 = Unix.gettimeofday () in
    let open Ctypes in
    let array = CArray.of_list int qs in
    let res = Qpp.separable s (CArray.start array) (CArray.length array) in
    let s1 = Unix.gettimeofday () in
    separability_time := !separability_time +. (s1 -. s0);
    res)
;;

let print = Qpp.print
