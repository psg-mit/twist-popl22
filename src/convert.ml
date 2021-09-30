open Core
open Ast
module VarMap = String.Map
module VarSet = String.Set

exception NoConversion

let rec contains_mixed = function
  | Tquantum (Pmixed, _) -> true
  | Tquantum (Ppure, _) -> false
  | Tquantum (_, _) -> true
  | Tpair (t1, t2) -> contains_mixed t1 || contains_mixed t2
  | Tfun (_, _) | Tbool | Tunit -> assert false
;;

let rec contains_pure = function
  | Tquantum (Ppure, _) -> true
  | Tquantum (Pmixed, _) -> false
  | Tquantum (_, _) -> true
  | Tpair (t1, t2) -> contains_pure t1 || contains_pure t2
  | Tfun (_, _) | Tbool | Tunit -> assert false
;;

let next_id =
  let i = ref 0 in
  fun () ->
    let x = !i in
    i := x + 1;
    x
;;

let get_var () = "__" ^ Int.to_string (next_id ())

let rec convert_to_quantum (rhs : 'a typ) (e : exp) =
  if not !Args.convert
  then raise NoConversion
  else (
    match rhs with
    | Tquantum (_, _) -> e
    | Tpair (t1, t2) ->
      let x, y = get_var (), get_var () in
      let e1 = convert_to_quantum t1 (Evar x) in
      let e2 = convert_to_quantum t2 (Evar y) in
      let e' =
        if contains_mixed rhs
        then Eentangle (Pmixed, Epair (Ecast (Pmixed, e1), Ecast (Pmixed, e2)))
        else Eentangle (Ppure, Epair (e1, e2))
      in
      Elet (Ppair (Pid (x, t1), Pid (y, t2)), e, e')
    | _ -> raise NoConversion)
;;

let rec convert (lhs : 'a typ) (rhs : 'a typ) (e : exp) =
  if not !Args.convert
  then raise NoConversion
  else (
    match lhs, rhs with
    | _, _ when equal_typ equal_purity lhs rhs -> e
    | Tquantum (Pmixed, _), Tquantum (Ppure, _) -> Ecast (Pmixed, e)
    | Tquantum (Ppure, _), Tquantum (Pmixed, _) -> Ecast (Ppure, e)
    | Tpair (t1, t2), Tpair (t1', t2') ->
      let x, y = get_var (), get_var () in
      let e1 = convert t1 t1' (Evar x) in
      let e2 = convert t2 t2' (Evar y) in
      Elet (Ppair (Pid (x, t1'), Pid (y, t2')), e, Epair (e1, e2))
    | Tpair (t1, t2), Tquantum (p, Tepair (t1', t2')) when contains_pure (Tpair (t1, t2))
      ->
      let x, y = get_var (), get_var () in
      let t1', t2' = Tquantum (Ppure, t1'), Tquantum (Ppure, t2') in
      let e1 = convert t1 t1' (Evar x) in
      let e2 = convert t2 t2' (Evar y) in
      Elet
        ( Ppair (Pid (x, t1'), Pid (y, t2'))
        , Esplit
            ( Ppure
            , match p with
              | Ppure -> e
              | Pmixed -> Ecast (Ppure, e)
              | _ -> raise NoConversion )
        , Epair (e1, e2) )
    | Tpair (t1, t2), Tquantum (_, Tepair (t1', t2')) ->
      let x, y = get_var (), get_var () in
      let t1', t2' = Tquantum (Pmixed, t1'), Tquantum (Pmixed, t2') in
      let e1 = convert t1 t1' (Evar x) in
      let e2 = convert t2 t2' (Evar y) in
      Elet
        ( Ppair (Pid (x, t1'), Pid (y, t2'))
        , Esplit (Pmixed, Ecast (Pmixed, e))
        , Epair (e1, e2) )
    | Tquantum (Ppure, Tepair (t1, t2)), Tpair (t1', t2')
      when contains_mixed (Tpair (t1', t2')) ->
      let x, y = get_var (), get_var () in
      let t1, t2 = Tquantum (Pmixed, t1), Tquantum (Pmixed, t2) in
      let e1 = convert t1 t1' (Evar x) in
      let e2 = convert t2 t2' (Evar y) in
      Elet
        ( Ppair (Pid (x, t1), Pid (y, t2))
        , e
        , Ecast (Ppure, Eentangle (Pmixed, Epair (e1, e2))) )
    | Tquantum (Ppure, Tepair (t1, t2)), Tpair (t1', t2') ->
      let x, y = get_var (), get_var () in
      let t1, t2 = Tquantum (Ppure, t1), Tquantum (Ppure, t2) in
      let e1 = convert t1 t1' (Evar x) in
      let e2 = convert t2 t2' (Evar y) in
      Elet (Ppair (Pid (x, t1), Pid (y, t2)), e, Eentangle (Ppure, Epair (e1, e2)))
    | Tquantum (Pmixed, Tepair (t1, t2)), Tpair (t1', t2') ->
      let x, y = get_var (), get_var () in
      let t1, t2 = Tquantum (Pmixed, t1), Tquantum (Pmixed, t2) in
      let e1 = convert t1 t1' (Evar x) in
      let e2 = convert t2 t2' (Evar y) in
      Elet (Ppair (Pid (x, t1), Pid (y, t2)), e, Eentangle (Pmixed, Epair (e1, e2)))
    | _, _ -> raise NoConversion)
;;

let rec classical = function
  | Tqubit -> Tbool
  | Tepair (t1, t2) -> Tpair (classical t1, classical t2)
;;

let convert_consume unconsumed ctx e =
  if not !Args.convert
  then raise NoConversion
  else (
    let rec consume e x t =
      match t with
      | Tquantum (Ppure, t) ->
        let y = get_var () in
        Elet (Pid (y, classical t), Emeasure (Evar x), e)
      | Tquantum (_, _) | Tfun (_, _) -> raise NoConversion
      | Tbool | Tunit -> e
      | Tpair (t1, t2) ->
        let y, z = get_var (), get_var () in
        Elet (Ppair (Pid (y, t1), Pid (z, t2)), Evar x, consume (consume e y t1) z t2)
    in
    Set.fold ~init:e ~f:(fun e x -> consume e x (VarMap.find_exn ctx x)) unconsumed)
;;
