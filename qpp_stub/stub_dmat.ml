open Ctypes
open Foreign

type state = unit ptr

let state : state typ = ptr void

let gate_of_int =
  let open Gate in
  function
  | 0 -> X
  | 1 -> Y
  | 2 -> Z
  | 3 -> H
  | 4 -> CNOT
  | 5 -> CZ
  | 6 -> TOF
  | 7 -> FRED
  | 8 -> PHASE 0.
  | 9 -> CPHASE 0.
  | _ -> raise (Invalid_argument "Unexpected gate enum")
;;

let int_of_gate =
  let open Gate in
  function
  | X -> 0
  | Y -> 1
  | Z -> 2
  | H -> 3
  | CNOT -> 4
  | CZ -> 5
  | TOF -> 6
  | FRED -> 7
  | PHASE _ -> 8
  | CPHASE _ -> 9
;;

let gate = view ~read:gate_of_int ~write:int_of_gate int
let empty = foreign "empty_dmat" (void @-> returning state)
let discard = foreign "discard_dmat" (state @-> returning void)
let qinit = foreign "qinit_dmat" (state @-> returning int)
let unitary1 = foreign "unitary1_dmat" (state @-> gate @-> int @-> returning void)
let unitary2 = foreign "unitary2_dmat" (state @-> gate @-> int @-> int @-> returning void)

let unitary3 =
  foreign "unitary3_dmat" (state @-> gate @-> int @-> int @-> int @-> returning void)
;;

let punitary1 = foreign "punitary1_dmat" (state @-> gate @-> int @-> double @-> returning void)

let punitary2 =
  foreign "punitary2_dmat" (state @-> gate @-> int @-> int @-> double @-> returning void)
;;

let measure = foreign "measure_dmat" (state @-> int @-> bool @-> returning void)
let clone = foreign "clone_dmat" (state @-> returning state)
let sum = foreign "sum_dmat" (state @-> state @-> ptr int @-> ptr int @-> int @-> returning void)
let separable = foreign "separable_dmat" (state @-> ptr int @-> int @-> returning bool)
let print = foreign "print_dmat" (state @-> returning void)
