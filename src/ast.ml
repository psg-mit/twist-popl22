type name = string [@@deriving show, eq]

type purity =
  | Ppure
  | Pmixed
  | Pvar of name
[@@deriving show, eq]

type qtyp =
  | Tqubit
  | Tepair of qtyp * qtyp
[@@deriving show, eq]

type 'purity typ =
  | Tquantum of 'purity * qtyp
  | Tbool
  | Tpair of 'purity typ * 'purity typ
  | Tunit
  | Tfun of 'purity typ * 'purity typ
[@@deriving show, eq]

type patt =
  | Pid of name * purity typ
  | Pinfer of name
  | Ppair of patt * patt
  | Punit
[@@deriving show]

type quantum =
  | Qref of int
  | Qepair of quantum * quantum
[@@deriving show]

type exp =
  | Evar of name
  | Elam of patt * exp
  | Eapp of exp * exp
  | Epair of exp * exp
  | Eunit
  | Elet of patt * exp * exp
  | Eqinit
  | Eunitary of Qpp.Gate.t * exp
  | Eentangle of purity * exp
  | Esplit of purity * exp
  | Ecast of purity * exp
  | Equantum of purity * quantum
  | Ebool of bool
  | Eif of exp * exp * exp
  | Emeasure of exp
[@@deriving show]

type decl = name * purity typ * exp [@@deriving show]
type program = decl list * exp [@@deriving show]
