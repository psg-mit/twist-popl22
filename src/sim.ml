open Core
module Gate = Qpp.Gate
module Qpp = Qpp.Stub

type state = Qpp.state * (int, int) Hashtbl.t
type qubit = int

let separability_time = ref 0.
let empty () = Qpp.empty (), Hashtbl.create (module Int)
let discard (s, _) = Qpp.discard s

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

let qinit (s, m) =
  let key = Qpp.qinit s in
  Hashtbl.add_exn m ~key ~data:key;
  key
;;

let unitary1 (s, m) u q =
  match u with
  | Gate.PHASE p -> Qpp.punitary1 s u (Hashtbl.find_exn m q) p
  | _ -> Qpp.unitary1 s u (Hashtbl.find_exn m q)
;;

let unitary2 (s, m) u (q1, q2) =
  match u with
  | Gate.CPHASE p -> Qpp.punitary2 s u (Hashtbl.find_exn m q1) (Hashtbl.find_exn m q2) p
  | _ -> Qpp.unitary2 s u (Hashtbl.find_exn m q1) (Hashtbl.find_exn m q2)
;;

let unitary3 (s, m) u (q1, q2, q3) =
  Qpp.unitary3 s u (Hashtbl.find_exn m q1) (Hashtbl.find_exn m q2) (Hashtbl.find_exn m q3)
;;

let measure (s, m) q =
  let i = Hashtbl.find_exn m q in
  let s = Qpp.measure s i in
  Hashtbl.remove m q;
  Hashtbl.map_inplace m ~f:(fun j -> if j > i then j - 1 else j);
  s
;;

let separable (s, m) _qs1 qs2 =
  if !Args.no_sep
  then true
  else (
    let s0 = Unix.gettimeofday () in
    let open Ctypes in
    let array = CArray.of_list int (List.map ~f:(Hashtbl.find_exn m) qs2) in
    let res = Qpp.separable s (CArray.start array) (CArray.length array) in
    let s1 = Unix.gettimeofday () in
    separability_time := !separability_time +. (s1 -. s0);
    res)
;;

let print (s, _) = Qpp.print s
