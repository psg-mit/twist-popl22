open Core
open Ast

exception Error of string

module VarMap = String.Map

module Purity : sig
  type purity

  val pure : purity
  val mixed : purity
  val equal : purity -> purity -> bool
  val is_pure : purity -> bool
  val lift : Ast.purity -> purity
  val split : purity -> purity
  val combine : purity -> purity -> purity
end = struct
  type purity =
    | Poly of Q.t Int.Map.t
    | Mixed

  let pure = Poly Int.Map.empty
  let mixed = Mixed

  let equal p1 p2 =
    match p1, p2 with
    | Mixed, Mixed -> true
    | Poly p1, Poly p2 -> Int.Map.equal Q.equal p1 p2
    | _, _ -> false
  ;;

  let is_pure = function
    | Mixed -> false
    | Poly f -> Int.Map.is_empty f
  ;;

  let next_id =
    let i = ref 0 in
    fun () ->
      let x = !i in
      i := x + 1;
      x
  ;;

  let vars = Hashtbl.create (module String)

  let lift = function
    | Ppure -> pure
    | Pmixed -> mixed
    | Pvar x ->
      let x = Hashtbl.find_or_add vars x ~default:next_id in
      Poly (Int.Map.singleton x (Q.div Q.one (Q.of_int 2)))
  ;;

  let split = function
    | Mixed -> Mixed
    | Poly f ->
      Poly
        (Int.Map.map
           (Int.Map.add_exn f ~key:(next_id ()) ~data:Q.one)
           ~f:(fun x -> Q.div x (Q.of_int 2)))
  ;;

  let combine f g =
    match f, g with
    | Mixed, _ | _, Mixed -> Mixed
    | Poly f, Poly g ->
      Poly
        (Int.Map.merge f g ~f:(fun ~key:_ -> function
           | `Left x | `Right x -> Some x
           | `Both (x, y) ->
             let z = Q.add x y in
             if Q.equal z Q.zero || Q.equal z Q.one then None else Some z))
  ;;
end

let rec classical = function
  | Tqubit -> Tbool
  | Tepair (t1, t2) -> Tpair (classical t1, classical t2)
;;

let rec mix = function
  | Tquantum (_, q) -> Tquantum (Purity.mixed, q)
  | Tpair (t1, t2) -> Tpair (mix t1, mix t2)
  | Tfun (t1, t2) -> Tfun (t1, mix t2)
  | t -> t
;;

let rec lift_t = function
  | Tquantum (p, t) -> Tquantum (Purity.lift p, t)
  | Tpair (t1, t2) -> Tpair (lift_t t1, lift_t t2)
  | Tfun (t1, t2) -> Tfun (lift_t t1, lift_t t2)
  | Tbool -> Tbool
  | Tunit -> Tunit
;;

let rec synth_p = function
  | Pid (_, t) -> lift_t t
  | Ppair (p1, p2) -> Tpair (synth_p p1, synth_p p2)
  | Punit -> Tunit
  | Pinfer _ -> assert false
;;

let rec synth decls ctx = function
  | Evar x ->
    (match VarMap.find ctx x with
    | Some t -> t
    | None -> lift_t (VarMap.find_exn decls x))
  | Eapp (Evar x, e2) when VarMap.mem decls x ->
    let t1, t2 =
      match VarMap.find_exn decls x with
      | Tfun (t1, t2) -> t1, t2
      | _ -> assert false
    in
    let t' = synth decls ctx e2 in
    let t, _ = Inst.inst t1 t2 t' Purity.lift in
    t
  | Eapp (e1, e2) ->
    let t1 = synth decls ctx e1 in
    let (_ : Purity.purity typ) = synth decls ctx e2 in
    (match t1 with
    | Tfun (_, t2') -> t2'
    | _ -> assert false)
  | Epair (e1, e2) -> Tpair (synth decls ctx e1, synth decls ctx e2)
  | Eunit -> Tunit
  | Elam (p, e) ->
    let rec update_ctx ctx = function
      | Pid (key, t) -> VarMap.add_exn (VarMap.remove ctx key) ~key ~data:(lift_t t)
      | Ppair (t1, t2) -> update_ctx (update_ctx ctx t1) t2
      | Punit -> ctx
      | Pinfer _ -> assert false
    in
    let ctx' = update_ctx ctx p in
    Tfun (synth_p p, synth decls ctx' e)
  | Elet (p, e1, e2) ->
    let rec update_ctx ctx = function
      | (Pid (key, _) | Pinfer key), data ->
        VarMap.add_exn (VarMap.remove ctx key) ~key ~data
      | Ppair (p1, p2), Tpair (t1, t2) -> update_ctx (update_ctx ctx (p1, t1)) (p2, t2)
      | Punit, Tunit -> ctx
      | _, _ -> assert false
    in
    let ctx' = update_ctx ctx (p, synth decls ctx e1) in
    synth decls ctx' e2
  | Eqinit -> Tquantum (Purity.pure, Tqubit)
  | Eunitary (_, e) -> synth decls ctx e
  | Eentangle (_, e) ->
    (match synth decls ctx e with
    | Tpair (Tquantum (f, t1), Tquantum (g, t2)) ->
      Tquantum (Purity.combine f g, Tepair (t1, t2))
    | _ -> assert false)
  | Esplit (Pmixed, e) ->
    (match synth decls ctx e with
    | Tquantum (f, Tepair (t1, t2)) ->
      let g = Purity.split f in
      Tpair (Tquantum (g, t1), Tquantum (g, t2))
    | _ -> assert false)
  | Esplit (Ppure, e) ->
    (match synth decls ctx e with
    | Tquantum (_, Tepair (t1, t2)) ->
      Tpair (Tquantum (Purity.pure, t1), Tquantum (Purity.pure, t2))
    | _ -> assert false)
  | Esplit (_, _) -> assert false
  | Ecast (Ppure, e) ->
    (match synth decls ctx e with
    | Tquantum (p', t) ->
      if Purity.is_pure p'
      then Tquantum (p', t)
      else raise (Error "Illegal cast does not cover all split<M> branches.")
    | _ -> assert false)
  | Ecast (Pmixed, e) -> synth decls ctx e
  | Ecast (Pvar x, e) ->
    let p2 = Purity.lift (Pvar x) in
    (match synth decls ctx e with
    | Tquantum (p1, t) ->
      if Purity.equal p1 p2
      then Tquantum (p1, t)
      else raise (Error "Illegal cast to an incompatible purity.")
    | _ -> assert false)
  | Ebool _ -> Tbool
  | Eif (e, e1, e2) ->
    let (_ : Purity.purity typ) = synth decls ctx e in
    let (_ : Purity.purity typ) = synth decls ctx e1 in
    mix (synth decls ctx e2)
  | Emeasure e ->
    (match synth decls ctx e with
    | Tquantum (_, t) -> classical t
    | _ -> assert false)
  | Equantum (_, _) -> assert false
;;

let check (decls, e) =
  let decls =
    List.fold_left decls ~init:VarMap.empty ~f:(fun decls (key, t2, e) ->
        let (_ : Purity.purity typ) = synth decls VarMap.empty e in
        let rec synth_p = function
          | Pid (_, t) -> t
          | Ppair (p1, p2) -> Tpair (synth_p p1, synth_p p2)
          | Punit -> Tunit
          | Pinfer _ -> assert false
        in
        let t1 =
          match e with
          | Elam (p, _) -> synth_p p
          | _ -> assert false
        in
        let data = Tfun (t1, t2) in
        VarMap.add_exn decls ~key ~data)
  in
  ignore (synth decls VarMap.empty e : Purity.purity typ)
;;
