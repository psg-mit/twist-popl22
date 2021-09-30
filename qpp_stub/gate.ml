type t =
  | X
  | Y
  | Z
  | H
  | CNOT
  | CZ
  | TOF
  | FRED
  | PHASE of float
  | CPHASE of float
[@@deriving show, eq]
