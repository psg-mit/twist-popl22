open Core
open Ast

exception TypeError of string

module VarMap = String.Map

let inst t1 t2 t' lift =
  let rec get_map m = function
    | Tbool, Tbool | Tunit, Tunit -> m
    | Tquantum ((Ppure | Pmixed), q1), Tquantum (_, q2) when equal_qtyp q1 q2 -> m
    | Tpair (t1, t2), Tpair (t1', t2') | Tfun (t1, t2), Tfun (t1', t2') ->
      get_map (get_map m (t1, t1')) (t2, t2')
    | Tquantum (Pvar key, q1), Tquantum (data, q2) when equal_qtyp q1 q2 ->
      (match VarMap.add m ~key ~data with
      | `Ok a -> a
      | `Duplicate -> raise (TypeError ("Duplicate generic purity parameter " ^ key)))
    | _, _ ->
      raise
        (TypeError
           (Format.asprintf
              "Cannot instantiate type %a with argument %a"
              (pp_typ pp_purity)
              t1
              (pp_typ (fun _ _ -> ()))
              t'))
  in
  let map = get_map VarMap.empty (t1, t') in
  let rec apply_map m = function
    | Tquantum (Pvar x, q) ->
      (match VarMap.find m x with
      | None -> raise (TypeError ("Unbound generic purity parameter " ^ x))
      | Some p -> Tquantum (p, q))
    | Tquantum (p, q) -> Tquantum (lift p, q)
    | Tpair (t1, t2) -> Tpair (apply_map m t1, apply_map m t2)
    | Tfun (t1, t2) -> Tfun (apply_map m t1, apply_map m t2)
    | Tbool -> Tbool
    | Tunit -> Tunit
  in
  apply_map map t2
;;
